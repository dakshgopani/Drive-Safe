// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
// import 'package:geolocator/geolocator.dart';
// import '../services/location_services.dart';
//
// import '../widgets/map_view.dart';
//
//
// class LocationScreen extends StatefulWidget {
//   const LocationScreen({Key? key}) : super(key: key);
//
//   @override
//   State<LocationScreen> createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<LocationScreen> {
//   late MapController _mapController;
//   final TextEditingController _startController = TextEditingController();
//   final TextEditingController _destinationController = TextEditingController();
//   List<dynamic> placeDetails = [];
//   GeoPoint? _startLocation;
//   final LocationSettings locationSettings = const LocationSettings(
//     accuracy: LocationAccuracy.bestForNavigation,
//     distanceFilter: 100,
//   );
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   List<dynamic> routes = [];
//   bool isNavigating = false;
//
//   int currentStepIndex = 1;
//
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeLocation();
//     _mapController = MapController(
//       initPosition: GeoPoint(latitude: 0, longitude: 0),
//     );
//   }
//
//   @override
//   void dispose() {
//     _startController.dispose();
//     _destinationController.dispose();
//     _mapController.dispose();
//     _stopLocationTracking();
//     super.dispose();
//   }
//
//   Future<void> _initializeLocation() async {
//     // Fetch the current location using the updated LocationService
//     GeoPoint? location = await LocationService.initializeLocation(context);
//
//     if (location != null) {
//       setState(() {
//         _startLocation = location;
//         _startController.text =
//             "Your location"; // Display text in the controller
//       });
//
//       await _mapController.addMarker(
//         _startLocation!,
//         markerIcon: MarkerIcon(
//           icon: Icon(Icons.location_on,
//               color: Colors.blueAccent,
//               size: 40), // Use a different icon for current location
//         ),
//       );
//       await _mapController.moveTo(location, animate: true);
//       await _mapController.setZoom(zoomLevel: 15);
//       _startLocationTracking();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Failed to fetch location.'),
//         ),
//       );
//     }
//   }
//
//   // Start tracking the location in real-time using LocationService
//   void _startLocationTracking() {
//     LocationService.startTrackingLocation((geoPoint) {
//       GeoPoint oldLocation = _startLocation as GeoPoint;
//       _mapController.changeLocationMarker(
//           oldLocation: oldLocation, newLocation: geoPoint, angle: 0);
//       setState(() {
//         _startLocation = geoPoint;
//       });
//     });
//   }
//
//   // Stop location tracking when no longer needed
//   void _stopLocationTracking() async {
//     await LocationService.stopTrackingLocation();
//   }
//
//   StreamSubscription<Position>? _positionStream;
//   //
//   // @override
//   // Widget build(BuildContext context) {
//   //   return GestureDetector(
//   //     onTap: () {
//   //       FocusManager.instance.primaryFocus?.unfocus();
//   //     },
//   //     behavior: HitTestBehavior.opaque,
//   //     child: Scaffold(
//   //       key: _scaffoldKey,
//   //       body: Stack(
//   //         children: [
//   //           // Map View Widget
//   //           MapView(mapController: _mapController),
//   //         ]
//   //       ),
//   //     ),
//   //   );
//   // }
// }
