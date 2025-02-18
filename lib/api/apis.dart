import 'dart:async';
import 'dart:convert';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:http/http.dart' as http;


class ApiService {
  static const String apiKey = '5a49871c0cmsh9b15b2793087336p143bd4jsn63eda080b121';
  // 740392cb4amsh77a7f25bdf77fb6p1c7346jsnf94b51aee5af
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
    // OSRM API URL for routing
    const String directionsUrl = 'http://router.project-osrm.org/route/v1/driving';

    // Construct the URI with the start and destination coordinates
    final Uri uri = Uri.parse(
        '$directionsUrl/${startLocation.longitude},${startLocation.latitude};${destinationLocation.longitude},${destinationLocation.latitude}?overview=full&geometries=geojson&steps=true');
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Decode the response body
        final data = jsonDecode(response.body);
        if (data['routes'].isNotEmpty) {
          return data['routes']; // Return the routes array
        } else {
          throw Exception('No routes found');
        }
      } else {
        throw Exception('Failed to fetch directions: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching directions: $e');
    }
  }

  static Future<List<String>> fetchCarMakes() async {
    final url = Uri.parse('https://car-data.p.rapidapi.com/cars/makes');
    final response = await http.get(
      url,
      headers: {
        'x-rapidapi-key': apiKey,
        'x-rapidapi-host': 'car-data.p.rapidapi.com',
      },
    );


      // Parse the JSON response into a List
    if (response.statusCode == 200) {
      // Parse the JSON response into a List
      List<dynamic> jsonResponse = json.decode(response.body);
      // Convert the List<dynamic> into a List<String>
      List<String> carMakes = List<String>.from(jsonResponse);
      return carMakes;
    } else {
      // Handle the error accordingly
      throw Exception('Failed to load car makes');
    }

  }
  static Future<List<String>> fetchCarModels({
    required String year,
    required String make,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('https://cars-api10.p.rapidapi.com/models?year=$year&make=$make'),
        headers: {
          "x-rapidapi-key": apiKey,
          "x-rapidapi-host": 'cars-api10.p.rapidapi.com',
        },
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Extract the "Models" array from the response
        final List<dynamic> models = jsonResponse['data']['Models'];
        print("Car models:$models");
        // Map each model's "model_name" to a list of strings
        return models.map((model) => model['model_name'] as String).toList();
      } else {
        // Handle HTTP errors
        throw Exception("Failed to load car models. Status code: ${response.statusCode}");
      }
    } catch (e) {
      // Handle exceptions
      throw Exception("Error fetching car models: $e");
    }
  }
}