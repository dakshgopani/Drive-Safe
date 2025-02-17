import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:algorithm_avengers_ves_final/screens/drawer/driving_behaviour_analysis.dart';
import 'package:algorithm_avengers_ves_final/screens/drawer/rewards_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import '../models/distance_bottom_sheet.dart';
import '../services/trip_service.dart';
import '../utils/constants.dart';
import '../api/apis.dart';
import '../services/location_services.dart';
import '../widgets/compass.dart';
import '../widgets/map_view.dart';
import '../widgets/location_button.dart';
import '../widgets/turn_by_turn.dart';
import '../widgets/zoom_button.dart';
import '../widgets/search_input.dart';
import 'package:confetti/confetti.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController _mapController;
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  List<dynamic> _searchResults = [];
  List<dynamic> placeDetails = [];
  GeoPoint? _startLocation;
  GeoPoint? _destinationLocation;
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


  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _mapController = MapController(
      initPosition: GeoPoint(latitude: 0, longitude: 0),
    );
  }

  @override
  void dispose() {
    _startController.dispose();
    _destinationController.dispose();
    _mapController.dispose();
    _stopLocationTracking();
    _positionStream?.cancel();
    super.dispose();
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
        markerIcon: const MarkerIcon(
          icon: Icon(Icons.location_on,
              color: Colors.blueAccent,
              size: 40), // Use a different icon for current location
        ),
      );
      await _mapController.moveTo(location, animate: true);
      await _mapController.setZoom(zoomLevel: 15);
      _startLocationTracking();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch location.'),
        ),
      );
    }
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
          markerIcon: const MarkerIcon(
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
        Color markerColor =
        (controller == _startController) ? Colors.blueAccent : Colors.red;

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

  Future<dynamic> _setplaceDetails() async {
    // Simulate a delay to mimic an asynchronous operation
    await Future.delayed(const Duration(seconds: 2));

    // Return the second element of placeDetails if available
    if (placeDetails != null && placeDetails.length > 1) {
      return placeDetails[1];
    }

    // Return null if placeDetails is not ready or invalid
    return null;
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
          // GeoPoint userLocation = GeoPoint(
          //   latitude: position.latitude,
          //   longitude: position.longitude,
          // );
          //
          // GeoPoint? _startLocation; // Store the first recorded position
          //
          // GeoPoint destination = _destinationLocation ?? GeoPoint(latitude: 19.1889541, longitude: 72.835543);
          //
          // double dynamicDistance = Geolocator.distanceBetween(
          //   userLocation.latitude,
          //   userLocation.longitude,
          //   destination.latitude,
          //   destination.longitude,
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
          //
          // print('📏 Distance to Destination (Live): ${dynamicDistance.toStringAsFixed(2)} meters');
          //
          // setState(() {
          //   isNavigating = true;
          // });
          //
          // // Speed tracking
          // double speed = position.speed; // Speed in meters per second
          // lastKnownSpeed = speed * 3.6; // Convert to km/h
          // totalSpeed += lastKnownSpeed;
          // speedCount++;
          //
          // if (previousPosition != null) {
          //   double segmentDistance = Geolocator.distanceBetween(
          //     previousPosition!.latitude,
          //     previousPosition!.longitude,
          //     position.latitude,
          //     position.longitude,
          //   );
          //   totalDistanceTraveled += segmentDistance;
          // }
          // previousPosition = position;
          //
          // checkForNextTurn(position);
          //
          // if (dynamicDistance <= thresholdDistance && !_tripCompleted) {
          //   _tripCompleted = true;
          //
          //   Duration tripDuration = DateTime.now().difference(tripStartTime!);
          //   double avgSpeed = speedCount > 0 ? totalSpeed / speedCount : 0;
          //
          //   print("🎉 Trip Completed - Dynamic Data");
          //
          //   // Save dynamic trip data to Firestore
          //   TripService(
          //     tripStartTime: tripStartTime!,
          //     totalDistanceTraveled: totalDistanceTraveled,
          //     totalSpeed: totalSpeed,
          //     speedCount: speedCount,
          //     startLocation: {
          //       "latitude": _startLocation!.latitude,
          //       "longitude": _startLocation!.longitude,
          //     }, // ✅ Correct start location
          //     destination: {
          //       "latitude": destination.latitude,
          //       "longitude": destination.longitude,
          //     },
          //   ).saveTripDataToFirestore().then((tripId) {
          // _showTripCompletedPopup(userId!, tripId); // ✅ Pass tripId
          // });
          //
          //
          // } else {
          //   print("🚗 Trip NOT Completed Yet (Live)");
          // }

          // ---------- STATIC TESTING ----------
          const double simulatedLat = 19.1889541;
          const double simulatedLng = 72.835543;
          GeoPoint? _startLocation; // Store the first recorded position

          GeoPoint simulatedSource = GeoPoint(
              latitude: simulatedLat, longitude: simulatedLng);
          GeoPoint staticDestination = GeoPoint(
              latitude: 19.1889541, longitude: 72.835543);

          double staticDistance = Geolocator.distanceBetween(
            simulatedSource.latitude,
            simulatedSource.longitude,
            staticDestination.latitude,
            staticDestination.longitude,
          );

          if (_startLocation == null) {
            _startLocation = GeoPoint(
              latitude: position.latitude,
              longitude: position.longitude,
            );
            print("🚀 Start Location Captured: $_startLocation");
          }

          print('📏 Distance to Destination (Static Test): ${staticDistance
              .toStringAsFixed(2)} meters');

          if (staticDistance <= thresholdDistance && !_tripCompleted) {
            print("🎉 Trip Completed - Static Test");
            // _showTripCompletedPopup();
            _tripCompleted = true; // ✅ Prevent multiple pop-ups

            Duration staticTripDuration = Duration(minutes: 15, seconds: 20);
            double staticAvgSpeed = 45.0;
            double staticTotalDistance = 5000.0; // Dummy total distance (5 km)

            // Save static trip data to Firestore
            TripService(
              tripStartTime: tripStartTime!,
              totalDistanceTraveled: staticTotalDistance,
              totalSpeed: staticAvgSpeed * 15,
              // Dummy speed calculations
              speedCount: 15,
              // Dummy speed count
              startLocation: {
                "latitude": _startLocation!.latitude,
                "longitude": _startLocation!.longitude,
              },
              // ✅ Correct start location
              destination: {
                "latitude": staticDestination.latitude,
                "longitude": staticDestination.longitude,
              },
            ).saveTripDataToFirestore().then((tripId) {
              _showTripCompletedPopup(userId!, tripId); // ✅ Pass tripId
            });
          } else {
            print("🚗 Trip NOT Completed Yet (Static Test)");
          }

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


  // **Function to show the trip completed pop-up**

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
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: [
            // Map View Widget
            MapView(mapController: _mapController),
            // Use the new MapView widget

            // Search Input Widget
            if (!isNavigating) ...[
              SearchInput(
                startController: _startController,
                destinationController: _destinationController,
                fetchSearchResultsDebounced: _fetchSearchResultsDebounced,
                searchResults: _searchResults,
                selectSearchResult: _selectSearchResult,
                checkAndShowBottomSheet: _checkAndShowBottomSheet,
                deleteRoadandMarker: _deleteRoadAndMarker,
                startLocationTracking: startLocationTracking,
              ),
            ] else
              ...[
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
                      //backgroundColor: Colors.transparent, // Transparent background
                      backgroundColor: Colors.blueAccent, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(16), // Rounded corners
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      //shadowColor: Colors.black.withOpacity(0.5),
                      elevation: 8, // Add shadow effect
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
                        fontSize: 12, // Font size for the button
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Text color
                      ),
                    ),
                  ),
                ),

                // Positioned(
                //   bottom: 40,
                //   left: 16,
                //   // top: 50,
                //   child: Container(
                //     width: 50, // Adjust the size as needed
                //     height: 50, // Make it a perfect circle
                //     decoration: BoxDecoration(
                //       color: Colors.white.withOpacity(0.7),
                //       borderRadius: BorderRadius.circular(24),
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.black.withOpacity(0.5),
                //           blurRadius: 20,
                //           offset: const Offset(0, 10),
                //         ),
                //       ],
                //     ),
                //     child: Center(
                //       child: Column(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Text(
                //             "${_speed.toStringAsFixed(1)}", // Show speed value
                //             style: const TextStyle(
                //               fontSize: 24, // Adjust font size
                //               fontWeight: FontWeight.bold,
                //               color: Colors.black, // Text color
                //             ),
                //           ),
                //           const Text(
                //             "km/h", // Speed unit
                //             style: TextStyle(
                //               fontSize: 10, // Smaller font size for unit
                //               color: Colors.black,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
              ],
            // Location Button Widget
            Positioned(
              bottom: 30,
              right: 16,
              child: LocationButton(
                  onPressed: () =>
                      _centerOnCurrentLocation()), // Use LocationButton
            ),

            Positioned(
              top: 200,
              left: 16,
              child: buildCompass(60, Colors.white, Colors.red),
            ),
            // Zoom Buttons Widget
            Positioned(
              top: 200,
              right: 16,
              child: ZoomButtons(
                mapController: _mapController, // Use ZoomButton for Zoom Out
              ),
            ),
          ],
        ),
      ),
    );
  }
}
