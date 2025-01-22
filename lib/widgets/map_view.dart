import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart'; // OSM package import

class MapView extends StatelessWidget {
  final MapController mapController;

  MapView({required this.mapController});

  @override
  Widget build(BuildContext context) {
    return OSMFlutter(
      controller: mapController,
      osmOption: OSMOption(
        enableRotationByGesture: true,

        userTrackingOption: UserTrackingOption(
          enableTracking: false,
          unFollowUser: true,
        ),

        zoomOption: ZoomOption(
          initZoom: 15,
          minZoomLevel: 3,
          maxZoomLevel: 19,
          stepZoom: 1.0,
        ),
        // userLocationMarker: UserLocationMaker(
        //   personMarker: MarkerIcon(
        //     icon: Icon(Icons.location_on, color: Colors.blue, size: 150),
        //   ),
        //   directionArrowMarker: MarkerIcon(
        //     icon: Icon(Icons.navigation, size: 150, color: Colors.blue),
        //   ),
        // ),
        roadConfiguration: RoadOption(roadColor: Colors.yellowAccent),

      ),

    );
  }
}
