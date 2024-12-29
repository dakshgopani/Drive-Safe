import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CreateRoomPage extends StatefulWidget {
  @override
  _CreateRoomPageState createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final TextEditingController roomNameController = TextEditingController();
  final TextEditingController startLocationController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController numberOfCarsController = TextEditingController();
  String? generatedRoomCode;

  void createRoom() {
    final uuid = Uuid();
    setState(() {
      generatedRoomCode = uuid.v4();
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Room Created"),
        content: Text("Room Code: $generatedRoomCode"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text("Create Room")),
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
                        // Room Name TextField with better styling
                        TextField(
                          controller: roomNameController,
                          decoration: InputDecoration(
                            labelText: "Name of Room",
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                        ),
                        SizedBox(height: 10),
                        // Start Location TextField
                        TextField(
                          controller: startLocationController,
                          decoration: InputDecoration(
                            labelText: "Start Location",
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                        ),
                        SizedBox(height: 10),
                        // Destination Location TextField
                        TextField(
                          controller: destinationController,
                          decoration: InputDecoration(
                            labelText: "Destination Location",
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                        ),
                        SizedBox(height: 10),
                        // Number of Cars TextField
                        TextField(
                          controller: numberOfCarsController,
                          decoration: InputDecoration(
                            labelText: "Number of Cars",
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 20),
                        // Create Room Button
                        ElevatedButton(
                          onPressed: createRoom,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600, // Button color
                            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            "Create Room",
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
