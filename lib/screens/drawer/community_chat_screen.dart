import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;

class DriverSafetyChatScreen extends StatefulWidget {
  @override
  _DriverSafetyChatScreenState createState() => _DriverSafetyChatScreenState();
}

class _DriverSafetyChatScreenState extends State<DriverSafetyChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  User? _currentUser;
  List<QueryDocumentSnapshot> _messages = [];
  bool _isEmergency = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadMessages();
  }

  void _getCurrentUser() {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser;
    });
  }

  void _loadMessages() {
    _firestore
        .collection('driver_chat')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _messages = snapshot.docs;
      });
      _scrollToBottom();
    });
  }

  Future<void> _sendMessage(String message, {File? file, bool isEmergency = false}) async {
    if (message.trim().isEmpty && file == null) return;

    try {
      String? base64Image;
      String? fileName;
      String? fileType;

      if (file != null) {
        fileName = path.basename(file.path);
        fileType = _getFileType(file);
        if (fileType == 'image') {
          List<int> imageBytes = await file.readAsBytes();
          base64Image = base64Encode(imageBytes);
        }
      }

      Position? position;
      if (isEmergency) {
        position = await Geolocator.getCurrentPosition();
      }

      await _firestore.collection('driver_chat').add({
        'text': message,
        'sender': _currentUser?.displayName ?? _currentUser?.email ?? 'Anonymous',
        'timestamp': FieldValue.serverTimestamp(),
        'base64Image': base64Image,
        'fileName': fileName,
        'fileType': fileType,
        'isEmergency': isEmergency,
        'location': position != null 
            ? GeoPoint(position.latitude, position.longitude)
            : null,
      });

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message')),
      );
    }
  }

  String _getFileType(File file) {
    String extension = path.extension(file.path).toLowerCase();
    if (['.jpg', '.jpeg', '.png', '.gif'].contains(extension)) {
      return 'image';
    } else {
      return 'file';
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _shareIncident() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      String mapUrl = 'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
      String locationMessage = 'Road incident reported at: $mapUrl';
      _sendMessage(locationMessage, isEmergency: true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share incident location'))
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        File file = File(image.path);
        await _sendMessage('', file: file);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image'))
      );
    }
  }

  Widget _buildMessageContent(Map<String, dynamic> messageData) {
    final messageText = messageData['text'] as String;
    final base64Image = messageData['base64Image'] as String?;
    final isEmergency = messageData['isEmergency'] as bool? ?? false;
    
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isEmergency ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.0),
        border: isEmergency ? Border.all(color: Colors.red, width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEmergency)
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text('INCIDENT REPORT',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          if (isEmergency) SizedBox(height: 8),
          if (base64Image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                base64Decode(base64Image),
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          if (base64Image != null) SizedBox(height: 8),
          _buildClickableText(messageText, isEmergency),
        ],
      ),
    );
  }

  Widget _buildClickableText(String text, bool isEmergency) {
    if (text.contains('http')) {
      final List<String> parts = text.split(': ');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${parts[0]}: ',
            style: TextStyle(fontSize: 16.0),
          ),
          InkWell(
            onTap: () async {
              final Uri uri = Uri.parse(parts[1].trim());
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Text(
              parts[1],
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      );
    }
    return Text(text, style: TextStyle(fontSize: 16.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Safety Community'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.warning),
            color: _isEmergency ? Colors.red : Colors.white,
            onPressed: () => setState(() => _isEmergency = !_isEmergency),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isEmergency)
            Container(
              color: Colors.red,
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Emergency Mode Active',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index].data() as Map<String, dynamic>;
                final sender = message['sender'] as String;
                final timestamp = message['timestamp'] as Timestamp?;

                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.blueAccent, size: 16),
                          SizedBox(width: 4),
                          Text(sender, 
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            )
                          ),
                          Spacer(),
                          Text(
                            timestamp != null
                                ? DateFormat('MMM d, h:mm a').format(timestamp.toDate())
                                : '',
                            style: TextStyle(fontSize: 12.0, color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      _buildMessageContent(message),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (_isEmergency)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 8),
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.share_location),
                      label: Text('Share Incident Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _shareIncident,
                    ),
                  ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.camera_alt, color: Colors.blueAccent),
                      onPressed: _pickImage,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: _isEmergency 
                              ? 'Describe the incident...'
                              : 'Share safety tips...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: _isEmergency ? Colors.red : Colors.blueAccent,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.blueAccent),
                      onPressed: () => _sendMessage(
                        _messageController.text,
                        isEmergency: _isEmergency,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // ... rest of the build method remains the same ...
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}