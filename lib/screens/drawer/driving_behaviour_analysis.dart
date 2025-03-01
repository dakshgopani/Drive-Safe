import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';


class DrivingTrip {
  final DateTime startTime;
  final DateTime endTime;
  final double score;
  final int harshBrakingCount;
  final int harshCorneringCount;
  final double distance;
  final double durationHours;

  DrivingTrip({
    required this.startTime,
    required this.endTime,
    required this.score,
    required this.harshBrakingCount,
    required this.harshCorneringCount,
    required this.distance,
    required this.durationHours,
  });
}

class DrivingBehaviorPage extends StatefulWidget {
  @override
  _DrivingBehaviorPageState createState() => _DrivingBehaviorPageState();
}

class _DrivingBehaviorPageState extends State<DrivingBehaviorPage>
    with SingleTickerProviderStateMixin {
  // Sensor data storage
  List<Map<String, dynamic>> sensorData = [];
  late StreamSubscription<UserAccelerometerEvent> _userAccelerometerSubscription;
  late StreamSubscription<GyroscopeEvent> _gyroscopeSubscription;

  // State variables
  bool isCollecting = false;
  String predictionResult = 'No data';
  int _currentHarshBrakingCount = 0;
  int _currentHarshCorneringCount = 0;
  double _currentSpeedingScore = 0.0;
  double _currentPhoneUsageScore = 0.0;

  // Trip storage
  List<DrivingTrip> tripHistory = [];
  DateTime? currentTripStartTime;

  // Sensor readings
  double accX = 0, accY = 0, accZ = 0;
  double gyroX = 0, gyroY = 0, gyroZ = 0;

  // Chart data
  List<FlSpot> dailyScores = [];
  List<FlSpot> weeklyScores = [];
  List<FlSpot> monthlyScores = [];

  // UI controllers
  late TabController _tabController;
  final List<String> _periods = ['Day', 'Week', 'Month'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize sensor subscriptions
    _userAccelerometerSubscription =
        userAccelerometerEvents.listen((UserAccelerometerEvent event) {
          setState(() {
            accX = event.x;
            accY = event.y;
            accZ = event.z;
          });
          if (isCollecting) {
            addSensorData(event.x, event.y, event.z, 'acc');
          }
        });

    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        gyroX = event.x;
        gyroY = event.y;
        gyroZ = event.z;
      });
      if (isCollecting) {
        addSensorData(event.x, event.y, event.z, 'gyro');
      }
    });

    _initializeChartData();
  }

  void _initializeChartData() {
    dailyScores = List.generate(24, (index) => FlSpot(index.toDouble(), 0));
    weeklyScores = List.generate(7, (index) => FlSpot(index.toDouble(), 0));
    monthlyScores = List.generate(30, (index) => FlSpot(index.toDouble(), 0));
    _updateChartData();
  }

  void addSensorData(double x, double y, double z, String type) {
    if (x == 0 && y == 0 && z == 0) return;

    sensorData.add({
      "AccX": type == 'acc' ? x : 0.0,
      "AccY": type == 'acc' ? y : 0.0,
      "AccZ": type == 'acc' ? z : 0.0,
      "GyroX": type == 'gyro' ? x : 0.0,
      "GyroY": type == 'gyro' ? y : 0.0,
      "GyroZ": type == 'gyro' ? z : 0.0,
      "timestamp": DateTime.now().toIso8601String(),
    });

    if (sensorData.length >= 50) {
      sendToAPI(List.from(sensorData));
      sensorData.clear();
    }
  }

  Future<void> sendToAPI(List<Map<String, dynamic>> data) async {
    try {
      var url = Uri.parse('https://rudraaaa76-driving-behavior.hf.space/predict');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        setState(() {
          _updateFromApiResponse(result, data);
        });
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  void _updateFromApiResponse(Map<String, dynamic> result, List<Map<String, dynamic>> data) {
    _currentHarshBrakingCount += (result['harsh_braking_count'] as int);
    _currentHarshCorneringCount += (result['harsh_cornering_count'] as int);
    _currentSpeedingScore = _calculateSpeedingScore(data);
    _currentPhoneUsageScore = _calculatePhoneUsageScore(data);
    predictionResult = result['predicted_classes'].isNotEmpty
        ? result['predicted_classes'].last
        : 'Normal Driving';
  }

  DrivingStats _calculatePeriodStats(String period) {
    DateTime now = DateTime.now();
    DateTime periodStart;

    if (period == 'Day') {
      periodStart = DateTime(now.year, now.month, now.day);
    } else if (period == 'Week') {
      periodStart = now.subtract(Duration(days: now.weekday - 1));
      periodStart = DateTime(periodStart.year, periodStart.month, periodStart.day);
    } else {
      periodStart = DateTime(now.year, now.month, 1);
    }

    List<DrivingTrip> periodTrips = tripHistory
        .where((trip) => trip.startTime.isAfter(periodStart))
        .toList();

    if (periodTrips.isEmpty) {
      return DrivingStats(score: 0, trips: 0, hours: 0, distance: 0);
    }

    double totalScore = periodTrips.fold(0, (sum, trip) => sum + trip.score);
    double totalHours = periodTrips.fold(0, (sum, trip) => sum + trip.durationHours);
    double totalDistance = periodTrips.fold(0, (sum, trip) => sum + trip.distance);

    return DrivingStats(
      score: totalScore / periodTrips.length,
      trips: periodTrips.length,
      hours: totalHours,
      distance: totalDistance,
    );
  }

  void _updateChartData() {
    DateTime now = DateTime.now();

    // Daily chart
    var todayTrips = tripHistory.where((trip) =>
    trip.startTime.day == now.day &&
        trip.startTime.month == now.month &&
        trip.startTime.year == now.year);
    dailyScores = List.generate(24, (index) {
      var hourTrips = todayTrips.where((trip) => trip.startTime.hour == index);
      return FlSpot(
        index.toDouble(),
        hourTrips.isNotEmpty
            ? hourTrips.fold(0.0, (sum, trip) => sum + trip.score) / hourTrips.length
            : 0.0,
      );
    });

    // Weekly chart
    var weekStart = now.subtract(Duration(days: now.weekday - 1));
    var weekTrips = tripHistory.where((trip) => trip.startTime.isAfter(weekStart));
    weeklyScores = List.generate(7, (index) {
      var dayTrips = weekTrips.where((trip) =>
      trip.startTime.weekday == (index + 1));
      return FlSpot(
        index.toDouble(),
        dayTrips.isNotEmpty
            ? dayTrips.fold(0.0, (sum, trip) => sum + trip.score) / dayTrips.length
            : 0.0,
      );
    });

    // Monthly chart
    var monthStart = DateTime(now.year, now.month, 1);
    var monthTrips = tripHistory.where((trip) => trip.startTime.isAfter(monthStart));
    monthlyScores = List.generate(30, (index) {
      var dayTrips = monthTrips.where((trip) =>
      trip.startTime.day == (index + 1));
      return FlSpot(
        index.toDouble(),
        dayTrips.isNotEmpty
            ? dayTrips.fold(0.0, (sum, trip) => sum + trip.score) / dayTrips.length
            : 0.0,
      );
    });
  }

  double _calculateDrivingScore() {
    double baseScore = 80;
    double harshBrakingPenalty = _currentHarshBrakingCount * 2;
    double harshCorneringPenalty = _currentHarshCorneringCount * 2;
    double speedingPenalty = _currentSpeedingScore * 10;
    double phonePenalty = _currentPhoneUsageScore * 10;
    return (baseScore - harshBrakingPenalty - harshCorneringPenalty -
        speedingPenalty - phonePenalty).clamp(0, 100);
  }

  double _calculateSpeedingScore(List<Map<String, dynamic>> data) {
    double maxAcc = data.map((e) => (e['AccX'] as double).abs()).reduce((a, b) => a > b ? a : b);
    return (maxAcc > 5 ? 0.3 : 0.1);
  }

  double _calculatePhoneUsageScore(List<Map<String, dynamic>> data) {
    double maxGyro = data.map((e) => (e['GyroX'] as double).abs()).reduce((a, b) => a > b ? a : b);
    return (maxGyro > 3 ? 0.2 : 0.05);
  }

  void startCollection() {
    setState(() {
      isCollecting = true;
      sensorData.clear();
      _currentHarshBrakingCount = 0;
      _currentHarshCorneringCount = 0;
      _currentSpeedingScore = 0.0;
      _currentPhoneUsageScore = 0.0;
      predictionResult = 'Collecting data...';
      currentTripStartTime = DateTime.now();
    });
  }

  void stopCollection() {
    if (currentTripStartTime == null) return;

    double durationHours = DateTime.now().difference(currentTripStartTime!).inMinutes / 60.0;
    double estimatedDistance = durationHours * 40; // Assume 40 km/h average

    setState(() {
      isCollecting = false;
      if (sensorData.isNotEmpty) {
        sendToAPI(sensorData);
      }

      // Save trip
      DrivingTrip trip = DrivingTrip(
        startTime: currentTripStartTime!,
        endTime: DateTime.now(),
        score: _calculateDrivingScore(),
        harshBrakingCount: _currentHarshBrakingCount,
        harshCorneringCount: _currentHarshCorneringCount,
        distance: estimatedDistance,
        durationHours: durationHours,
      );

      tripHistory.add(trip);
      _updateChartData();
    });
  }

  @override
  void dispose() {
    _userAccelerometerSubscription.cancel();
    _gyroscopeSubscription.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Driving Score',
          style: TextStyle(color: Colors.black87, fontSize: 24),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: _periods.map((period) => Tab(text: period)).toList(),
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPeriodView('Day', dailyScores),
          _buildPeriodView('Week', weeklyScores),
          _buildPeriodView('Month', monthlyScores),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isCollecting ? stopCollection : startCollection,
        icon: Icon(isCollecting ? Icons.stop : Icons.play_arrow),
        label: Text(isCollecting ? 'Stop Analysis' : 'Start Analysis'),
      ),
    );
  }

  Widget _buildPeriodView(String period, List<FlSpot> chartData) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScoreCard(period),
          SizedBox(height: 16),
          if (period == 'Day') _buildSensorReadingsCard(),
          SizedBox(height: 16),
          _buildPerformanceChart(period, chartData),
          SizedBox(height: 16),
          _buildBehaviorMetricsCard(period),
          SizedBox(height: 16),
          if (predictionResult != 'No data' && period == 'Day')
            _buildPredictionsCard(),
          if (predictionResult != 'No data' && period == 'Day')
            _buildRecommendationsCard(),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String period) {
    DrivingStats stats = _calculatePeriodStats(period);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '$period Score',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              stats.score.isNaN ? '0' : stats.score.toInt().toString(),
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Trips', stats.trips.toString()),
                _buildStatItem('Hours', stats.hours.toStringAsFixed(1)),
                _buildStatItem('Distance', '${stats.distance.toInt()} km'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorReadingsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Readings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildSensorRow('Accelerometer X', accX),
            _buildSensorRow('Accelerometer Y', accY),
            _buildSensorRow('Accelerometer Z', accZ),
            Divider(),
            _buildSensorRow('Gyroscope X', gyroX),
            _buildSensorRow('Gyroscope Y', gyroY),
            _buildSensorRow('Gyroscope Z', gyroZ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart(String period, List<FlSpot> scores) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$period Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (period == 'Day') {
                            return Text('${value.toInt()}h');
                          } else if (period == 'Week') {
                            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            return Text(days[value.toInt()]);
                          } else {
                            return Text((value.toInt() + 1).toString());
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: scores,
                      isCurved: true,
                      color: Colors.blue,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBehaviorMetricsCard(String period) {
    DrivingStats stats = _calculatePeriodStats(period);

    // Calculate period-specific metrics
    List<DrivingTrip> periodTrips = tripHistory.where((trip) {
      DateTime now = DateTime.now();
      if (period == 'Day') {
        return trip.startTime.day == now.day &&
            trip.startTime.month == now.month &&
            trip.startTime.year == now.year;
      } else if (period == 'Week') {
        return trip.startTime.isAfter(now.subtract(Duration(days: now.weekday - 1)));
      } else {
        return trip.startTime.month == now.month && trip.startTime.year == now.year;
      }
    }).toList();

    int periodHarshBraking = periodTrips.fold(0, (sum, trip) => sum + trip.harshBrakingCount);
    int periodHarshCornering = periodTrips.fold(0, (sum, trip) => sum + trip.harshCorneringCount);
    double periodSpeeding = isCollecting ? _currentSpeedingScore : 0.0;
    double periodPhoneUsage = isCollecting ? _currentPhoneUsageScore : 0.0;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Behavior Metrics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildMetricRow('Harsh Braking', periodHarshBraking, Colors.orange),
            _buildMetricRow('Harsh Cornering', periodHarshCornering, Colors.blue),
            _buildMetricRow('Speeding', periodSpeeding, Colors.green),
            _buildMetricRow('Phone Usage', periodPhoneUsage, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Predictions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('Current Trip Prediction: $predictionResult'),
            SizedBox(height: 8),
            Text('Harsh Braking: $_currentHarshBrakingCount'),
            Text('Harsh Cornering: $_currentHarshCorneringCount'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    final recommendations = generateRecommendations(predictionResult);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recommendations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ...recommendations.map((rec) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text(rec)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSensorRow(String label, double value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, dynamic value, Color color) {
    double percentage = value is int ? value / 50 : value.toDouble();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(value is int ? '$value' : '${(percentage * 100).toInt()}%'),
            ],
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0),
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  List<String> generateRecommendations(String prediction) {
    switch (prediction) {
      case 'Aggressive Driving':
        return [
          'Avoid rapid acceleration.',
          'Reduce hard braking.',
          'Drive at a consistent speed.',
        ];
      case 'Distracted Driving':
        return [
          'Focus on the road.',
          'Avoid using your phone while driving.',
        ];
      default:
        return ['Maintain your current driving habits.'];
    }
  }
}

class DrivingStats {
  final double score;
  final int trips;
  final double hours;
  final double distance;

  DrivingStats({
    required this.score,
    required this.trips,
    required this.hours,
    required this.distance,
  });
}