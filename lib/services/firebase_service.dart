import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/rewards.dart';
import '../models/user_profile.dart';
import '../models/forum_post.dart';
import '../models/story.dart';
import '../models/feedback.dart';

class FirebaseService {
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestores = FirebaseFirestore.instance;


  // Method to create a new forum post
  Future<void> createForumPost(ForumPost post) async {
    try {
      await _firestore.collection('forum_posts').add({
        'title': post.title,
        'content': post.content,
        'authorId': post.authorId,
        'authorName': post.authorName,
        'authorPhotoUrl': post.authorPhotoUrl,
        'createdAt': Timestamp.fromDate(post.createdAt),
        'likes': post.likes,
        'likedBy': post.likedBy,
        'commentCount': post.commentCount,
      });
    } catch (e) {
      print('Error creating forum post: $e');
      throw Exception('Error creating post');
    }
  }

  // Getter to access the current user's ID
  String get currentUserId => _auth.currentUser?.uid ?? dummyUserId;


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

  // Forum Methods
  Stream<List<ForumPost>> getForumPosts() {
    return _firestore
        .collection('forum_posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ForumPost.fromFirestore(doc))
              .toList();
        });
  }

  // Future<void> createForumPost(ForumPost post) {
  //   return _firestore.collection('forum_posts').add(post.toJson());
  // }

  Future<void> updateForumPost(ForumPost post) {
    return _firestore
        .collection('forum_posts')
        .doc(post.id)
        .update(post.toJson());
  }

  // Stories Methods
  Stream<List<Story>> getStories() {
    return _firestore
        .collection('stories')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Story.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> createStory(Story story) {
    return _firestore.collection('stories').add(story.toJson());
  }

  // Feedback Methods
  String dummyUserId = 'user3'; // Simulating a dummy user ID for testing purposes
  Stream<List<DrivingFeedback>> getReceivedFeedback() {
    final currentUserId = _auth.currentUser?.uid ?? dummyUserId; // Fallback to dummy user ID if null
    print("Current User ID: $currentUserId");
    //if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('feedback')
        .where('receiverId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => DrivingFeedback.fromFirestore(doc))
              .toList();
        });
  }

  
  Stream<List<DrivingFeedback>> getSentFeedback() {
    final currentUserId = _auth.currentUser?.uid ?? dummyUserId;
    // if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('feedback')
        .where('senderId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => DrivingFeedback.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> createFeedback(DrivingFeedback feedback) {
    return _firestore.collection('feedback').add(feedback.toJson());
  }

  Future<void> updateFeedback(DrivingFeedback feedback) {
    return _firestore
        .collection('feedback')
        .doc(feedback.id)
        .update(feedback.toJson());
  }

  

  /// Fetch rewards in real-time using a Stream
  static Stream<List<Map<String, dynamic>>> fetchRewardsStream() {
    return _firestores.collection('rewards').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "id": doc.id, // Document ID
          "title": data["title"] ?? "",
          "description": data["description"] ?? "",
          "imageUrl": data["imageUrl"] ?? "",
          "pointsRequired": data["pointsRequired"] ?? 0,
        };
      }).toList();
    });
  }

  /// Fetch rewards once (non-real-time)
  static Future<List<Map<String, dynamic>>> fetchRewardsOnce() async {
    try {
      final snapshot = await _firestores.collection('rewards').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "id": doc.id, // Document ID
          "title": data["title"] ?? "",
          "description": data["description"] ?? "",
          "imageUrl": data["imageUrl"] ?? "",
          "pointsRequired": data["pointsRequired"] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('Error fetching rewards: $e');
      return [];
    }
  }

}
