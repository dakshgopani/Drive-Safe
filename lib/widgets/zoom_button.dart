import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart'; // OSM package import

class ZoomButtons extends StatelessWidget {
  final MapController mapController;

  ZoomButtons({required this.mapController});

  @override
  Widget build(BuildContext context) {
    return
      Column(
        children: [
          // Zoom In Button
          _buildZoomButton(
            icon: Icons.zoom_in,
            onPressed: () => mapController.zoomIn(),
          ),
          // Zoom Out Button
          _buildZoomButton(
            icon: Icons.zoom_out,
            onPressed: () => mapController.zoomOut(),
          ),
        ],
      );
  }

  Widget _buildZoomButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.blueAccent),
          )
    );

  }
}