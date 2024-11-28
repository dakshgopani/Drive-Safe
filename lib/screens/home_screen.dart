import 'package:flutter/material.dart';
import "./profile_screen.dart";

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to ProfileScreen with user data
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(
                  userName: "John Doe", // Replace with dynamic data
                  email: "john.doe@example.com", // Replace with dynamic data
                ),
              ),
            );
          },
          child: const Text("Go to Profile"),
        ),
      ),
    );
  }
}
