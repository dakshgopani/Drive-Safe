import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  // Import Firebase Core
import 'app.dart'; // Import the app.dart file

void main() async {
  // Ensures Flutter bindings are initialized before Firebase is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Run the app after Firebase initialization
  runApp(MyApp());
}
