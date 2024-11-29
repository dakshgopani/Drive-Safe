import 'package:flutter/material.dart';
import '../../models/feedback.dart';
import '../../services/firebase_service.dart';
import '../../utils/validators.dart';

class CreateFeedbackScreen extends StatefulWidget {
  const CreateFeedbackScreen({Key? key}) : super(key: key);

  @override
  _CreateFeedbackScreenState createState() => _CreateFeedbackScreenState();
}

class _CreateFeedbackScreenState extends State<CreateFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();
  
  String _receiverId = '';
  String _content = '';
  String _category = 'safety';
  int _rating = 3;

  final List<String> _categories = [
    'safety',
    'eco-driving',
    'maintenance',
    'general'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Feedback'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Recipient ID',
                hintText: 'Enter the recipient\'s user ID',
              ),
              validator: Validators.required,
              onSaved: (value) => _receiverId = value ?? '',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _category = value ?? 'safety');
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Feedback',
                hintText: 'Enter your feedback',
              ),
              maxLines: 5,
              validator: Validators.required,
              onSaved: (value) => _content = value ?? '',
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Rating:'),
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        Icons.star,
                        color: index < _rating ? Colors.amber : Colors.grey[300],
                      ),
                      onPressed: () {
                        setState(() => _rating = index + 1);
                      },
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitFeedback,
        child: const Icon(Icons.send),
      ),
    );
  }

  void _submitFeedback() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final feedback = DrivingFeedback(
        id: '',  // Will be set by Firestore
        senderId: FirebaseService().currentUserId ?? '',
        receiverId: _receiverId,
        content: _content,
        createdAt: DateTime.now(),
        category: _category,
        rating: _rating,
        isRead: false,
      );

      try {
        await _firebaseService.createFeedback(feedback);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}