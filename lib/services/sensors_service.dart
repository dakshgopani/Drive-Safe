import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'package:logger/logger.dart';

class SensorService {
  final Logger _logger = Logger();
  StreamSubscription? _accelerometerSubscription;
  StreamSubscription? _gyroscopeSubscription;
  Timer? _debugTimer;
  
  double accelX = 0.0, accelY = 0.0, accelZ = 0.0;
  double gyroX = 0.0, gyroY = 0.0, gyroZ = 0.0;

  void startSensorTracking(Function(Map<String, dynamic>) onDataReceived) {
    _logger.i('Starting sensor tracking...');

    try {
      // Debug timer to log sensor values every 5 seconds
      _debugTimer = Timer.periodic(Duration(seconds: 5), (timer) {
        _logger.d('Current Sensor Values:\n'
            'Accelerometer (x,y,z): ($accelX, $accelY, $accelZ)\n'
            'Gyroscope (x,y,z): ($gyroX, $gyroY, $gyroZ)');
      });

      _accelerometerSubscription = userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          accelX = event.x;
          accelY = event.y;
          accelZ = event.z;
          _sendSensorData(onDataReceived);
        },
        onError: (error) {
          _logger.e('Accelerometer error: $error');
        },
      );

      _gyroscopeSubscription = gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          gyroX = event.x;
          gyroY = event.y;
          gyroZ = event.z;
          _sendSensorData(onDataReceived);
        },
        onError: (error) {
          _logger.e('Gyroscope error: $error');
        },
      );

      _logger.i('Sensor tracking started successfully');
    } catch (e) {
      _logger.e('Error starting sensor tracking: $e');
    }
  }

  void _sendSensorData(Function(Map<String, dynamic>) onDataReceived) {
    final now = DateTime.now();
    final sensorData = {
      "timestamp": now.toIso8601String(),
      "accel_x": accelX,
      "accel_y": accelY,
      "accel_z": accelZ,
      "gyro_x": gyroX,
      "gyro_y": gyroY,
      "gyro_z": gyroZ,
    };
    
    _logger.v('Sending sensor data: $sensorData');
    onDataReceived(sensorData);
  }

  void stopSensorTracking() {
    _logger.i('Stopping sensor tracking...');
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _debugTimer?.cancel();
    _logger.i('Sensor tracking stopped');
  }
}