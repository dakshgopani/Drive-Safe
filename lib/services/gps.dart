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
    bool permissionGranted = await requestPermission();
    if (!permissionGranted) throw 'Location permission denied';

    positionStream = Geolocator.getPositionStream().listen(callback) as StreamSubscription<Position>?;
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
          distanceFilter: 10, // Only update if moved by at least 10 meters
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
