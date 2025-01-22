import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import '../models/distance_bottom_sheet.dart';
import '../utils/constants.dart';
import '../api/apis.dart';
import '../services/location_services.dart';
import '../widgets/compass.dart';
import '../widgets/map_view.dart';
import '../widgets/location_button.dart';
import '../widgets/turn_by_turn.dart';
import '../widgets/zoom_button.dart';
import '../widgets/search_input.dart';


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
  List<dynamic> placeDetails=[];
  GeoPoint? _startLocation;
  GeoPoint? _destinationLocation;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 100,
  );
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isFetching = false; // Prevent multiple fetches
  List<dynamic> routes =[];
  bool isNavigating=false;
  String _instruction="";
  double _distance=0.0;
  String _laneName="";
  int currentStepIndex = 1;
  String _instruction_text="";
  double _speed = 0.0;

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
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    // Fetch the current location using the updated LocationService
    GeoPoint? location = await LocationService.initializeLocation(context);

    if (location != null) {
      setState(() {
        _startLocation = location;
        _startController.text = "Your location"; // Display text in the controller

      });

     await _mapController.addMarker(
        _startLocation!,
        markerIcon: MarkerIcon(
          icon: Icon(Icons.location_on, color: Colors.blue, size: 40), // Use a different icon for current location
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
      GeoPoint oldLocation=_startLocation as GeoPoint;
      _mapController.changeLocationMarker(oldLocation:oldLocation,newLocation: geoPoint,angle: 0);
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

  Future<void> _selectSearchResult(
      dynamic result, TextEditingController controller) async {
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
            icon: Icon(Icons.location_on, color: Colors.blue, size: 40), // Use a different icon for current location
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
        Color markerColor = (controller == _startController) ? Colors.blue : Colors.blue;

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
      routes = await ApiService.fetchDirections(_startLocation!, _destinationLocation!);

      // Log the entire response for debugging
      print('Route Response: $routes');

      // Check if routes exist in the response
      if (routes.isNotEmpty) {
        // Get the polyline from the first route response
        List<dynamic> coordinates = routes[0]['geometry']['coordinates']; // This is a List<List<double>>

        // Convert coordinates into GeoPoints
        List<GeoPoint> decodedGeoPoints = coordinates
            .map((point) => GeoPoint(latitude: point[1].toDouble(), longitude: point[0].toDouble()))
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
            zoomInto: true,
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
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
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
    await _mapController.moveTo(_startLocation!,animate: true);
  }

  StreamSubscription<Position>? _positionStream;

  void startLocationTracking() {

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      // Handle the updated position here
      print('Current Position: ${position.latitude}, ${position.longitude}');
      setState(() {
        isNavigating=true;
         // _speed = position.speed * 3.6;
      });
      checkForNextTurn(position);
    });
  }

  void stopLocationTracking() {
    setState(() {
      isNavigating=false;
    });
    _positionStream?.cancel(); // Stop tracking when no longer needed
  }
  void checkForNextTurn(Position userPosition) {
    const double thresholdDistance = 50.0; // Distance in meters to consider "close enough" to a turn
    const double notificationDistance = 200.0; // Distance to notify user before turn
    if (routes.isNotEmpty && routes[0]['legs'].isNotEmpty) {
      List<
          dynamic> steps = routes[0]['legs'][0]['steps']; // Access steps from the first leg

      if (steps.isEmpty || currentStepIndex >= steps.length) {
        print('No valid route steps found or all steps processed.');
        return;
      }

      var step = steps[currentStepIndex];
      List<double> maneuverLocation = List<double>.from(
          step['maneuver']['location']);
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
      }
      else if (distanceToTurn < notificationDistance) {
        // Notify user if they are within notification distance
        setState(() {
          _instruction_text="Prepare for a $_instruction turn onto $_laneName";
        });

      }
    }
    else{
      print("No valid route found");
    }
  }


  void _checkAndShowBottomSheet(BuildContext context, void Function() startLocationTracking) {
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
              return DistanceBottomSheet(placeDetails: null);
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    content: const Text(
                      'We could not fetch the details for the selected place. Click retry to try again.',
                      style: TextStyle(fontSize: 14),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          _checkAndShowBottomSheet(context, startLocationTracking);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
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
          MapView(mapController: _mapController), // Use the new MapView widget

          // Search Input Widget
          if(!isNavigating) ...[
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
]
          else ...[
            TurnByTurnNavigationUI(
              instruction: _instruction,
              distance: "$_distance meters",
              lane:_laneName,
              instructionText: _instruction_text,
            ),
            Positioned(
              bottom: 30,
              left: 16,
              child: Container(
                width: 50, // Adjust the size as needed
                height: 50, // Make it a perfect circle
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${_speed.toStringAsFixed(1)}", // Show speed value
                        style: const TextStyle(
                          fontSize: 24, // Adjust font size
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Text color
                        ),
                      ),
                      const Text(
                        "km/h", // Speed unit
                        style: TextStyle(
                          fontSize: 14, // Smaller font size for unit
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          ],
          // Location Button Widget
          Positioned(
            bottom: 30,
            right: 16,
            child: LocationButton(onPressed: () => _centerOnCurrentLocation()), // Use LocationButton
          ),

          Positioned(
            top:200,
            left: 16,
            child: buildCompass(60, Colors.white, Colors.red),),
          // Zoom Buttons Widget
          Positioned(
            top: 200,
            right: 16,
            child: ZoomButtons(mapController: _mapController,// Use ZoomButton for Zoom Out
            ),
          ),
        ],
      ),
    ),
    );
  }
}
