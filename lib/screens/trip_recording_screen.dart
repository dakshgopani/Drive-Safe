import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'trip_dashboard_screen.dart';

class TripTrackingScreen extends StatefulWidget {
  @override
  _TripTrackingScreenState createState() => _TripTrackingScreenState();
}

class _TripTrackingScreenState extends State<TripTrackingScreen> {
  bool _tripCompleted = false;
  bool showDashboard = false;
  Duration tripDuration = Duration.zero;
  double avgSpeed = 0.0;
  double totalDistanceTraveled = 0.0;

  // Update dashboard when trip completes
  void updateDashboard(Duration duration, double speed, double distance) {
    setState(() {
      tripDuration = duration;
      avgSpeed = speed;
      totalDistanceTraveled = distance;
      showDashboard = true; // Show dashboard overlay
    });
  }

  // **Function to track user's location**
  void startLocationTracking() {
    const double thresholdDistance = 10.0; // Trip completes within 10 meters

    double totalDistanceTraveled = 0.0;
    double totalSpeed = 0.0;
    int speedCount = 0;
    DateTime? tripStartTime = DateTime.now();
    Position? previousPosition;

    // Start tracking
    Geolocator.getPositionStream(locationSettings: LocationSettings(accuracy: LocationAccuracy.high))
        .listen((Position position) {
      double speed = position.speed * 3.6; // Convert to km/h
      totalSpeed += speed;
      speedCount++;

      // Calculate distance traveled
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

      // Check if trip is completed
      if (totalDistanceTraveled >= thresholdDistance && !_tripCompleted) {
        _tripCompleted = true;
        Duration tripDuration = DateTime.now().difference(tripStartTime!);
        double avgSpeed = speedCount > 0 ? totalSpeed / speedCount : 0;

        // Show trip completed popup
        _showTripCompletedPopup();

        // Update floating dashboard after 3 seconds
        Future.delayed(Duration(seconds: 3), () {
          if (mounted) {
            updateDashboard(tripDuration, avgSpeed, totalDistanceTraveled);
          }
        });
      }
    });
  }

  // 🎉 Show trip completion pop-up
  void _showTripCompletedPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("🎉 Trip Completed!"),
          content: Text("You have successfully reached your destination."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close popup
              },
              child: Text("Awesome!"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🌍 Map and Navigation UI
        Positioned.fill(
          child: Container(
            color: Colors.blueAccent.shade100,
            child: Center(child: Text("🗺️ Map & Navigation UI")),
          ),
        ),

        // 📊 Floating Dashboard Overlay
        if (showDashboard)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("📌 Trip Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("🕒 Duration: ${tripDuration.inMinutes} min ${tripDuration.inSeconds % 60} sec"),
                  Text("🚀 Avg Speed: ${avgSpeed.toStringAsFixed(2)} km/h"),
                  Text("🛤️ Distance: ${totalDistanceTraveled.toStringAsFixed(2)} meters"),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TripDashboardScreen(tripDuration, avgSpeed, totalDistanceTraveled)),
                      );
                    },
                    child: Text("View Full Details"),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
