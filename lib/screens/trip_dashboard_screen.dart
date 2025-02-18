import 'package:flutter/material.dart';

class TripDashboardScreen extends StatelessWidget {
  final Duration tripDuration;
  final double avgSpeed;
  final double totalDistanceTraveled;

  TripDashboardScreen(this.tripDuration, this.avgSpeed, this.totalDistanceTraveled);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("📊 Trip Dashboard")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🚗 Trip Summary", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("🕒 Duration: ${tripDuration.inMinutes} min ${tripDuration.inSeconds % 60} sec"),
            Text("🚀 Avg Speed: ${avgSpeed.toStringAsFixed(2)} km/h"),
            Text("🛤️ Distance: ${totalDistanceTraveled.toStringAsFixed(2)} meters"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to tracking screen
              },
              child: Text("Back to Navigation"),
            ),
          ],
        ),
      ),
    );
  }
}
