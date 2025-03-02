import 'dart:ui';
import 'package:algorithm_avengers_ves_final/screens/convoyMode/qr_code_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class JoinRoomPage extends StatefulWidget {
  final String userId;
  final String userName;

  const JoinRoomPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  _JoinRoomPageState createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final TextEditingController roomCodeController = TextEditingController();
  bool _fieldError = false;

  void openQRScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanQRCodeScreen(
          userId: widget.userId, // Replace with actual user ID
          userName: widget.userName, // Replace with actual user name
        ),
      ),
    );
  }

  bool validateField() {
    setState(() {
      _fieldError = roomCodeController.text.trim().isEmpty;
    });
    return !_fieldError;
  }

  void joinRoomManually() {
    if (!validateField()) {
      return;
    }
    final enteredRoomCode = roomCodeController.text;
    print("Joining room with code: $enteredRoomCode");
    // Add logic to join room with the entered code
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Join Room")),
      body: Container(
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          width: constraints.maxWidth > 600
                              ? 600
                              : constraints.maxWidth,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildTextField(),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: openQRScanner,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 32,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                icon: const Icon(
                                  FontAwesomeIcons.qrcode,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                label: const Text(
                                  "Scan QR Code",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: joinRoomManually,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 32,
                                  ),
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
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: roomCodeController,
      decoration: InputDecoration(
        labelText: "Enter Room Code",
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        errorText: _fieldError ? "Please enter room code" : null,
        errorBorder: _fieldError
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              )
            : null,
      ),
    );
  }
}
