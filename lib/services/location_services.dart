import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Import your GeoPoint model
import '../services//gps.dart'; // Import GPS class
import 'dart:async';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';


class LocationService {
  static GPS gps = GPS();

  // Initialize the location and return the GeoPoint (one-time location retrieval)
  static Future<GeoPoint?> initializeLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Prompt user to enable location services
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are disabled. Please enable them.'),
        ),
      );
      return null;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission denied, show a message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied.'),
          ),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permissions are permanently denied.'),
        ),
      );
      return null;
    }

    // Get the current location using GPS class
    try {


      // If no last known position is available, get the current position
      Position? position = await gps.getCurrentPosition();
      print('Accuracy: ${position?.accuracy} meters');
      if (position == null) {
        return null; // No location available
      }
      print("Location:$position");
      final newLocation = GeoPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return newLocation;
    } catch (e) {
      print("Error initializing location: $e");
      return null;
    }
  }

  // Start location tracking (real-time location stream)
  static Future<void> startTrackingLocation(Function(GeoPoint) onLocationUpdated) async {
    try {
      await gps.startPositionStream((position) {
        final geoPoint = GeoPoint(latitude: position.latitude, longitude: position.longitude);
        onLocationUpdated(geoPoint); // Provide the updated location
      });
    } catch (e) {
      print("Error starting location stream: $e");
    }
  }

  // Stop location tracking
  static Future<void> stopTrackingLocation() async {
    await gps.stopPositionStream();
  }
}