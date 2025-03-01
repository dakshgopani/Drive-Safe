import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:algorithm_avengers_ves_final/screens/drawer/driving_behaviour_analysis.dart';
import 'package:algorithm_avengers_ves_final/screens/drawer/rewards_screen.dart';
import 'package:algorithm_avengers_ves_final/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/distance_bottom_sheet.dart';
import '../services/trip_service.dart';
import '../utils/constants.dart';
import '../api/apis.dart';
import '../services/location_services.dart';
import '../widgets/compass.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/map_view.dart';
import '../widgets/location_button.dart';
import '../widgets/turn_by_turn.dart';
import '../widgets/zoom_button.dart';
import '../widgets/search_input.dart';
import 'package:confetti/confetti.dart';

import 'package:algorithm_avengers_ves_final/screens/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';


// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapScreen extends StatefulWidget {
  final String userName;
  final String email;
  final String userId;
  final double? latitude;
  final double? longitude;

  const MapScreen({Key? key,  required this.userName,  required this.email,required this.userId,this.latitude,
    this.longitude,}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin,WidgetsBindingObserver{
  final MapController _mapController=MapController(
    initPosition: GeoPoint(latitude: 0, longitude: 0),
  );
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  List<dynamic> _searchResults = [];
  List<dynamic> placeDetails = [];
  GeoPoint? _startLocation;
  GeoPoint? _destinationLocation;
  String uniqueId = "Fetching...";
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 100,
  );
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isFetching = false; // Prevent multiple fetches
  List<dynamic> routes = [];
  bool isNavigating = false;
  String _instruction = "";
  double _distance = 0.0;
  String _laneName = "";
  int currentStepIndex = 1;
  String _instruction_text = "";
  double _speed = 0.0;
  bool _tripCompleted = false; // Flag to prevent repeated pop-ups
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _searchSlideAnimation;
  late Animation<Offset> _backgroundSlideAnimation;
  bool isSearching = false;
  List<Map<String, String>> _savedPlaces = [];
  List<GeoPoint> _markerLocations = [];
  OverlayEntry? _blurOverlay;
  OverlayEntry? _capsuleOverlay;
  bool isBottomSheetVisible = false;
  double currentRotation = 0.0; // Tracks the cumulative rotation angle
  StreamSubscription? _gyroscopeSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeLocation();
    _setupAnimations();
    _loadSavedPlaces();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _startController.dispose();
    _destinationController.dispose();
    _mapController.dispose();
    _animationController.dispose();
    _stopLocationTracking();
    _positionStream?.cancel();
    super.dispose();
  }
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _backgroundSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _searchSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));



    _animationController.forward();
  }


  Future<void> _fetchUniqueId() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await firestore.FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            uniqueId = userDoc.id;
          });
        }
      }
    } catch (e) {
      print("Error fetching UID: $e");
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing out: $e")),
      );
    }
  }
  Future<void> _initializeLocation() async {
    // Fetch the current location using the updated LocationService
    GeoPoint? location = await LocationService.initializeLocation(context);

    if (location != null) {
      setState(() {
        _startLocation = location;
        _startController.text =
        "Your location"; // Display text in the controller
      });

      await _mapController.addMarker(
        _startLocation!,
        markerIcon: MarkerIcon(
          icon: Icon(
            Icons.location_on,
            color: Colors.blueAccent, // Icon color
            size: 40, // Icon size
          ),
        ),
      );
      await _mapController.moveTo(location, animate: true);
      await _mapController.setZoom(zoomLevel: 15);
      _startLocationTracking();
      checkForIncident();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch location.'),
        ),
      );
    }
  }
  void checkForIncident() {
    try {
      if (widget.latitude != null && widget.longitude != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _addMarker(widget.latitude!, widget.longitude!);
        });
      }
    } catch (e) {

      checkForIncident();
    }
  }

  Future<void> _addMarker(double lat, double lon) async {
    await _mapController.addMarker(
      GeoPoint(latitude: lat, longitude: lon),
      markerIcon: MarkerIcon(
        icon: Icon(
          Icons.location_pin,
          color: Colors.red,
          size: 48,
        ),
      ),
    );
    await _mapController.setZoom(zoomLevel: 12);
    await _mapController.moveTo(GeoPoint(latitude: lat, longitude: lon),animate: true);
  }

  // Start tracking the location in real-time using LocationService
  void _startLocationTracking() {
    LocationService.startTrackingLocation((geoPoint) {
      GeoPoint oldLocation = _startLocation as GeoPoint;
      _mapController.changeLocationMarker(
          oldLocation: oldLocation, newLocation: geoPoint, angle: 0);
      setState(() {
        _startLocation = geoPoint;
      });
    });
  }

  // Stop location tracking when no longer needed
  void _stopLocationTracking() async {
    await LocationService.stopTrackingLocation();
  }

  void _fetchSearchResultsDebounced(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults.clear());
      return;
    }

    if (_isFetching) return; // Prevent multiple fetches

    _isFetching = true;

    Future.delayed(const Duration(milliseconds: 300), () {
      ApiService.fetchSearchResults(query).then((results) {
        setState(() {
          _searchResults = results;
          _isFetching = false;
        });
      }).catchError((e) {
        print('Error fetching search results: $e');
        _isFetching = false;
      });
    });
  }

  Future<void> _selectSearchResult(dynamic result,
      TextEditingController controller) async {
    try {
      // Check if the result is "Your Location"
      if (result['description'] == "Your Location") {
        // Fetch the current position of the user
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        // Create a GeoPoint from the current position
        final currentLocation = GeoPoint(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        setState(() {
          _startLocation = currentLocation; // Use current location
        });

        // Clear search results and set text in controller
        setState(() {
          _searchResults.clear();
          controller.text = result['description']; // "Your Location"
        });

        // Add a marker for the current location
        await _mapController.addMarker(
          currentLocation,
          markerIcon: MarkerIcon(
            icon: Icon(Icons.location_on,
                color: Colors.blueAccent,
                size: 40), // Use a different icon for current location
          ),
        );
      } else {

        // Fetch place details for other locations
        placeDetails = await ApiService.fetchPlaceDetails(result['place_id']);

        // Set the start or destination location based on the controller
        if (controller == _startController) {
          setState(() {
            _startLocation = placeDetails[0];
          });
        } else {
          setState(() {
            _destinationLocation = placeDetails[0];
          });
        }

        // Clear search results and set text in controller
        setState(() {
          _searchResults.clear();
          controller.text = result['description'];
        });

        // Determine marker color based on which controller is used
        Color markerColor = (controller == _startController)
            ? Colors.blueAccent
            : Colors.red;

        // Add a marker for the selected place with appropriate color
        await _mapController.addMarker(
          placeDetails[0],
          markerIcon: MarkerIcon(
            icon: Icon(Icons.location_on, color: markerColor, size: 40),
          ),
        );
      }

      // Draw road between points if both locations are set
      if (_startLocation != null && _destinationLocation != null) {
        await _drawRoadBetweenPoints();
      }
    } catch (e) {
      print('Error selecting search result: $e');
    }
  }


  Future<void> _setplaceDetails() async {
    await Future.delayed(const Duration(seconds: 2));

    if (placeDetails.length > 1) {
      String? placeName = placeDetails[1]['name']?.trim();
      String? formattedAddress = placeDetails[1]['formatted_address']?.trim();
      String? placeId = placeDetails[1]['place_id']?.trim();

      if (placeName != null && formattedAddress != null && placeId != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Retrieve existing saved places
        List<String> savedPlacesJson = prefs.getStringList('cached_places') ?? [];
        Set<String> existingPlaceIds = savedPlacesJson.map((placeJson) {
          Map<String, dynamic> place = jsonDecode(placeJson);
          return place['place_id'] as String;
        }).toSet();

        // Check if the place already exists in the saved list
        if (!existingPlaceIds.contains(placeId)) {
          // Create a new place entry
          Map<String, String> newPlace = {
            'name': placeName,
            'formatted_address': formattedAddress,
            'place_id': placeId,
          };

          // Convert to JSON string and add to list
          savedPlacesJson.add(jsonEncode(newPlace));

          // Save updated list back to SharedPreferences
          await prefs.setStringList('cached_places', savedPlacesJson);

          print("_setPlaceDetails: Place details saved successfully.");
        } else {
          print("_setPlaceDetails: Duplicate place details detected. Skipping save.");
        }
      }
      return placeDetails[1];
    } else {
      print("_setplaceDetails: Error in fetching place details");
    }
  }
  Future<void> _loadSavedPlaces() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedPlaces = prefs.getStringList('cached_places');

    if (savedPlaces != null && savedPlaces.isNotEmpty) {
      setState(() {
        _savedPlaces = savedPlaces.map((place) => Map<String, String>.from(
            jsonDecode(place))).toList();
      });
    }
    print("Saved data: $savedPlaces");
  }

  Future<void> _drawRoadBetweenPoints() async {
    try {
      // Fetch directions using the provided fetchDirections function
      routes = await ApiService.fetchDirections(
          _startLocation!, _destinationLocation!);

      // Log the entire response for debugging
      print('Route Response: $routes');

      // Check if routes exist in the response
      if (routes.isNotEmpty) {
        // Get the polyline from the first route response
        List<dynamic> coordinates = routes[0]['geometry']
        ['coordinates']; // This is a List<List<double>>

        // Convert coordinates into GeoPoints
        List<GeoPoint> decodedGeoPoints = coordinates
            .map((point) =>
            GeoPoint(
                latitude: point[1].toDouble(), longitude: point[0].toDouble()))
            .toList();

        // Check if decoding was successful
        if (decodedGeoPoints.isEmpty) {
          print('Decoded polyline is empty.');
          return;
        }
        // Draw the road manually on the map
        await _mapController.drawRoadManually(
          decodedGeoPoints,
          const RoadOption(
            roadWidth: 20.0,
            roadColor: Colors.blueAccent,
            roadBorderColor: Colors.black,
            roadBorderWidth: 2.5,
            zoomInto: false,
            // earlier it was true
            isDotted: false,
          ),
        );
      } else {
        print('No valid route found in response.');
      }
    } catch (e) {
      print('Error drawing road between points: $e');
    }
  }

