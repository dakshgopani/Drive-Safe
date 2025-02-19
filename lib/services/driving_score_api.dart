import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

class DrivingScoreAPI {
  final Logger _logger = Logger();

  // Replace with your actual API endpoint URL.
  static const String apiUrl = 'https://kankshi-eco-safety-score-prediction.hf.space/predict';

  Future<Map<String, dynamic>> getDrivingScores(Map<String, dynamic> sensorData) async {
    try {
      _logger.i('Making API call to Driving Score Prediction API.');
      _logger.d('Request data: ${json.encode(sensorData)}');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(sensorData),
      );

      _logger.d('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        // Check for any error in response
        if (result.containsKey('error')) {
          _logger.e('API returned error: ${result['error']}');
          return {'eco_score': 'Error', 'safety_score': 'Error'};
        }
        return {
          'safety_score': result['Safety_Score'],
          'eco_score': result['EcoScore'],
        };
      } else {
        _logger.e('API call failed with status code: ${response.statusCode}');
        return {'eco_score': 'Error', 'safety_score': 'Error'};
      }
    } catch (e, stackTrace) {
      _logger.e('Exception while calling API: $e', e, stackTrace);
      return {'eco_score': 'Error', 'safety_score': 'Error'};
    }
  }
}
