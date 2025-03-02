import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sensors_plus/sensors_plus.dart';
import '../../services/trip_service.dart'; // Adjust path as needed
import 'crash_detection_api.dart'; // Import the crash detection API

class DrivingBehaviorService {
  static final DrivingBehaviorService _instance = DrivingBehaviorService._internal();
  factory DrivingBehaviorService() => _instance;
  DrivingBehaviorService._internal();

  // Crash detection
  final CrashDetectionAPI _crashDetectionAPI = CrashDetectionAPI();
  Timer? _crashDetectionTimer;
  bool _crashDetected = false;

  // Sensor subscriptions
  StreamSubscription<UserAccelerometerEvent>? _userAccelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  // State variables (made public via getters)
  bool get isCollecting => _isCollecting;
  bool _isCollecting = false;

  List<Map<String, dynamic>> get sensorData => _sensorData;
  List<Map<String, dynamic>> _sensorData = [];

  int get harshBrakingCount => _harshBrakingCount;
  int _harshBrakingCount = 0;

  int get harshCorneringCount => _harshCorneringCount;
  int _harshCorneringCount = 0;

  double get speedingScore => _speedingScore;
  double _speedingScore = 0.0;

  double get phoneUsageScore => _phoneUsageScore;
  double _phoneUsageScore = 0.0;

  String get predictionResult => _predictionResult;
  String _predictionResult = 'No data';

  DateTime? get tripStartTime => _tripStartTime;
  DateTime? _tripStartTime;

  // Sensor readings (already public)
  double accX = 0, accY = 0, accZ = 0;
  double gyroX = 0, gyroY = 0, gyroZ = 0;

  // Callbacks for UI updates
  Function(String)? onPredictionUpdate;
  Function(double, double, double, double, double, double)? onSensorUpdate;
  Function(Map<String, dynamic>)? onTripCompleted;
  Function(bool)? onCrashDetected; // New callback for crash detection

  void startTracking() {
    if (_isCollecting) return;

    _isCollecting = true;
    _sensorData.clear();
    _harshBrakingCount = 0;
    _harshCorneringCount = 0;
    _speedingScore = 0.0;
    _phoneUsageScore = 0.0;
    _predictionResult = 'Collecting data...';
    _tripStartTime = DateTime.now();
    _crashDetected = false;

    _userAccelerometerSubscription = userAccelerometerEvents.listen((event) {
      accX = event.x;
      accY = event.y;
      accZ = event.z;
      if (_isCollecting) {
        _addSensorData(event.x, event.y, event.z, 'acc');
      }
      onSensorUpdate?.call(accX, accY, accZ, gyroX, gyroY, gyroZ);
    });

    _gyroscopeSubscription = gyroscopeEvents.listen((event) {
      gyroX = event.x;
      gyroY = event.y;
      gyroZ = event.z;
      if (_isCollecting) {
        _addSensorData(event.x, event.y, event.z, 'gyro');
      }
      onSensorUpdate?.call(accX, accY, accZ, gyroX, gyroY, gyroZ);
    });

    // Start periodic crash detection
    _startCrashDetection();

    onPredictionUpdate?.call(_predictionResult);
  }

