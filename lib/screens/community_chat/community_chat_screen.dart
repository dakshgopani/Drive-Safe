import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class CommunityChatScreen extends StatefulWidget {
  @override
  _CommunityChatScreenState createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _addUserToCommunity();
  }

  Future<void> _addUserToCommunity() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('community_users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        await _firestore.collection('community_users').doc(currentUser.uid).set({
          'uid': currentUser.uid,
          'name': currentUser.displayName ?? currentUser.email ?? 'Anonymous',
          'email': currentUser.email,
          'photoUrl': currentUser.photoURL ?? '',
          'joinedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error adding user to community: $e');
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      String sender = currentUser?.displayName ?? currentUser?.email ?? 'Anonymous';

      await _firestore.collection('group_chat').add({
        'text': message,
        'sender': sender,
        'timestamp': FieldValue.serverTimestamp(),
        'photoUrl': currentUser?.photoURL,
        'likes': 0, // Initialize likes count
      });

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

Future<void> _shareLocation() async {
  try {
    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are required'))
        );
        return;
      }
    }

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enable location services'))
      );
      return;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );

    // Send location as a Google Maps link
    String locationMessage = 'My Location: https://www.google.com/maps?q=${position.latitude},${position.longitude}';
    _sendMessage(locationMessage);
  } catch (e) {
    print('Error sharing location: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to get location'))
    );
  }
} 
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Chat'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('group_chat')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet. Start the conversation!',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index];
                    final messageText = messageData['text'] ?? '';
                    final sender = messageData['sender'] ?? 'Anonymous';
                    final timestamp = messageData['timestamp']?.toDate();
                    final photoUrl = messageData['photoUrl'] ?? null;
                    final likes = messageData['likes'] ?? 0;

                    final formattedTime = timestamp != null
                        ? DateFormat('hh:mm a').format(timestamp)
                        : '';
                    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
                    final isCurrentUser = sender == currentUserEmail;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Align(
                        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            if (!isCurrentUser && photoUrl != null)
                              CircleAvatar(backgroundImage: NetworkImage(photoUrl), radius: 16.0),
                            if (!isCurrentUser) SizedBox(width: 8.0),
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: isCurrentUser ? Colors.teal[100] : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(16.0),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black26, blurRadius: 4.0, offset: Offset(2, 2)),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(sender, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.teal[800])),
                                    SizedBox(height: 4.0),
                                    Text(messageText, style: TextStyle(fontSize: 16.0)),
                                    if (formattedTime.isNotEmpty) SizedBox(height: 4.0),
                                    if (formattedTime.isNotEmpty)
                                      Text(formattedTime, style: TextStyle(fontSize: 12.0, color: Colors.grey[600])),
                                    Row(
                                      mainAxisAlignment:
                                          isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.thumb_up),
                                          onPressed: () async {
                                            await _firestore.collection('group_chat').doc(messageData.id).update({
                                              'likes': likes + 1,
                                            });
                                          },
                                        ),
                                        Text('$likes'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border:
                          OutlineInputBorder(borderRadius:
                          BorderRadius.circular(30.0)),
                      filled:
                          true,
                      fillColor:
                          Colors.grey[200],
                      contentPadding:
                          EdgeInsets.symmetric(horizontal:
                          20.0),
                    ),
                  ),
                ),
                SizedBox(width:
                8.0),
                IconButton(
                  iconSize:
                      30,
                  icon:
                      Icon(Icons.location_on, color:
                          Colors.teal),
                  onPressed:
                      () => _shareLocation(),
                ),
                ElevatedButton(
                  onPressed:
                      () => _sendMessage(_messageController.text),
                  style:
                      ElevatedButton.styleFrom(shape:
                          CircleBorder(), padding:
                          EdgeInsets.all(12.0), backgroundColor:
                          Colors.teal), // Button color
                  child:
                      Icon(Icons.send,color:
                          Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
