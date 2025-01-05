import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/story.dart';
import '../../services/firebase_service.dart';
import '../../utils/validators.dart';
import '../../utils/firebase_error_handler.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  _CreateStoryScreenState createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();
  final _imagePicker = ImagePicker();
  bool _isSubmitting = false;

  String _title = '';
  String _content = '';
  String _category = 'experience';
  List<String> _tags = [];
  final List<XFile> _selectedImages = [];

  final List<String> _categories = [
    'experience',
    'tip',
    'achievement',
    'question'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Your Story'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter story title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.teal),
                    ),
                    filled: true,
                    fillColor: Colors.teal[50],
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: Validators.required,
                  onSaved: (value) => _title = value ?? '',
                  maxLength: 100,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.teal),
                    ),
                    filled: true,
                    fillColor: Colors.teal[50],
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _category = value ?? 'experience');
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Tags (comma separated)',
                    hintText: 'safety, tips, maintenance',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.teal),
                    ),
                    filled: true,
                    fillColor: Colors.teal[50],
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  onSaved: (value) {
                    _tags = value?.split(',')
                        .map((tag) => tag.trim().toLowerCase())
                        .where((tag) => tag.isNotEmpty)
                        .toList() ?? [];
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Story',
                    hintText: 'Share your driving story...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.teal),
                    ),
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: Colors.teal[50],
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: Validators.required,
                  onSaved: (value) => _content = value ?? '',
                  maxLines: 10,
                  maxLength: 2000,
                ),
                const SizedBox(height: 16),
                _buildImagePicker(),
                const SizedBox(height: 32),
                _buildAddStoryButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Photos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._selectedImages.map((image) => _buildImagePreview(image)),
            if (_selectedImages.length < 5)
              InkWell(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.teal, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.teal[50],
                  ),
                  child: const Icon(Icons.add_photo_alternate, size: 40, color: Colors.teal),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreview(XFile image) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: FileImage(File(image.path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () {
              setState(() {
                _selectedImages.remove(image);
              });
            },
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImages.add(image);
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    final List<String> imageUrls = [];
    final storage = FirebaseStorage.instance;

    for (final image in _selectedImages) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = storage.ref().child('stories/$fileName.jpg');
      
      final uploadTask = ref.putFile(File(image.path));
      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();
      
      imageUrls.add(url);
    }

    return imageUrls;
  }

  Widget _buildAddStoryButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitStory,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Add Story', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Future<void> _submitStory() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      _formKey.currentState?.save();

      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) throw Exception('User not logged in');

        List<String> imageUrls = [];
        if (_selectedImages.isNotEmpty) {
          imageUrls = await _uploadImages();
        }

        final story = Story(
          id: '', 
          title: _title,
          content: _content,
          authorId: currentUser.uid,
          authorName: currentUser.displayName ?? 'Anonymous',
          authorPhotoUrl: currentUser.photoURL ?? '',
          createdAt: DateTime.now(),
          images: imageUrls,
          likes: 0,
          likedBy: [],
          category: _category,
          tags: _tags,
        );

        await _firebaseService.createStory(story);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(FirebaseErrorHandler.getFirestoreErrorMessage(e)),
          ),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
