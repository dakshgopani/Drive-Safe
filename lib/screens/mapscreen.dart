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
import '../widgets/map_view.dart';
import '../widgets/location_button.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _mapController = MapController(
      initPosition: GeoPoint(latitude: 0, longitude: 0),
    );
    _startLocationTracking();
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

      await _mapController.moveTo(location, animate: true);
      await _mapController.setZoom(zoomLevel: 15);
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
      setState(() {
        _startLocation = geoPoint;
      });

      // Update the map to the new location
      _mapController.moveTo(geoPoint, animate: true);
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
      placeDetails = await ApiService.fetchPlaceDetails(result['place_id']);
      if (controller == _startController) {
        setState(() {
          _startLocation = placeDetails[0];
        });
      } else {
        setState(() {
          _destinationLocation = placeDetails[0];
        });
      }

      setState(() {
        _searchResults.clear();
        controller.text = result['description'];
      });

      await _mapController.addMarker(
        placeDetails[0],
        markerIcon: MarkerIcon(
          icon: Icon(Icons.location_on, color: Colors.red, size: 40),
        ),
      );

      if (_startLocation != null && _destinationLocation != null) {
        await _drawRoadBetweenPoints();
      }
    } catch (e) {
      print('Error selecting search result: $e');
    }
  }
  Future<dynamic> _setplaceDetails() async {
    // Simulate a delay to mimic an asynchronous operation
    await Future.delayed(const Duration(seconds: 1));

    // Return the second element of placeDetails if available
    if (placeDetails != null && placeDetails.length > 1) {
      return placeDetails[1];
    }

    // Return null if placeDetails is not ready or invalid
    return null;
  }

  Future<void> _drawRoadBetweenPoints() async {
    try {

      await _mapController.drawRoad(
        _startLocation!,
        _destinationLocation!,
        roadType: RoadType.car,
        roadOption: const RoadOption(
          roadWidth: 5.0,
          roadColor: Colors.blueAccent,
          roadBorderColor: Colors.black,
          roadBorderWidth: 1.5,
          zoomInto: true,
          isDotted: false,
        ),
      );
    } catch (e) {
      print('Error drawing road between points: $e');
    }
  }

  Future<void> _centerOnCurrentLocation() async {
    Position? position = await Geolocator.getLastKnownPosition();

    if (position != null) {
      final newLocation = GeoPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      setState(() {
        _startLocation = newLocation;
      });

      await _mapController.moveTo(newLocation, animate: true);
      await _mapController.setZoom(zoomLevel: 15);
      await _mapController.rotateMapCamera(0);
    } else {
      print(
          "No last known position available. Trying to fetch current location.");

      position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);

      final newLocation = GeoPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      setState(() {
        _startLocation = newLocation;
      });

      await _mapController.moveTo(newLocation, animate: true);
      await _mapController.setZoom(zoomLevel: 15);
      await _mapController.rotateMapCamera(0);
    }
  }
  void _checkAndShowBottomSheet(BuildContext context) {
    // Show the bottom sheet
    showBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return FutureBuilder<dynamic>(
          future: _setplaceDetails(), // Method to fetch place details
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Pass null to show loading state
              return DistanceBottomSheet(placeDetails: null);
            } else {
              final fetchedPlaceDetails = snapshot.data;
              if (fetchedPlaceDetails is Map<String, dynamic>) {
                return DistanceBottomSheet(placeDetails: fetchedPlaceDetails);
              } else {
                return const SizedBox(
                  height: 200,
                  child: Center(child: Text('Invalid place details.')),
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
          SearchInput(
            startController: _startController,
            destinationController: _destinationController,
            fetchSearchResultsDebounced: _fetchSearchResultsDebounced,
            searchResults: _searchResults,
            selectSearchResult: _selectSearchResult,
            checkAndShowBottomSheet: _checkAndShowBottomSheet,
          ),

          // Location Button Widget
          Positioned(
            bottom: 30,
            right: 16,
            child: LocationButton(onPressed: () => _centerOnCurrentLocation()), // Use LocationButton
          ),

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
