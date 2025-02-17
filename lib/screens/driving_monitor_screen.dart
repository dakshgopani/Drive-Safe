import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/sensors_service.dart';
import '../services/crash_detection_api.dart';
import '../services/background_service.dart';
import '../widgets/crash_alert_dialog.dart';

class DrivingMonitorScreen extends StatefulWidget {
  @override
  _DrivingMonitorScreenState createState() => _DrivingMonitorScreenState();
}

class _DrivingMonitorScreenState extends State<DrivingMonitorScreen> {
  final Logger _logger = Logger();
  final SensorService _sensorService = SensorService();
  final CrashDetectionAPI _crashDetectionAPI = CrashDetectionAPI();
  bool isMonitoring = false;
  bool isDialogShown = false; // Prevents multiple dialogs

  String _lastApiResponse = "No API calls yet";

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

    BackgroundService.startMonitoring();

    _sensorService.startSensorTracking((sensorData) async {
      if (!mounted) return; // Prevents setState if widget is disposed

      _logger.d('Received sensor data: ${json.encode(sensorData)}');

      try {
        final isCrashDetected =
            await _crashDetectionAPI.detectCrash(sensorData);

        if (mounted) {
          setState(() {
            _lastApiResponse = 'API Response: Crash detected: $isCrashDetected';
          });
        }
        if (isCrashDetected && mounted && !isDialogShown) {
          _logger.w('Crash detected!');
          setState(() {
            isDialogShown = true;
          });
          _showCrashAlert();
        }
      } catch (e) {
        _logger.e('Error in monitoring loop: $e');
        if (mounted) {
          setState(() {
            _lastApiResponse = 'Error: $e';
          });
        }
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
        return CrashAlertDialog(
          onEmergencyTriggered: () {
            _logger.w('Emergency alert sent!');
          },
          onDialogClosed: () {
            if (mounted) {
              setState(() {
                isDialogShown = false;
              });
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Drive Monitor')),
      body: Center(
        child: ElevatedButton(
          onPressed: _toggleMonitoring,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            backgroundColor: isMonitoring ? Colors.red : Colors.green,
          ),
          child: Text(
            isMonitoring ? 'Stop Monitoring' : 'Start Drive',
            style: TextStyle(fontSize: 20),
          ),
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