// Function to decode polyline (you may already have this)
  List<List<num>> decodePolyline(String encoded) {
    List<List<num>> coordinates = [];
    int index = 0,
        len = encoded.length;
    int lat = 0,
        lng = 0;

    while (index < len) {
      int b,
          shift = 0,
          result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result >> 1) ^ -(result & 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result >> 1) ^ -(result & 1));
      lng += dlng;

      coordinates.add([lat / 1E5, lng / 1E5]);
    }

    return coordinates;
  }

  Future<void> _deleteRoadAndMarker() async {
    try {
      await _mapController.removeLastRoad();
      await _mapController.removeMarker(_destinationLocation!);
    } catch (e) {
      print('Error drawing road between points: $e');
    }
  }

  Future<void> _centerOnCurrentLocation() async {
    await _mapController.setZoom(zoomLevel: 15);
    await _mapController.rotateMapCamera(0);
    await _mapController.moveTo(_startLocation!, animate: true);
  }

  StreamSubscription<Position>? _positionStream;


  void startLocationTracking() {
    const double thresholdDistance = 10.0; // Trip completes within 10 meters

    double totalDistanceTraveled = 0.0;
    double lastKnownSpeed = 0.0;
    double totalSpeed = 0.0;
    int speedCount = 0;
    DateTime? tripStartTime;
    Position? previousPosition;

    tripStartTime = DateTime.now();

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
          // ---------- DYNAMIC TRIP TRACKING ----------
          GeoPoint userLocation = GeoPoint(
            latitude: position.latitude,
            longitude: position.longitude,
          );

          GeoPoint? _startLocation; // Store the first recorded position

          GeoPoint destination = _destinationLocation ?? GeoPoint(latitude: 19.1889541, longitude: 72.835543);

          double dynamicDistance = Geolocator.distanceBetween(
            userLocation.latitude,
            userLocation.longitude,
            destination.latitude,
            destination.longitude,
          );

          if (_startLocation == null) {
            _startLocation = GeoPoint(
              latitude: position.latitude,
              longitude: position.longitude,
            );
            print("🚀 Start Location Captured: $_startLocation");
          }

          setState(() {
            isNavigating = true;
            // _speed = position.speed * 3.6;
          });
          checkForNextTurn(position);
          _startGyroscopeListener();

          print('📏 Distance to Destination (Live): ${dynamicDistance.toStringAsFixed(2)} meters');
          // Speed tracking
          double speed = position.speed; // Speed in meters per second
          lastKnownSpeed = speed * 3.6; // Convert to km/h
          totalSpeed += lastKnownSpeed;
          speedCount++;

          if (previousPosition != null) {
            double segmentDistance = Geolocator.distanceBetween(
              previousPosition!.latitude,
              previousPosition!.longitude,
              position.latitude,
              position.longitude,
            );
            totalDistanceTraveled += segmentDistance;
          }
          previousPosition = position;

          if (dynamicDistance <= thresholdDistance && !_tripCompleted) {
            _tripCompleted = true;

            Duration tripDuration = DateTime.now().difference(tripStartTime!);
            double avgSpeed = speedCount > 0 ? totalSpeed / speedCount : 0;

            print("🎉 Trip Completed - Dynamic Data");

            // Save dynamic trip data to Firestore
            TripService(
              tripStartTime: tripStartTime!,
              totalDistanceTraveled: totalDistanceTraveled,
              totalSpeed: totalSpeed,
              speedCount: speedCount,
              startLocation: {
                "latitude": _startLocation!.latitude,
                "longitude": _startLocation!.longitude,
              }, // ✅ Correct start location
              destination: {
                "latitude": destination.latitude,
                "longitude": destination.longitude,
              },
              tripDuration: tripDuration,
            ).saveTripDataToFirestore().then((tripId) {
              _showTripCompletedPopup(userId!, tripId); // ✅ Pass tripId
            });


          } else {
            print("🚗 Trip NOT Completed Yet (Live)");
          }

          // ---------- STATIC TESTING ----------
          // const double simulatedLat = 19.1889541;
          // const double simulatedLng = 72.835543;
          // GeoPoint? _startLocation; // Store the first recorded position
          //
          // GeoPoint simulatedSource = GeoPoint(
          //     latitude: simulatedLat, longitude: simulatedLng);
          // GeoPoint staticDestination = GeoPoint(
          //     latitude: 19.1889541, longitude: 72.835543);
          //
          // double staticDistance = Geolocator.distanceBetween(
          //   simulatedSource.latitude,
          //   simulatedSource.longitude,
          //   staticDestination.latitude,
          //   staticDestination.longitude,
          // );
          //
          // if (_startLocation == null) {
          //   _startLocation = GeoPoint(
          //     latitude: position.latitude,
          //     longitude: position.longitude,
          //   );
          //   print("🚀 Start Location Captured: $_startLocation");
          // }
          //
          // print('📏 Distance to Destination (Static Test): ${staticDistance
          //     .toStringAsFixed(2)} meters');
          //
          // if (staticDistance <= thresholdDistance && !_tripCompleted) {
          //   print("🎉 Trip Completed - Static Test");
          //   // _showTripCompletedPopup();
          //   _tripCompleted = true; // ✅ Prevent multiple pop-ups
          //
          //   Duration staticTripDuration = Duration(minutes: 15, seconds: 20);
          //   double staticAvgSpeed = 45.0;
          //   double staticTotalDistance = 5000.0; // Dummy total distance (5 km)
          //
          //   // Save static trip data to Firestore
          //   TripService(
          //     tripStartTime: tripStartTime!,
          //     totalDistanceTraveled: staticTotalDistance,
          //     totalSpeed: staticAvgSpeed * 15,
          //     // Dummy speed calculations
          //     speedCount: 15,
          //     // Dummy speed count
          //     startLocation: {
          //       "latitude": _startLocation!.latitude,
          //       "longitude": _startLocation!.longitude,
          //     },
          //     // ✅ Correct start location
          //     destination: {
          //       "latitude": staticDestination.latitude,
          //       "longitude": staticDestination.longitude,
          //     },
          //     tripDuration: staticTripDuration,
          //   ).saveTripDataToFirestore().then((tripId) {
          //     _showTripCompletedPopup(userId!, tripId); // ✅ Pass tripId
          //   });
          // } else {
          //   print("🚗 Trip NOT Completed Yet (Static Test)");
          // }
          //
        });

  }

  void _navigateToRewardsScreen(String userId, String tripId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RewardsSystem(userId: userId, requestId: tripId),
      ),
    );
  }


  // *Function to show the trip completed pop-up*

  void _showTripCompletedPopup(String userId, String tripId) {
    ConfettiController confettiController = ConfettiController(
        duration: const Duration(seconds: 3));

    confettiController.play(); // Start confetti animation

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 🎉 Confetti Animation
              Positioned(
                top: 0,
                child: ConfettiWidget(
                  confettiController: confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  // Burst effect
                  emissionFrequency: 0.03,
                  // More frequent confetti bursts
                  numberOfParticles: 50,
                  // Increase for more confetti
                  gravity: 0.3,
                  // Slower fall effect
                  shouldLoop: false,
                  colors: [
                    Colors.redAccent,
                    Colors.greenAccent,
                    Colors.blueAccent,
                    Colors.orangeAccent,
                    Colors.purpleAccent,
                  ],
                ),
              ),

              // 🎊 Pop-Up UI
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent.shade200, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.celebration, // 🎉 Celebration icon
                      color: Colors.white,
                      size: 80,
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "Trip Completed!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "You have successfully reached your destination.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // View Rewards Button
                    ElevatedButton(
                      onPressed: () {
                        confettiController.stop(); // Stop confetti animation
                        Navigator.pop(context); // Close pop-up
                        _navigateToRewardsScreen(
                            userId, tripId); // ✅ Go to Rewards Screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 30),
                        elevation: 5,
                      ),
                      child: const Text(
                        "View Rewards 🎁",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  void stopLocationTracking() {
    setState(() {
      isNavigating = false;
    });
    _positionStream?.cancel(); // Stop tracking when no longer needed
  }

  void checkForNextTurn(Position userPosition) {
    const double thresholdDistance =
    50.0; // Distance in meters to consider "close enough" to a turn
    const double notificationDistance =
    200.0; // Distance to notify user before turn
    if (routes.isNotEmpty && routes[0]['legs'].isNotEmpty) {
      List<dynamic> steps =
      routes[0]['legs'][0]['steps']; // Access steps from the first leg

      if (steps.isEmpty || currentStepIndex >= steps.length) {
        print('No valid route steps found or all steps processed.');
        return;
      }

      var step = steps[currentStepIndex];
      List<double> maneuverLocation =
      List<double>.from(step['maneuver']['location']);
      double distanceToTurn = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        maneuverLocation[1], // latitude
        maneuverLocation[0], // longitude
      );
      setState(() {
        _instruction = step['maneuver']['modifier'] ?? 'Continue Straight';
        _distance = step['distance'];
        _laneName = step['name'];
      });
      if (_laneName.contains("No")) {
        _laneName = _laneName.replaceFirst("No", "Number");
      }

      if (distanceToTurn < thresholdDistance) {
        // User is close to the current turn, provide the next instruction
        setState(() {
          _instruction_text = "Take $_instruction onto $_laneName";
        });

        print('Next Turn: $_instruction');

        // Move to the next step
        currentStepIndex++;
      } else if (distanceToTurn < notificationDistance) {
        // Notify user if they are within notification distance
        setState(() {
          _instruction_text =
          "Prepare for a $_instruction turn onto $_laneName";
        });
      }
    } else {
      print("No valid route found");
    }
  }

  void _checkAndShowBottomSheet(BuildContext context,
      void Function() startLocationTracking) {
    // Show the bottom sheet
    showBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      showDragHandle: false,
      // Add this to control the size of the bottom sheet
      builder: (_) {
        return FutureBuilder<dynamic>(
          future: _setplaceDetails(), // Method to fetch place details
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Pass null to show loading state
              return const DistanceBottomSheet(placeDetails: null);
            } else {
              final fetchedPlaceDetails = snapshot.data;
              print("$fetchedPlaceDetails");
              if (fetchedPlaceDetails is Map<String, dynamic>) {
                return DistanceBottomSheet(
                  placeDetails: fetchedPlaceDetails,
                  startLocationTracking: startLocationTracking,
                );
              } else {
                return Center(
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'Invalid Place Details',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    content: const Text(
                      'We could not fetch the details for the selected place. Click retry to try again.',
                      style: TextStyle(fontSize: 14),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          _checkAndShowBottomSheet(
                              context, startLocationTracking);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blueAccent,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
            }
          },
        );
      },
    );
    setState(() {
      isSearching=false;
    });
  }
  Future<Offset?> calculateScreenCoordinates(GeoPoint targetPoint) async {
    // 1. Retrieve the current bounding box of the map
    BoundingBox? boundingBox = await _mapController.bounds;
    if (boundingBox == null) return null;

    // 2. Get the size of the map widget
    RenderBox? mapRenderBox = _scaffoldKey.currentContext?.findRenderObject() as RenderBox?;
    if (mapRenderBox == null) return null;
    Size mapSize = mapRenderBox.size;

    // 3. Calculate latitude and longitude ranges
    double latRange = boundingBox.north - boundingBox.south;
    double lonRange = boundingBox.east - boundingBox.west;

    // Ensure ranges are not zero to avoid division by zero
    if (latRange <= 0 || lonRange <= 0) return null;

    // 4. Calculate the relative position of the target point within the bounding box
    double latRelative = (boundingBox.north - targetPoint.latitude) / latRange;
    double lonRelative = (targetPoint.longitude - boundingBox.west) / lonRange;

    // 5. Fine-tune the x-coordinate to adjust for the right-side shift
    double xAdjustmentFactor = 0.98; // Adjust this value (e.g., 0.98 shifts slightly left)
    double rawX = lonRelative * mapSize.width * xAdjustmentFactor;
    double rawY = latRelative * mapSize.height;

    // 6. Clamp the coordinates to ensure they stay within the screen bounds
    double x = rawX.clamp(0, mapSize.width); // Clamp x between 0 and map width
    double y = rawY.clamp(0, mapSize.height); // Clamp y between 0 and map height

    // 7. Check if the capsule goes out of the screen width and flip it if necessary
    const capsuleWidth = 56.0; // Width of the capsule (adjust based on your design)
    if (x + capsuleWidth > mapSize.width) {
      // Flip the capsule to the opposite side
      x = mapSize.width - capsuleWidth - (mapSize.width - x);
    }

    return Offset(x, y);
  }

  void _updateMarkerIcon(GeoPoint markerLocation, IconData icon, Color color) async {
    setState(() {
      _markerLocations.add(markerLocation); // Store the marker location
    });
    if (!_markerLocations.contains(markerLocation)) {
      print("Error: Marker location not found.");
      return;
    }

    // Remove the old marker
    await _mapController.removeMarker(markerLocation);

    // Add a new marker with the updated icon
    await _mapController.addMarker(
      markerLocation,
      markerIcon: MarkerIcon(
        icon: Icon(icon, color: color, size: 40),
      ),
    );
  }


  void _showReactionCapsule(GeoPoint location) async {
    _removeReactionCapsule();
    // Calculate the screen coordinates asynchronously
    Offset? screenCoordinate = await calculateScreenCoordinates(location);

    if (screenCoordinate == null) {
      print("Failed to calculate screen coordinates for the marker.");
      return;
    }

    // Create the OverlayEntry for the blurred background
    OverlayEntry blurOverlay = OverlayEntry(
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Apply blur effect
        child: Container(
          color: Colors.black.withOpacity(0.3), // Semi-transparent background
        ),
      ),
    );

    // Create the OverlayEntry for the reaction capsule
    OverlayEntry capsuleOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: screenCoordinate.dx - 50, // Offset horizontally
        top: screenCoordinate.dy - 100, // Offset vertically
        child: _buildReactionCapsule(location),
      ),
    );

    // Insert both overlays into the Overlay
    Overlay.of(context).insert(blurOverlay);
    Overlay.of(context).insert(capsuleOverlay);

    // Store references to both overlays for removal later
    _blurOverlay = blurOverlay;
    _capsuleOverlay = capsuleOverlay;
  }
  void _removeReactionCapsule() {
    _blurOverlay?.remove();
    _capsuleOverlay?.remove();
    _blurOverlay = null;
    _capsuleOverlay = null;
  }
  void addMarker(GeoPoint location) async {
    await _mapController.addMarker(location);
    setState(() {
      _markerLocations.add(location); // Store the marker location
    });
  }

  void _startGyroscopeListener() {
    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      // event.z gives the rotation around the vertical axis (yaw)
      double rotationChange = event.z * 5; // Scale factor to adjust sensitivity
      currentRotation += rotationChange;

      // Keep rotation between 0 and 360 degrees
      currentRotation %= 360;

      // Rotate camera to the new angle
      _mapController.rotateMapCamera(currentRotation);
    });
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print("Back button pressed"); // Debugging
        if (isSearching) {
          if (mounted) {
            print("Mounted");
            setState(() => isSearching = false); // Close search screen
          }
          return false; // Prevent navigating back
        }
        else if(isNavigating)
          {
            if(mounted)
              {
                setState(() {
                  isNavigating=false;
                  _deleteRoadAndMarker();
                  routes=[];
                });
              }
          }
        else{
          Navigator.pop(context);
          _deleteRoadAndMarker();
          _centerOnCurrentLocation();
        }

        // Prevent default back action
        return Future.value(false);
      },
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          drawer: CustomDrawer(
            userName: widget.userName,
            email: widget.email,
            onSignOut: _signOut,
            userId: '',
          ),
          resizeToAvoidBottomInset: false,
          key: _scaffoldKey,
          body: Stack(
            children: [
              // Map View Widget
              MapView(mapController: _mapController,
                showReactionCapsule: _showReactionCapsule,),

              // Toggle between top bar and search UI
              if (!isSearching && !isNavigating) _buildTopBar(),

              // Navigation UI
              if (isNavigating) ...[
                TurnByTurnNavigationUI(
                  instruction: _instruction,
                  distance: "$_distance meters",
                  lane: _laneName,
                  instructionText: _instruction_text,
                ),
                Positioned(
                  bottom: 40,
                  left: 16,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      elevation: 8,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DrivingBehaviorPage()),
                      );
                    },
                    child: const Text(
                      "Check Driving  \nBehaviour Analysis",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],

              // Location and Compass Buttons
              Positioned(
                top: isNavigating ? 280 : 200,
                left: 16,
                child: LocationButton(onPressed: _centerOnCurrentLocation),
              ),
              Positioned(
                top: isNavigating ? 210 : 130,
                left: 16,
                child: buildCompass(60, Colors.white, Colors.red),
              ),
              Positioned(
                top: isNavigating ? 210 :130,
                right: 16,
                child: ZoomButtons(mapController: _mapController),
              ),
              _buildDrivingStats(),

              // Show Search Screen if searching
              if (isSearching) _buildSearchScreen(),
            ],
          ),
        ),
      ),
    );
  }
  /// *Builds the Top Bar*
  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Menu Button with Builder
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Search Bar
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => isSearching = true), // Enable search UI
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      const Text(
                        "Search",
                        style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Profile Button
            _buildQuickActionButton(
              icon: Icons.person_outline,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    userName: widget.userName,
                    email: widget.email,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// *Builds the Search UI*
  Widget _buildSearchScreen() {
    return Positioned.fill(

      child: SlideTransition(
        position: _backgroundSlideAnimation, // Background slides from bottom
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white, // Background
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // Search Input slides in from the top
                    SlideTransition(
                      position: _searchSlideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SearchInput(
                          startController: _startController,
                          destinationController: _destinationController,
                          fetchSearchResultsDebounced: _fetchSearchResultsDebounced,
                          searchResults: _searchResults,
                          selectSearchResult: _selectSearchResult,
                          checkAndShowBottomSheet: _checkAndShowBottomSheet,
                          deleteRoadandMarker: _deleteRoadAndMarker,
                          startLocationTracking: startLocationTracking,
                          savedPlaces: _savedPlaces,
                        ),
                      ),
                    ),

                    // Fade in _buildNoRecentSearch() if no saved places
                    if (_savedPlaces.isEmpty && _searchResults.isEmpty)
                      Positioned.fill(
                        child: AnimatedOpacity(
                          opacity: _fadeAnimation.value,
                          duration: const Duration(milliseconds: 400),
                          child: _buildNoRecentSearch(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  /// *Reusable Quick Action Button*
  Widget _buildQuickActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.blueAccent, size: 24),
      ),
    );
  }

  Widget _buildNoRecentSearch() {
    if (_savedPlaces.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Use min to center the content in the available space
          children: [
            Image.asset(
              "assets/images/no_search.jpg", // Replace with your image path
              width: 220,
              height: 220,
            ),
            const SizedBox(height: 16),
            const Text(
              "No Recent Search",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedPlaces.length,
      itemBuilder: (context, index) {
        final place = _savedPlaces[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: const Icon(Icons.location_on, color: Colors.blue),
            title: Text(
              place['name'] ?? "Unknown Place",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle:
            Text(place['formatted_address'] ?? "No Address Available"),
            onTap: () {
              print("Selected: ${place['name']}");
              // Handle place selection
            },
          ),
        );
      },
    );
  }

  Widget _buildReactionCapsule(GeoPoint tappedLocation) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(4),  // Reduced padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // Smaller capsule
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6, // Reduced blur
              offset: Offset(0, 2), // Adjusted shadow
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMarkerOption(Icons.home, Colors.red, tappedLocation),
            const SizedBox(width: 4),  // Reduced spacing
            _buildMarkerOption(Icons.work, Colors.green, tappedLocation),
            const SizedBox(width: 4),
            _buildMarkerOption(Icons.directions_car, Colors.blue, tappedLocation),
            const SizedBox(width: 4),
            _buildMarkerOption(Icons.star, Colors.amber, tappedLocation),
            const SizedBox(width: 4),
            _buildMarkerOption(Icons.flag, Colors.orange, tappedLocation),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkerOption(IconData icon, Color color, GeoPoint tappedLocation) {
    return GestureDetector(
      onTap: () {
        _updateMarkerIcon(tappedLocation, icon, color);
        _removeReactionCapsule();
      },
      child: Container(
        padding: const EdgeInsets.all(6),  // Reduced padding inside the icon
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 28), // Reduced icon size
      ),
    );
  }

  Widget _buildDrivingStats() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: MediaQuery.of(context).padding.top,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  isNavigating ? "Navigation Active" : "Today's Drive",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.speed,
                  value: "0",
                  unit: "km/h",
                  label: "Current Speed",
                  color: Colors.blue,
                ),
                _buildStatItem(
                  icon: Icons.timer,
                  value: "0",
                  unit: "hrs",
                  label: "Drive Time",
                  color: Colors.orange,
                ),
                _buildStatItem(
                  icon: Icons.route,
                  value: "0",
                  unit: "km",
                  label: "Distance",
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isNavigating ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            isNavigating ? Icons.navigation : Icons.circle,
            color: isNavigating ? Colors.blue : Colors.green,
            size: 8,
          ),
          const SizedBox(width: 4),
          Text(
            isNavigating ? "Navigating" : "Active",
            style: TextStyle(
              color: isNavigating ? Colors.blue[700] : Colors.green[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String unit,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: " $unit",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}