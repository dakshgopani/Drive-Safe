import 'dart:async';
import 'dart:convert';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:http/http.dart' as http;


class ApiService {
  static const String apiKey = '5a49871c0cmsh9b15b2793087336p143bd4jsn63eda080b121';
  static const String apiHost = 'google-map-places.p.rapidapi.com';

  static Future<List<dynamic>> fetchSearchResults(String query) async {
    const String apiUrl =
        'https://google-map-places.p.rapidapi.com/maps/api/place/autocomplete/json';
    final Uri uri = Uri.parse('$apiUrl?input=$query&radius=50000&language=en');

    try {
      final response = await http.get(
        uri,
        headers: {
          'x-rapidapi-key': apiKey,
          'x-rapidapi-host': apiHost,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['predictions'];
      } else {
        throw Exception('Failed to fetch search results: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching search results: $e');
    }
  }

  static Future<List<dynamic>> fetchPlaceDetails(String placeId) async {
    const String detailsUrl =
        'https://google-map-places.p.rapidapi.com/maps/api/place/details/json';
    final Uri uri =
    Uri.parse('$detailsUrl?place_id=$placeId&language=en');

    try {
      final response = await http.get(
        uri,
        headers: {
          'x-rapidapi-key': apiKey,
          'x-rapidapi-host': apiHost,
        },
      );

      if (response.statusCode == 200) {
        final placedetails = jsonDecode(response.body)['result'];
        final selectedLocation = GeoPoint(
          latitude: placedetails['geometry']['location']['lat'],
          longitude: placedetails['geometry']['location']['lng'],
        );
        return [selectedLocation,placedetails];
      } else {
        throw Exception('Failed to fetch place details: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching place details: $e');
    }
  }

  static Future<List<dynamic>> fetchDirections(
      GeoPoint startLocation, GeoPoint destinationLocation) async {
    const String directionsUrl =
        'https://google-map-places.p.rapidapi.com/maps/api/directions/json';

    final Uri uri = Uri.parse(
        '$directionsUrl?origin=${startLocation.latitude},${startLocation.longitude}'
            '&destination=${destinationLocation.latitude},${destinationLocation.longitude}'
            '&mode=driving&language=en');

    try {
      final response = await http.get(
        uri,
        headers: {
          'x-rapidapi-key': apiKey,
          'x-rapidapi-host': apiHost,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['routes'][0]['overview_polyline']['points'];
      } else {
        throw Exception('Failed to fetch directions: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching directions: $e');
    }
  }
}