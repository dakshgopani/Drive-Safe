import 'dart:async';
import 'package:geolocator/geolocator.dart';

class GPS {
  StreamSubscription<Position>? positionStream;

  // Request location permission
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  // Start location stream
  Future<void> startPositionStream(Function(Position) callback) async {
    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation, // Use highest accuracy
      distanceFilter: 5, // Minimum distance (in meters) to trigger updates// Optional: Time limit for better fixes
    );

    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      if (position.accuracy <= 10) { // Filter for high-accuracy locations
        callback(position);
      } else {
        print('Skipping low accuracy location: ${position.accuracy}');
      }
    });
  }

  // Stop location stream
  Future<void> stopPositionStream() async {
    await positionStream?.cancel();
  }

  // Get the current position (one-time)
  Future<Position?> getCurrentPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(

        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 10,
          // Only update if moved by at least 10 meters
        ),
      );
      return position;
    } catch (e) {
      throw "Error fetching location: $e";
    }
  }

  // Get last known position (one-time)
  Future<Position?> getLastKnownPosition() async {
    return await Geolocator.getLastKnownPosition();
  }
}