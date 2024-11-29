import 'package:cloud_firestore/cloud_firestore.dart';

class ForumPost {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String authorPhotoUrl;
  final DateTime createdAt;
  final int likes;
  final List<String> likedBy;
  final int commentCount;

  ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorPhotoUrl,
    required this.createdAt,
    required this.likes,
    required this.likedBy,
    required this.commentCount,
  });

  // Convert Firestore document to ForumPost object
  factory ForumPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ForumPost(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      commentCount: data['commentCount'] ?? 0,
    );
  }

  // Convert ForumPost object to Firestore-compatible format
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'likedBy': likedBy,
      'commentCount': commentCount,
    };
  }
}
