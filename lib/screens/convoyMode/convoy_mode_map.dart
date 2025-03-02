import 'dart:async';
import 'dart:collection';

import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import '../../api/apis.dart';
import '../../services/trip_service.dart';
import '../../utils/app_state.dart';
import '../../widgets/compass.dart';
import '../../widgets/location_button.dart';
import '../../widgets/map_view.dart';
import '../../services/location_services.dart';
import '../../widgets/turn_by_turn.dart';
import '../../widgets/zoom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

import '../drawer/rewards_screen.dart';

class ConvoyModeMap extends StatefulWidget {
  const ConvoyModeMap({super.key});

  @override
  State<ConvoyModeMap> createState() => _ConvoyModeMapState();
}

class _ConvoyModeMapState extends State<ConvoyModeMap>
    with WidgetsBindingObserver {
  final MapController _mapController = MapController(
    initPosition: GeoPoint(latitude: 0, longitude: 0),
  );
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 100,
  );
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _instruction = "";
  double _distance = 0.0;
  String _laneName = "";
  int currentStepIndex = 1;
  String _instruction_text = "";
  GeoPoint? _startLocation;
  GeoPoint? _destinationLocation;
  late GeoPoint _currentLocation;
  List<dynamic> routes = [];
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;
  final databaseRef = FirebaseDatabase.instance.ref();
  bool _tripCompleted = false;
  StreamSubscription<Position>? _positionStream;
  String userId = "";
  String roomCode = "";
  bool _isFetchingDestination = false;
  bool isStepsAvailable=false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initializeLocation().then((_) {
      listenForUserLocations(); // Listen for user locations in the Realtime Database
      _fetchRoomCodeAndDestination();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    GeoPoint? location = await LocationService.initializeLocation(context);

    if (location != null) {
      setState(() {
        _startLocation = location;
        _currentLocation = location; // Set the initial location
      });

      await _mapController.addMarker(
        _startLocation!,
        markerIcon: MarkerIcon(
          icon: Icon(
            Icons.location_on,
            color: Colors.blueAccent,
            size: 40,
          ),
        ),
      );

      await _mapController.moveTo(_startLocation!, animate: true);
      await _mapController.setZoom(zoomLevel: 15);

      // Update user location in Firebase Realtime Database
      updateUserLocation(_startLocation!);
    }
  }

  void updateUserLocation(GeoPoint userLocation) {
    userId = FirebaseAuth.instance.currentUser!.uid;
    if (userId != null) {
      // Set the location for the user in Realtime Database
      databaseRef.child("users").child(userId).set({
        'latitude': userLocation.latitude,
        'longitude': userLocation.longitude,
        'timestamp': ServerValue
            .timestamp, // Optional timestamp for when the location was updated
      });
    }
  }

  void listenForUserLocations() {
    databaseRef.child("users").onValue.listen((event) {
      final data = event.snapshot.value;

      // Check if data is not null and cast it to Map
      if (data != null && data is Map<dynamic, dynamic>) {
        // Use forEach to iterate over the Map
        data.forEach((userId, locationData) {
          // Check if locationData is not null and has the expected fields
          if (locationData != null &&
              locationData.containsKey('latitude') &&
              locationData.containsKey('longitude')) {
            double latitude = locationData['latitude'];
            double longitude = locationData['longitude'];

            GeoPoint userLocation =
                GeoPoint(latitude: latitude, longitude: longitude);

            // Add marker for the user
            _mapController.addMarker(
              userLocation,
              markerIcon: MarkerIcon(
                icon: Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 40,
                ),
              ),
            );
          } else {
            print("Invalid location data for user $userId: $locationData");
          }
        });
      } else {
        print("No data found or data is not a Map");
      }
    });
  }

  Future<void> _fetchRoomCodeAndDestination() async {
    if (_isFetchingDestination) return;

    setState(() {
      _isFetchingDestination = true;
    });

    roomCode = appState.roomCode;
    if (roomCode.isNotEmpty) {
      await _fetchDestinationFromFirebase(roomCode);
    } else {
      print("Error: roomCode is empty, cannot fetch destination.");
      _showErrorSnackBar("Room code is missing. Please try again.");
    }

    setState(() {
      _isFetchingDestination = false;
    });
  }

  // Fetch destination location from Firestore and update the state
  Future<void> _fetchDestinationFromFirebase(String roomCode) async {
    try {
      print("Fetching destination for roomCode: '$roomCode'");
      firestore.DocumentSnapshot roomSnapshot =
          await _firestore.collection('rooms').doc(roomCode).get();

      if (roomSnapshot.exists) {
        var roomData = roomSnapshot.data() as Map<String, dynamic>;

        // Check if destination_location exists and is not null
        if (roomData.containsKey('destination_location') &&
            roomData['destination_location'] != null) {
          var destinationLocation = roomData['destination_location'];

          // Make sure latitude and longitude are present and not null
          if (destinationLocation.containsKey('latitude') &&
              destinationLocation.containsKey('longitude')) {
            setState(() {
              _destinationLocation = GeoPoint(
                latitude: destinationLocation['latitude'],
                longitude: destinationLocation['longitude'],
              );
            });

            await _drawRoadBetweenPoints();
            startLocationTracking(); // Start tracking after destination is fetched
            print("Fetched destination: $_destinationLocation");
          } else {
            print('Error: Latitude and/or Longitude missing.');
            _showErrorSnackBar("Invalid destination data. Please try again.");
          }
        } else {
          print('Error: destination_location is missing.');
          _showErrorSnackBar(
              "Destination location not found. Please try again.");
        }
      } else {
        print('Error: Room does not exist.');
        _showErrorSnackBar("Room not found. Please try again.");
      }
    } catch (e) {
      print('Error fetching destination location: $e');
      _showErrorSnackBar("Error fetching destination. Please try again.");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _centerOnCurrentLocation() async {
    if (_startLocation == null) {
      print("Start location is null, cannot center the map.");
      return; // Exit the function if _startLocation is null
    }

    await _mapController.setZoom(zoomLevel: 15);
    await _mapController.rotateMapCamera(0);
    await _mapController.moveTo(_startLocation!, animate: true);
  }

  Future<void> _drawRoadBetweenPoints() async {
    try {
      // Fetch directions using the provided fetchDirections function
      routes = await ApiService.fetchDirections(
          _startLocation!, _destinationLocation!);
      print("Routes:$routes");
      await _mapController.addMarker(
        _destinationLocation!,
        markerIcon: MarkerIcon(
          icon: Icon(
            Icons.location_on,
            color: Colors.blueAccent,
            size: 40,
          ),
        ),
      );

      // Log the entire response for debugging
      print('Route Response: $routes');

      // Check if routes exist in the response
      if (routes.isNotEmpty) {
        // Get the polyline from the first route response
        List<dynamic> coordinates = routes[0]['geometry']
            ['coordinates']; // This is a List<List<double>>

        // Convert coordinates into GeoPoints
        List<GeoPoint> decodedGeoPoints = coordinates
            .map((point) => GeoPoint(
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

  void startLocationTracking() {
    _tripCompleted = false; // Reset the trip completed flag

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

      GeoPoint destination = _destinationLocation ??
          GeoPoint(latitude: 19.1889541, longitude: 72.835543);

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

      print(
          '📏 Distance to Destination (Live): ${dynamicDistance.toStringAsFixed(2)} meters');

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

      checkForNextTurn(position);
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
    });
  }

  void _showTripCompletedPopup(String userId, String tripId) {
    ConfettiController confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

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

  void _navigateToRewardsScreen(String userId, String tripId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RewardsSystem(userId: userId, requestId: tripId),
      ),
    );
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
        isStepsAvailable=true;
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

  @override
  Widget build(BuildContext context) {
    roomCode = appState.roomCode;
    if (roomCode.isEmpty && !_isFetchingDestination) {
      _fetchRoomCodeAndDestination();
    }

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        body: Stack(
          children: [
            // Map View Widget
            MapView(mapController: _mapController),

            // Navigation UI

            TurnByTurnNavigationUI(
              instruction: "Straight road",
              distance: "151.3 meters",
              lane: _laneName,
              instructionText: "Go straight",
            ),

            // Location and Compass Buttons
            Positioned(
              top: 280,
              left: 16,
              child: LocationButton(onPressed: _centerOnCurrentLocation),
            ),
            Positioned(
              top: 210,
              left: 16,
              child: buildCompass(60, Colors.white, Colors.red),
            ),
            Positioned(
              top: 210,
              right: 16,
              child: ZoomButtons(mapController: _mapController),
            ),
            _buildDrivingStats(),
          ],
        ),
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
                  "Navigation Active",
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
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            Icons.navigation,
            color: Colors.blue,
            size: 8,
          ),
          const SizedBox(width: 4),
          Text(
            "Navigating",
            style: TextStyle(
              color: Colors.blue[700],
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
