import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String displayName;
  final String photoUrl;
  final double safetyScore;
  final double ecoScore;
  final int totalDistance;
  final List<String> badges;
  final String region;
  final DateTime joinDate;

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.photoUrl,
    required this.safetyScore,
    required this.ecoScore,
    required this.totalDistance,
    required this.badges,
    required this.region,
    required this.joinDate,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      safetyScore: (data['safetyScore'] ?? 0.0).toDouble(),
      ecoScore: (data['ecoScore'] ?? 0.0).toDouble(),
      totalDistance: data['totalDistance'] ?? 0,
      badges: List<String>.from(data['badges'] ?? []),
      region: data['region'] ?? '',
      joinDate: (data['joinDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'photoUrl': photoUrl,
      'safetyScore': safetyScore,
      'ecoScore': ecoScore,
      'totalDistance': totalDistance,
      'badges': badges,
      'region': region,
      'joinDate': Timestamp.fromDate(joinDate),
    };
  }
}