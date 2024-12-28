import 'package:algorithm_avengers_ves_final/screens/mapscreen.dart';
import 'package:flutter/material.dart';

void main() {
  // Ensures Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Run the app and directly navigate to MapScreen
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Map App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapScreen(), // Set MapScreen as the home screen
    );
  }
}
