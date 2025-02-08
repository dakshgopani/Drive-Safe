import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/sensors_service.dart';
import '../services/crash_detection_api.dart';
import '../services/background_service.dart';

class DrivingMonitorScreen extends StatefulWidget {
  @override
  _DrivingMonitorScreenState createState() => _DrivingMonitorScreenState();
}

class _DrivingMonitorScreenState extends State<DrivingMonitorScreen> {
  final Logger _logger = Logger();
  final SensorService _sensorService = SensorService();
  final CrashDetectionAPI _crashDetectionAPI = CrashDetectionAPI();
  bool isMonitoring = false;
  String _lastApiResponse = "No API calls yet";
  String _lastSensorData = "No sensor data yet";

  @override
  void initState() {
    super.initState();
    _logger.i('Initializing DrivingMonitorScreen');
    BackgroundService.initialize();
  }

  void _toggleMonitoring() {
    _logger.i('Toggling monitoring state');
    setState(() {
      isMonitoring = !isMonitoring;
    });

    if (isMonitoring) {
      _startMonitoring();
    } else {
      _stopMonitoring();
    }
  }

  void _startMonitoring() {
    _logger.i('Starting monitoring');
    
    // Start background service
    BackgroundService.startMonitoring();

    // Start sensor tracking
    _sensorService.startSensorTracking((sensorData) async {
      setState(() {
        _lastSensorData = json.encode(sensorData);
      });

      _logger.d('Received sensor data: $_lastSensorData');

      try {
        final isCrashDetected = await _crashDetectionAPI.detectCrash(sensorData);
        
        setState(() {
          _lastApiResponse = 'API Response: Crash detected: $isCrashDetected';
        });

        if (isCrashDetected) {
          _logger.w('Crash detected!');
          _showCrashAlert();
        }
      } catch (e) {
        _logger.e('Error in monitoring loop: $e');
        setState(() {
          _lastApiResponse = 'Error: $e';
        });
      }
    });
  }

  void _stopMonitoring() {
    _logger.i('Stopping monitoring');
    BackgroundService.stopMonitoring();
    _sensorService.stopSensorTracking();

  }

  void _showCrashAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Possible Crash Detected!'),
          content: Text('Are you okay? Emergency services will be contacted if no response.'),
          actions: [
            TextButton(
              child: Text('I\'m OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Need Help'),
              onPressed: () {
                // Implement emergency service call
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drive Monitor'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _toggleMonitoring,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20), backgroundColor: isMonitoring ? Colors.red : Colors.green,
              ),
              child: Text(
                isMonitoring ? 'Stop Monitoring' : 'Start Drive',
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Monitoring Status: ${isMonitoring ? "Active" : "Inactive"}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Last Sensor Data:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_lastSensorData),
            ),
            SizedBox(height: 20),
            Text(
              'Last API Response:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_lastApiResponse),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logger.i('Disposing DrivingMonitorScreen');
    _sensorService.stopSensorTracking();
    super.dispose();
  }
}