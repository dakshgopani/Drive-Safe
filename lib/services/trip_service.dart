import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripService {
  final DateTime tripStartTime;
  final double totalDistanceTraveled;
  final double totalSpeed;
  final int speedCount;
  final Map<String, dynamic> startLocation;
  final Map<String, dynamic> destination;

  TripService({
    required this.tripStartTime,
    required this.totalDistanceTraveled,
    required this.totalSpeed,
    required this.speedCount,
    required this.startLocation,
    required this.destination,
  });

  /// ✅ Save trip and return `tripId`
  Future<String> saveTripDataToFirestore() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid; // Get current user ID

      // Reference to the Firestore users collection
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      CollectionReference tripsCollection = userRef.collection('trips');

      // Prepare trip data
      Map<String, dynamic> tripData = {
        "startTime": tripStartTime,
        "endTime": DateTime.now(),
        "totalDistance": totalDistanceTraveled.toStringAsFixed(2),
        "averageSpeed": speedCount > 0 ? (totalSpeed / speedCount).toStringAsFixed(2) : "0",
        "tripDuration": DateTime.now().difference(tripStartTime).inMinutes,
        "startLocation": startLocation,
        "destination": destination,
        "timestamp": FieldValue.serverTimestamp(),
      };

      // Save the trip data under the user's collection and get the document ID
      DocumentReference tripRef = await tripsCollection.add(tripData);

      print("✅ Trip data saved! Trip ID: ${tripRef.id}");
      return tripRef.id; // ✅ Return tripId
    } catch (e) {
      print("❌ Error saving trip data: $e");
      return ''; // Return empty if failed
    }
  }
}
