import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driving Behavior Analysis',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: DrivingBehaviorPage(),
    );
  }
}

class DrivingBehaviorPage extends StatefulWidget {
  @override
  _DrivingBehaviorPageState createState() => _DrivingBehaviorPageState();
}

class _DrivingBehaviorPageState extends State<DrivingBehaviorPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> sensorData = [];
  late StreamSubscription<UserAccelerometerEvent>
      _userAccelerometerSubscription;
  late StreamSubscription<GyroscopeEvent> _gyroscopeSubscription;
  bool isCollecting = false;
  String predictionResult = 'No data';
  int _overallHarshBrakingCount = 0;
  int _overallHarshCorneringCount = 0;
  List<String> predictedClasses = [];
  Map<String, int> classCounts = {};

  double accX = 0, accY = 0, accZ = 0;
  double gyroX = 0, gyroY = 0, gyroZ = 0;

  // New UI-related variables
  late TabController _tabController;
  final List<String> _periods = ['Day', 'Week', 'Month'];

  // Sample data for demonstration
  final List<FlSpot> weeklyScores = [
    FlSpot(0, 72),
    FlSpot(1, 75),
    FlSpot(2, 78),
    FlSpot(3, 74),
    FlSpot(4, 76),
    FlSpot(5, 80),
    FlSpot(6, 78),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    });

    if (sensorData.length == 50) {
      sendToAPI(List.from(sensorData));
      sensorData.clear();
    }
  }

  Future<void> sendToAPI(List<Map<String, dynamic>> data) async {
    try {
      var url =
          Uri.parse('https://rudraaaa76-driving-behavior.hf.space/predict');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        setState(() {
          List<String> newPredictedClasses =
              List<String>.from(result['predicted_classes']);
          predictedClasses.addAll(newPredictedClasses);

          for (var className in newPredictedClasses) {
            classCounts[className] = (classCounts[className] ?? 0) + 1;
          }

          String mostFrequentClass = classCounts.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;

          predictionResult = mostFrequentClass;
          _overallHarshBrakingCount += (result['harsh_braking_count'] as int);
          _overallHarshCorneringCount +=
              (result['harsh_cornering_count'] as int);
        });
      } else {
        print("Error response: ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  void startCollection() {
    setState(() {
      isCollecting = true;
      sensorData.clear();
      predictedClasses.clear();
      classCounts.clear();
      _overallHarshBrakingCount = 0;
      _overallHarshCorneringCount = 0;
      predictionResult = 'Collecting data...';
    });
  }

  void stopCollection() {
    setState(() {
      isCollecting = false;
    });
    if (sensorData.isNotEmpty) {
      sendToAPI(sensorData);
    }
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
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDayView(),
                _buildWeekView(),
                _buildMonthView(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isCollecting ? stopCollection : startCollection,
        icon: Icon(isCollecting ? Icons.stop : Icons.play_arrow),
        label: Text(isCollecting ? 'Stop Analysis' : 'Start Analysis'),
      ),
    );
  }

  Widget _buildDayView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScoreCard(),
          SizedBox(height: 16),
          _buildSensorReadingsCard(),
          SizedBox(height: 16),
          _buildPredictionsCard(),
          SizedBox(height: 16),
          _buildBehaviorMetricsCard(),
          if (predictionResult != 'No data') _buildRecommendationsCard(),
        ],
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
            Text(
              'Predictions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Overall Prediction: $predictionResult',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Predicted Classes:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: classCounts.entries
                  .map((entry) => Text(
                        '${entry.key}: ${entry.value}',
                        style: TextStyle(fontSize: 14),
                      ))
                  .toList(),
            ),
            SizedBox(height: 8),
            Text(
              'Overall Harsh Braking: $_overallHarshBrakingCount',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Overall Harsh Cornering: $_overallHarshCorneringCount',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyStatsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Avg. Score', '75'),
                _buildStatItem('Total Trips', '35'),
                _buildStatItem('Total Distance', '315 km'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyStatsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Avg. Score', '77'),
                _buildStatItem('Total Trips', '142'),
                _buildStatItem('Total Distance', '1,280 km'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildWeeklyStatsCard(),
          SizedBox(height: 16),
          _buildWeeklyChart(),
          SizedBox(height: 16),
          _buildBehaviorMetricsCard(),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    final List<FlSpot> monthlyScores = List.generate(30, (index) {
      return FlSpot(index.toDouble(), 70 + (index % 10));
    });

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Performance',
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
                          if (value % 5 == 0) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: monthlyScores,
                      isCurved: true,
                      color: Colors.blue,
                      dotData: FlDotData(show: false),
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

  Widget _buildMonthView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMonthlyStatsCard(),
          SizedBox(height: 16),
          _buildMonthlyChart(),
          SizedBox(height: 16),
          _buildBehaviorMetricsCard(),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Today\'s Score',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              '78',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Trips', '5'),
                _buildStatItem('Hours', '2.5'),
                _buildStatItem('Distance', '45 km'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSensorReadingsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Readings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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

  Widget _buildSensorRow(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value.toStringAsFixed(2),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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

  Widget _buildBehaviorMetricsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Behavior Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildMetricRow(
                'Harsh Braking', _overallHarshBrakingCount, Colors.orange),
            _buildMetricRow(
                'Harsh Cornering', _overallHarshCorneringCount, Colors.blue),
            _buildMetricRow('Speeding', 0.2, Colors.green),
            _buildMetricRow('Phone Usage', 0.1, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Performance',
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
                          const days = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun'
                          ];
                          return Text(
                            days[value.toInt() % days.length],
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: weeklyScores,
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

  Widget _buildRecommendationsCard() {
    final recommendations = generateRecommendations(predictionResult);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
}