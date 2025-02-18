import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'create_room_page.dart';
import 'join_room_page.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            // Animated Background with a dynamic multi-color gradient
            Positioned.fill(
              child: AnimatedContainer(
                duration: Duration(seconds: 3),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Colors.blue.shade200, Colors.white],
                    radius: 1.2,
                    focalRadius: 1.0,
                    center: Alignment.center,
                  ),
                ),
              ),
            ),
            // Glassmorphism container with some shadow and gradient effects
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                  width: screenWidth * 0.85,  // 75% of screen width
                    height: screenHeight * 0.3,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6), // Light frosted glass effect
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Create Room Button with gradient and shadow
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CreateRoomPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600, // Frosted blue color
                            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 10,
                          ),
                          icon: Icon(
                            FontAwesomeIcons.plus,
                            color: Colors.white,
                            size: 28,
                          ),
                          label: Text(
                            'Create Room',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Join Room Button with gradient and subtle shadow
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => JoinRoomPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600, // Frosted green color
                            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 10,
                          ),
                          icon: Icon(
                            FontAwesomeIcons.users,
                            color: Colors.white,
                            size: 28,
                          ),
                          label: Text(
                            '  Join Room',
                            style: TextStyle(
                              fontSize: 20,
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
          ],
        ),
      ),
    );
  }

}
