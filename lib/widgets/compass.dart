import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

Widget buildCompass(double size, Color backgroundColor, Color iconColor) {
  return StreamBuilder<CompassEvent>(
    stream: FlutterCompass.events,
    builder: (context, snapshot) {
      double? direction = snapshot.data?.heading;

      if (direction == null) {
        return Text(
          'N/A',
          style: TextStyle(color: iconColor, fontSize: size / 3),
        );
      }

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Transform.rotate(
          angle: (direction * (math.pi / 180) * -1),
          child: Icon(
            Icons.explore_outlined, // Use the navigation arrow icon
            color: iconColor,
            size: size,
          ),
        ),
      );
    },
  );
}
