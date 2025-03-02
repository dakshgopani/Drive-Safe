import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/driving_score_api.dart';
import '../services/sensors_service.dart';
import '../services/crash_detection_api.dart';
import '../services/background_service.dart';
import '../widgets/crash_alert_dialog.dart';

class DrivingMonitorScreen extends StatefulWidget {
  @override
  _DrivingMonitorScreenState createState() => _DrivingMonitorScreenState();
}

class _DrivingMonitorScreenState extends State<DrivingMonitorScreen> {
  // final Logger _logger = Logger();
  final SensorService _sensorService = SensorService();
  final CrashDetectionAPI _crashDetectionAPI = CrashDetectionAPI();
  final DrivingScoreAPI _drivingScoreAPI = DrivingScoreAPI();

  bool isMonitoring = false;
  bool isDialogShown = false; // Prevents multiple dialogs
  String _lastApiResponse = "No API calls yet";
  String _ecoScore = "N/A";
  String _safetyScore = "N/A";
  String _averageScore = "N/A";
  String _speed = "0 km/h";

  List<double> _ecoScoreList = [];
  List<double> _safetyScoreList = [];

  @override
  void initState() {
    super.initState();
    // _logger.i('Initializing DrivingMonitorScreen');
    BackgroundService.initialize();
  }

  void _toggleMonitoring() {
    // _logger.i('Toggling monitoring state');
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
    // _logger.i('Starting monitoring');
    BackgroundService.startMonitoring();
    _ecoScoreList.clear();
    _safetyScoreList.clear();

    _sensorService.startSensorTracking((sensorData) async {
      if (!mounted) return; // Prevents setState if widget is disposed

      // _logger.d('Received sensor data: ${json.encode(sensorData)}');

      try {
        // Extract speed
        String speed = sensorData['Speed_kmh']?.toStringAsFixed(1) ?? "0";
        setState(() {
          _speed = "$speed km/h";
        });

        // Call Crash Detection API
        final isCrashDetected = await _crashDetectionAPI.detectCrash(sensorData);

        // Call Driving Score API
        final drivingScores = await _drivingScoreAPI.getDrivingScores(sensorData);

        double eco = double.tryParse(drivingScores['eco_score'].toString()) ?? 0.0;
        double safety = double.tryParse(drivingScores['safety_score'].toString()) ?? 0.0;

        _ecoScoreList.add(eco);
        _safetyScoreList.add(safety);

        if (mounted) {
          setState(() {
            _ecoScore = eco.toStringAsFixed(2);
            _safetyScore = safety.toStringAsFixed(2);
            _lastApiResponse = 'Crash detected: $isCrashDetected';
          });
        }

        if (isCrashDetected && mounted && !isDialogShown) {
          // _logger.w('Crash detected!');
          setState(() {
            isDialogShown = true;
          });
          _showCrashAlert();
        }
      } catch (e) {
        // _logger.e('Error in monitoring loop: $e');
        if (mounted) {
          setState(() {
            _lastApiResponse = 'Error: $e';
          });
        }
      }
    });
  }

  void _stopMonitoring() {
    // _logger.i('Stopping monitoring');
    BackgroundService.stopMonitoring();
    _sensorService.stopSensorTracking();

    // Calculate average scores
    double avgEco = _ecoScoreList.isNotEmpty ? _ecoScoreList.reduce((a, b) => a + b) / _ecoScoreList.length : 0.0;
    double avgSafety = _safetyScoreList.isNotEmpty ? _safetyScoreList.reduce((a, b) => a + b) / _safetyScoreList.length : 0.0;
    double avgScore = (avgEco + avgSafety) / 2;

    if (mounted) {
      setState(() {
        _averageScore = avgScore.toStringAsFixed(2);
      });
    }
  }

  void _showCrashAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CrashAlertDialog(
          onEmergencyTriggered: () {
            // _logger.w('Emergency alert sent!');
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
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.greenAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScoreContainer(),
            SizedBox(height: 30),
            _buildStartStopButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreContainer() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        children: [
          Text("Live Driving Scores", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 15),
          _buildScoreRow("Eco Score", _ecoScore, Colors.green),
          _buildScoreRow("Safety Score", _safetyScore, Colors.blue),
          // _buildScoreRow("Speed", _speed, Colors.orange),
          if (!isMonitoring) ...[
            Divider(),
            _buildScoreRow("Average driving Score", _averageScore, Colors.purple),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Chip(
            label: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: color,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          ),
        ],
      ),
    );
  }

  Widget _buildStartStopButton() {
    return ElevatedButton(
      onPressed: _toggleMonitoring,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        backgroundColor: isMonitoring ? Colors.red : Colors.green,
      ),
      child: Text(
        isMonitoring ? 'Stop Monitoring' : 'Start Drive',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  void dispose() {
    // _logger.i('Disposing DrivingMonitorScreen');
    _sensorService.stopSensorTracking();
    super.dispose();
  }
}