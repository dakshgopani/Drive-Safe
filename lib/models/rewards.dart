import 'package:cloud_firestore/cloud_firestore.dart';

class Reward {
  final String id;
  final String title;
  final String description;
  final int pointsRequired;
  final String imageUrl;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.imageUrl,
  });

  factory Reward.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Reward(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      pointsRequired: data['pointsRequired'],
      imageUrl: data['imageUrl'],
    );
  }
}