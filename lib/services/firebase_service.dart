import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class FirebaseService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getter to access the current user's ID
  String get currentUserId => _auth.currentUser!.uid;


  // User Profile Methods
  Stream<List<UserProfile>> getLeaderboard({
    required String metric,
    String? region,
  }) {
    try {
      Query query = _firestore.collection('users')
          .orderBy(metric, descending: true)
          .limit(100);

      if (region != null && region.isNotEmpty) {
        query = query.where('region', isEqualTo: region);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => UserProfile.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print('Error in getLeaderboard: $e');
      return Stream.error('Failed to load leaderboard');
    }
  }

  // User Profile Methods
  Future<UserProfile> getUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return UserProfile.fromFirestore(userDoc);
      }
    }
    return UserProfile(
      uid: '',
      displayName: '',
      photoUrl: '',
      safetyScore: 0,
      ecoScore: 0,
      totalDistance: 0,
      badges: [],
      region: '',
      joinDate: DateTime.now(),
      points: 0,
      unlockedRewards: [],
    );
  }

  Future<void> updateUserProfile(UserProfile updatedProfile) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update(updatedProfile.toJson());
    }
  }
}