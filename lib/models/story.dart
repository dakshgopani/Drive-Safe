import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String authorPhotoUrl;
  final DateTime createdAt;
  final List<String> images;
  final int likes;
  final List<String> likedBy;
  final String category;
  final List<String> tags;

  Story({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorPhotoUrl,
    required this.createdAt,
    required this.images,
    required this.likes,
    required this.likedBy,
    required this.category,
    required this.tags,
  });

  factory Story.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Story(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      images: List<String>.from(data['images'] ?? []),
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      category: data['category'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'images': images,
      'likes': likes,
      'likedBy': likedBy,
      'category': category,
      'tags': tags,
    };
  }
}