import 'package:cloud_firestore/cloud_firestore.dart';

class DrivingFeedback {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final String category;
  final int rating;
  final bool isRead;
  final String? response;

  DrivingFeedback({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    required this.category,
    required this.rating,
    required this.isRead,
    this.response,
  });

  factory DrivingFeedback.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DrivingFeedback(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      category: data['category'] ?? '',
      rating: data['rating'] ?? 0,
      isRead: data['isRead'] ?? false,
      response: data['response'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'category': category,
      'rating': rating,
      'isRead': isRead,
      'response': response,
    };
  }
}