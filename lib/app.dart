import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  // Hides the debug banner
      title: 'Firebase Test App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),  // Set the HomeScreen as the initial screen
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String displayName = 'No user signed in';
  String firestoreMessage = 'No data fetched from Firestore';

  @override
  void initState() {
    super.initState();
    // Call the test connectivity method
    testFirebaseConnectivity();
  }

  // Test Firebase Authentication and Firestore connectivity
  Future<void> testFirebaseConnectivity() async {
    try {
      // Check if user is signed in
      User? user = auth.currentUser;
      if (user != null) {
        setState(() {
          displayName = 'User signed in: ${user.displayName}';
        });
      } else {
        setState(() {
          displayName = 'No user signed in';
        });
      }

      // Test Firestore: Add a document
      await firestore.collection('test').doc('testDoc').set({
        'message': 'Firebase is connected!',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Retrieve data from Firestore to check if it's stored correctly
      DocumentSnapshot snapshot = await firestore.collection('test').doc('testDoc').get();
      if (snapshot.exists) {
        setState(() {
          firestoreMessage = 'Firestore Document Data: ${snapshot.data()}';
        });
      } else {
        setState(() {
          firestoreMessage = 'No data found in Firestore';
        });
      }
    } catch (e) {
      setState(() {
        firestoreMessage = 'Error with Firebase: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Connectivity Test"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(displayName, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            Text(firestoreMessage, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: testFirebaseConnectivity,  // Re-run the test when pressed
              child: const Text('Test Firebase Again'),
            ),
          ],
        ),
      ),
    );
  }
}