  void _startCrashDetection() {
    // Check for crashes every 5 seconds
    _crashDetectionTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      if (!_isCollecting) {
        timer.cancel();
        return;
      }

      if (_sensorData.isNotEmpty) {
        // Prepare the most recent sensor data for crash detection
        Map<String, dynamic> recentData = {
          'accelerometer': {
            'x': accX,
            'y': accY, 
            'z': accZ
          },
          'gyroscope': {
            'x': gyroX,
            'y': gyroY,
            'z': gyroZ
          },
          'timestamp': DateTime.now().toIso8601String()
        };

        bool crashDetected = await _crashDetectionAPI.detectCrash(recentData);
        
        if (crashDetected && !_crashDetected) {
          _crashDetected = true;
          onCrashDetected?.call(true);
          
          // Optional: You might want to automatically stop tracking when a crash is detected
          // await stopTracking();
        }
      }
    });
  }

  Future<void> stopTracking() async {
    if (!_isCollecting || _tripStartTime == null) return;

    _isCollecting = false;
    _userAccelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _crashDetectionTimer?.cancel();

    if (_sensorData.isNotEmpty) {
      await _sendToAPI(_sensorData);
    }

    DateTime endTime = DateTime.now();
    double durationHours = endTime.difference(_tripStartTime!).inMinutes / 60.0;
    double estimatedDistance = durationHours * 40; // Assume 40 km/h average
    double drivingScore = calculateDrivingScore();
    double ecoScore = calculateEcoScore();
    double safetyScore = calculateSafetyScore();

    Map<String, dynamic> tripData = {
      'startTime': _tripStartTime,
      'endTime': endTime,
      'score': drivingScore,
      'harshBrakingCount': _harshBrakingCount,
      'harshCorneringCount': _harshCorneringCount,
      'distance': estimatedDistance,
      'durationHours': durationHours,
      'ecoScore': ecoScore,
      'safetyScore': safetyScore,
      'crashDetected': _crashDetected,
    };

    // Save to Firestore
    TripService tripService = TripService(
      drivingScore: drivingScore,
      ecoScore: ecoScore,
      safetyScore: safetyScore,
      harshBrakingCount: _harshBrakingCount,
      harshCorneringCount: _harshCorneringCount,
    );
    String tripId = await tripService.saveTripDataToFirestore();

    onTripCompleted?.call(tripData);
    _predictionResult = 'No data';
    onPredictionUpdate?.call(_predictionResult);
  }

  void _addSensorData(double x, double y, double z, String type) {
    if (x == 0 && y == 0 && z == 0) return;

    _sensorData.add({
      "AccX": type == 'acc' ? x : 0.0,
      "AccY": type == 'acc' ? y : 0.0,
      "AccZ": type == 'acc' ? z : 0.0,
      "GyroX": type == 'gyro' ? x : 0.0,
      "GyroY": type == 'gyro' ? y : 0.0,
      "GyroZ": type == 'gyro' ? z : 0.0,
      "timestamp": DateTime.now().toIso8601String(),
    });

    if (_sensorData.length >= 50) {
      _sendToAPI(List.from(_sensorData));
      _sensorData.clear();
    }
  }

  Future<void> _sendToAPI(List<Map<String, dynamic>> data) async {
    try {
      var url = Uri.parse('https://rudraaaa76-driving-behavior.hf.space/predict');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        _harshBrakingCount += (result['harsh_braking_count'] as int);
        _harshCorneringCount += (result['harsh_cornering_count'] as int);
        _speedingScore = calculateSpeedingScore(data);
        _phoneUsageScore = calculatePhoneUsageScore(data);
        _predictionResult = result['predicted_classes'].isNotEmpty
            ? result['predicted_classes'].last
            : 'Normal Driving';
        onPredictionUpdate?.call(_predictionResult);
      }
    } catch (e) {
      print("Exception sending to API: $e");
    }
  }

  // Public methods for score calculations
  double calculateDrivingScore() {
    double baseScore = 80;
    double harshBrakingPenalty = _harshBrakingCount * 2;
    double harshCorneringPenalty = _harshCorneringCount * 2;
    double speedingPenalty = _speedingScore * 10;
    double phonePenalty = _phoneUsageScore * 10;
    double crashPenalty = _crashDetected ? 30 : 0; // Add penalty for crashes
    return (baseScore - harshBrakingPenalty - harshCorneringPenalty - speedingPenalty - phonePenalty - crashPenalty).clamp(0, 100);
  }

  double calculateEcoScore() {
    double baseScore = 85.0;
    double brakingPenalty = _harshBrakingCount * 2.5;
    double speedingPenalty = _speedingScore * 15;
    double corneringPenalty = _harshCorneringCount * 1.5;
    return (baseScore - brakingPenalty - speedingPenalty - corneringPenalty).clamp(0.0, 100.0);
  }

  double calculateSafetyScore() {
    double baseScore = 90.0;
    double brakingPenalty = _harshBrakingCount * 3.0;
    double corneringPenalty = _harshCorneringCount * 2.5;
    double speedingPenalty = _speedingScore * 20;
    double phonePenalty = _phoneUsageScore * 25;
    double crashPenalty = _crashDetected ? 50 : 0; // Add major penalty for crashes
    return (baseScore - brakingPenalty - corneringPenalty - speedingPenalty - phonePenalty - crashPenalty).clamp(0.0, 100.0);
  }

  double calculateSpeedingScore(List<Map<String, dynamic>> data) {
    double maxAcc = data.map((e) => (e['AccX'] as double).abs()).reduce((a, b) => a > b ? a : b);
    return (maxAcc > 5 ? 0.3 : 0.1);
  }

  double calculatePhoneUsageScore(List<Map<String, dynamic>> data) {
    double maxGyro = data.map((e) => (e['GyroX'] as double).abs()).reduce((a, b) => a > b ? a : b);
    return (maxGyro > 3 ? 0.2 : 0.05);
  }

  void dispose() {
    _userAccelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _crashDetectionTimer?.cancel();
  }
}