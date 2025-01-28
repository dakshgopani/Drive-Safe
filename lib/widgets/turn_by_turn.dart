import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_tts/flutter_tts.dart';

class TurnByTurnNavigationUI extends StatelessWidget {
  final String instruction;
  final String distance;
  final String lane;
  final String instructionText;
  final FlutterTts flutterTts = FlutterTts();

  TurnByTurnNavigationUI({
    Key? key,
    required this.instruction,
    required this.distance,
    required this.lane,
    required this.instructionText,
  }) : super(key: key) {
    // Initialize TTS and speak the instruction
    _speak(instructionText, distance);
  }

  Future<void> _speak(String instructionText, String distance) async {
    await flutterTts.setLanguage("en-IN");
    await flutterTts.setPitch(1.0);
    String text = "$instructionText in $distance";
    await flutterTts.speak(text);
  }
  IconData _getDirectionIcon(String instruction) {
    // Determine the direction icon based on the instruction
    if (instruction.contains('left')) {
      return Icons.turn_left;
    } else if (instruction.contains('right')) {
      return Icons.turn_right;
    } else if (instruction.contains('straight')) {
      return Icons.straight;
    } else if (instruction.contains('uturn')) {
      return Icons.u_turn_left; // or Icons.u_turn_right
    } else {
      return Icons.navigation; // Default navigation icon
    }
  }


  String _formatToCamelCase(String text) {
    return text.split(' ').map((word) {
      return word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '';
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 50, // Adjust this value as needed
          left: 16,
          right: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.9),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _getDirectionIcon(instruction),
                      color: Colors.white,
                      size: 40, // Increased icon size
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Take "+_formatToCamelCase(instruction),
                            style: const TextStyle(
                              fontSize: 24, // Increased text size
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Distance: $distance',
                            style: const TextStyle(
                              fontSize: 20, // Increased text size
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}