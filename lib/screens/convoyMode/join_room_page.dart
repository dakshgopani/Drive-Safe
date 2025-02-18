import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class JoinRoomPage extends StatefulWidget {
  @override
  _JoinRoomPageState createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final TextEditingController roomCodeController = TextEditingController();

  void openQRScanner() {
    // Implement QR Code scanner here
    print("Opening QR Scanner...");
  }

  void joinRoomManually() {
    final enteredRoomCode = roomCodeController.text;
    if (enteredRoomCode.isNotEmpty) {
      print("Joining room with code: $enteredRoomCode");
      // Add logic to join room with the entered code
    } else {
      print("Please enter a room code.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text("Join Room")),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade100,
                    Colors.blue.shade300,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Glassmorphism effect container
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: screenWidth * 0.75,  // 75% of screen width
                  height: screenHeight * 0.6, // 60% of screen height
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), // Light frosted glass effect
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Room Code TextField with better styling
                        TextField(
                          controller: roomCodeController,
                          decoration: InputDecoration(
                            labelText: "Enter Room Code",
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Scan QR Code Button
                        ElevatedButton.icon(
                          onPressed: openQRScanner,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600, // Button color
                            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          icon: Icon(
                            FontAwesomeIcons.qrcode,
                            color: Colors.white,
                            size: 24,
                          ),
                          label: Text(
                            "Scan QR Code",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Join Room Button
                        ElevatedButton(
                          onPressed: joinRoomManually,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600, // Button color
                            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Join Room",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
