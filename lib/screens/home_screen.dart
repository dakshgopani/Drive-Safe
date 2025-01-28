import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './profile_screen.dart';
import './map_screen.dart'; // Import the Map screen
import '../widgets/custom_drawer.dart'; // Import the drawer file
import 'welcome_screen.dart'; // Import Welcome Screen

class HomeScreen extends StatefulWidget {
  final String userName;
  final String email;

  const HomeScreen({super.key, required this.userName, required this.email});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String uniqueId = "Fetching...";

  @override
  void initState() {
    super.initState();
    _fetchUniqueId();
  }

  Future<void> _fetchUniqueId() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            uniqueId = userDoc.id;
          });
        } else {
          setState(() {
            uniqueId = "Document not found!";
          });
        }
      } else {
        setState(() {
          uniqueId = "User not logged in!";
        });
      }
    } catch (e) {
      setState(() {
        uniqueId = "Error fetching UID: $e";
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing out: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: CustomDrawer( // Keep the drawer accessible
        userName: widget.userName,
        email: widget.email,
        onSignOut: _signOut,
      ),
      // appBar: AppBar(
      //   title: Text("Welcome, ${widget.userName}"),
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.logout),
      //       onPressed: _signOut,
      //     ),
      //   ],
      // ),
      body: Stack(
        children: [
          // Map takes full screen
          Positioned.fill(
            child: MapScreen(),
          ),
          // Drawer icon manually added
          // Drawer icon with border
          Positioned(
            top: 20, // Adjust based on device status bar height
            left: 15,
            child: Builder(
              builder: (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color
                    shape: BoxShape.circle, // Circular shape
                    border: Border.all(color: Colors.black, width: 2), // Border
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 1,
                        offset: const Offset(2, 2), // Shadow position
                      ),
                    ],
                  ),
                  child: const Icon(Icons.menu, color: Colors.black, size: 28),
                ),
              ),
            ),
          ),

          // Floating user info card
          // Positioned(
          //   top: 10,
          //   left: 15,
          //   right: 15,
          //   child: Card(
          //     color: Colors.white.withOpacity(0.9),
          //     elevation: 5,
          //     // shape: RoundedRectangleBorder(
          //     //   borderRadius: BorderRadius.circular(12),
          //     // ),
          //     child: Padding(
          //       padding: const EdgeInsets.all(10.0),
          //       // child: Column(
          //       //   mainAxisSize: MainAxisSize.min,
          //       //   children: [
          //       //     Text(
          //       //       widget.userName,
          //       //       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          //       //       textAlign: TextAlign.center,
          //       //     ),
          //       //     const SizedBox(height: 5),
          //       //     Text(
          //       //       widget.email,
          //       //       style: const TextStyle(fontSize: 16, color: Colors.grey),
          //       //       textAlign: TextAlign.center,
          //       //     ),
          //       //     const SizedBox(height: 5),
          //       //     Text(
          //       //       "Firestore ID: $uniqueId",
          //       //       style: const TextStyle(fontSize: 14, color: Colors.grey),
          //       //       textAlign: TextAlign.center,
          //       //     ),
          //       //   ],
          //       // ),
          //     ),
          //   ),
          // ),

          // Floating Profile Button
          // Positioned(
          //   bottom: 20,
          //   right: 20,
          //   child: FloatingActionButton(
          //     backgroundColor: Colors.blueAccent,
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => ProfileScreen(
          //             userName: widget.userName,
          //             email: widget.email,
          //           ),
          //         ),
          //       );
          //     },
          //     // child: const Icon(Icons.person),
          //   ),
          // ),
        ],
      ),
    );
  }
}
