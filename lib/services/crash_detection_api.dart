import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

class CrashDetectionAPI {
  final Logger _logger = Logger();
  static const String apiUrl = 'https://rudraaaa76-crash-detection.hf.space/predict';
  
  Future<bool> detectCrash(Map<String, dynamic> sensorData) async {
    try {
      _logger.i('Making API call to crash detection service');
      _logger.d('Request data: ${json.encode(sensorData)}');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(sensorData),
      );

      _logger.d('API Response Status Code: ${response.statusCode}');
      _logger.d('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        _logger.i('Crash detection result: $result');
        return result['crash_prediction'] == 1;
      } else {
        _logger.e('API error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.e('Error calling crash detection API', e, stackTrace);
      return false;
    }
  }
}