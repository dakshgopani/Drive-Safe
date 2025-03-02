import 'package:algorithm_avengers_ves_final/screens/convoyMode/convoy_mode_map.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:animate_do/animate_do.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String userName;
  final String roomId;
  final int maxAllowedUsers; // Add maxAllowedUsers as a parameter

  const WaitingRoomScreen({
    Key? key,
    required this.userName,
    required this.roomId,
    required this.maxAllowedUsers, // Make it required
  }) : super(key: key);

  @override
  _WaitingRoomScreenState createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;
  bool isJoined = false;

  @override
  void initState() {
    super.initState();
    _joinRoom();
  }

  Future<void> _joinRoom() async {
    final docRef = _firestore.collection('rooms').doc(widget.roomId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      final List<String> currentUsers = List<String>.from(data?['users'] ?? []);

      // Check if room is already full
      if (currentUsers.length >= widget.maxAllowedUsers) {
        if (mounted) {
          _showRoomFullDialog();
        }
        return;
      }

      // Allow user to join if room is not full
      if (!currentUsers.contains(widget.userName)) {
        currentUsers.add(widget.userName);
        await docRef.update({'users': currentUsers});
        setState(() {
          isJoined = true;
        });
      }
    } else {
      // Create a new room if it doesn't exist
      await docRef.set({
        'users': [widget.userName],
        'maxAllowedUsers': widget.maxAllowedUsers, // Store max users in Firestore
      });
      setState(() {
        isJoined = true;
      });
    }
  }

// Show alert dialog when room is full
  void _showRoomFullDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Room Full"),
        content: const Text("The room is already full. Please try another room."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _leaveRoom();
    super.dispose();
  }

  Future<void> _leaveRoom() async {
    final docRef = _firestore.collection('rooms').doc(widget.roomId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      List<String> currentUsers = List<String>.from(data?['users'] ?? []);
      currentUsers.remove(widget.userName);
      await docRef.update({'users': currentUsers});
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: Text(
                "Waiting Room (${widget.roomId})",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            ),
            Expanded(
              child: StreamBuilder<firestore.DocumentSnapshot>(
                stream: _firestore.collection('rooms').doc(widget.roomId).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data?.data() as Map<String, dynamic>?;
                  List<String> users = List<String>.from(data?['users'] ?? []);

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        FadeInDown(
                          duration: const Duration(milliseconds: 600),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white.withOpacity(0.8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.people,
                                    color: Colors.blueAccent, size: 26),
                                const SizedBox(width: 10),
                                Text(
                                  "Users in the Room: ${users.length}/${widget.maxAllowedUsers}", // Use widget.maxAllowedUsers
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              return FadeInLeft(
                                duration: Duration(milliseconds: 500 + (index * 100)),
                                child: Card(
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  color: Colors.white,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.blueAccent.shade700,
                                      child: Text(
                                        users[index][0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      users[index],
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    trailing: const Icon(Icons.verified,
                                        color: Colors.green),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.exit_to_app, color: Colors.white),
                            label: const Text("Leave Room",
                                style: TextStyle(fontSize: 18, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConvoyModeMap(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.directions_car, color: Colors.white),
                            label: const Text(
                              "Start Convoy",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}