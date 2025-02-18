import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class ZoomButtons extends StatelessWidget {
  final MapController mapController;

  ZoomButtons({required this.mapController});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Zoom In Button
        _buildZoomButton(
          icon: Icons.zoom_in,
          onPressed: () => mapController.zoomIn(),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
        ),
        SizedBox(height: 5), // Transparent space between buttons
        // Zoom Out Button
        _buildZoomButton(
          icon: Icons.zoom_out,
          onPressed: () => mapController.zoomOut(),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
        ),
      ],
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onPressed,
    required BorderRadius borderRadius,
  }) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: 50,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: borderRadius,
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
          icon: Icon(icon, color: Colors.blueAccent,size: 35,),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tight(const Size(60, 60)),
        ),
      ),
    );
  }
}
