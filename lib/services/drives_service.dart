import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriveService {
  final DateTime? tripStartTime;
  final double? totalDistanceTraveled;
  final double? totalSpeed;
  final int? speedCount;
  final Map<String, dynamic>? startLocation;
  final Map<String, dynamic>? destination;
  final Duration? tripDuration;

  DriveService({
    this.tripStartTime,
    this.totalDistanceTraveled,
    this.totalSpeed,
    this.speedCount,
    this.startLocation,
    this.destination,
    this.tripDuration,
    
  });

  Future<String> saveTripDataToFirestore() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      CollectionReference tripsCollection = userRef.collection('drives');

      Map<String, dynamic> tripData = {
        if (tripStartTime != null) "startTime": tripStartTime,
        "endTime": DateTime.now(),
        if (totalDistanceTraveled != null) "totalDistance": totalDistanceTraveled!.toStringAsFixed(2),
        if (speedCount != null && totalSpeed != null && speedCount! > 0)
          "averageSpeed": (totalSpeed! / speedCount!).toStringAsFixed(2),
        if (tripDuration != null) "tripDuration": tripDuration!.inMinutes,
        if (startLocation != null) "startLocation": startLocation,
        if (destination != null) "destination": destination,
        "timestamp": FieldValue.serverTimestamp(),
      };

      DocumentReference tripRef = await tripsCollection.add(tripData);
      print("✅ Trip data saved! Trip ID: ${tripRef.id}");
      return tripRef.id;
    } catch (e) {
      print("❌ Error saving trip data: $e");
      return '';
    }
  }
}
