import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProfile extends ChangeNotifier {
  final String uid;
  String displayName;
  String photoUrl;
  double safetyScore;
  double ecoScore;
  int totalDistance;
  List<String> badges;
  String region;
  DateTime joinDate;
  int points;
  List<String> unlockedRewards;

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
    required this.points,
    required this.unlockedRewards,
  });

  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? photoUrl,
    double? safetyScore,
    double? ecoScore,
    int? totalDistance,
    List<String>? badges,
    String? region,
    DateTime? joinDate,
    int? points,
    List<String>? unlockedRewards,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      safetyScore: safetyScore ?? this.safetyScore,
      ecoScore: ecoScore ?? this.ecoScore,
      totalDistance: totalDistance ?? this.totalDistance,
      badges: badges ?? this.badges,
      region: region ?? this.region,
      joinDate: joinDate ?? this.joinDate,
      points: points ?? this.points,
      unlockedRewards: unlockedRewards ?? this.unlockedRewards,
    );
  }


  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'] ?? 'https://i.pravatar.cc/150',
      safetyScore: (data['safetyScore'] ?? 0.0).toDouble(),
      ecoScore: (data['ecoScore'] ?? 0.0).toDouble(),
      totalDistance: data['totalDistance'] ?? 0,
      badges: List<String>.from(data['badges'] ?? []),
      region: data['region'] ?? '',
      joinDate: (data['joinDate'] as Timestamp).toDate(),
      points: data['points'],
      unlockedRewards: List<String>.from(data['unlockedRewards'] ?? []),
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
      'points': points,
      'unlockedRewards': unlockedRewards,
    };
  }

  void update(UserProfile newProfile) {
    points = newProfile.points;
    displayName = newProfile.displayName;
    photoUrl = newProfile.photoUrl;
    safetyScore = newProfile.safetyScore;
    ecoScore = newProfile.ecoScore;
    totalDistance = newProfile.totalDistance;
    badges = newProfile.badges;
    region = newProfile.region;
    joinDate = newProfile.joinDate;
    unlockedRewards = newProfile.unlockedRewards;

    // Update other properties as needed
  }
}