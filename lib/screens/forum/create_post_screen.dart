import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/forum_post.dart';
import '../../services/firebase_service.dart';
import '../../utils/validators.dart';
import '../../utils/firebase_error_handler.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();
  bool _isSubmitting = false;

  String _title = '';
  String _content = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        backgroundColor: Colors.teal.shade600, // Darker teal for app bar
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Neutral background color
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Title input
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter post title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.teal),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200], // Light grey background
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: Validators.required,
                  onSaved: (value) => _title = value ?? '',
                  maxLength: 100,
                ),
                const SizedBox(height: 16),

                // Content input
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Content',
                    hintText: 'Share your thoughts...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.teal),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200], // Light grey background
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: Validators.required,
                  onSaved: (value) => _content = value ?? '',
                  maxLines: 10,
                  maxLength: 1000,
                ),
                const SizedBox(height: 16),

                // Add post button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitPost,
                  child:
                      _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Post'),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.teal.shade400, // Lighter teal for button
                    shape:
                        RoundedRectangleBorder(borderRadius:
                            BorderRadius.circular(12)),
                  ).copyWith(
                    backgroundColor:
                        MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.tealAccent; // Accent color on press
                      }
                      return Colors.teal.shade400; // Default button color
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitPost() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      _formKey.currentState?.save();

      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) throw Exception('User not logged in');

        final post = ForumPost(
          id: '',
          title: _title,
          content: _content,
          authorId: currentUser.uid,
          authorName:
              currentUser.displayName ?? 'Anonymous',
          authorPhotoUrl:
              currentUser.photoURL ?? '',
          createdAt:
              DateTime.now(),
          likes:
              0,
          likedBy:
              [],
          commentCount:
              0,
        );

        await _firebaseService.createForumPost(post);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content:
              Text('Error creating post. Please try again later.')),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }
}