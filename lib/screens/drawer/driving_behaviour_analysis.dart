import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/driving_service.dart'; 

class DrivingTrip {
  final DateTime startTime;
  final DateTime endTime;
  final double score;
  final int harshBrakingCount;
  final int harshCorneringCount;
  final double distance;
  final double durationHours;
  double ecoScore;
  double safetyScore;

  DrivingTrip({
    required this.startTime,
    required this.endTime,
    required this.score,
    required this.harshBrakingCount,
    required this.harshCorneringCount,
    required this.distance,
    required this.durationHours,
    this.ecoScore = 0.0,
    this.safetyScore = 0.0,
  });
}

class DrivingBehaviorPage extends StatefulWidget {
  const DrivingBehaviorPage({Key? key}) : super(key: key);

  @override
  _DrivingBehaviorPageState createState() => _DrivingBehaviorPageState();
}

class _DrivingBehaviorPageState extends State<DrivingBehaviorPage> with SingleTickerProviderStateMixin {
  final DrivingBehaviorService _service = DrivingBehaviorService();
  List<DrivingTrip> tripHistory = [];
  late TabController _tabController;
  final List<String> _periods = ['Day', 'Week', 'Month'];
  List<FlSpot> dailyScores = [];
  List<FlSpot> weeklyScores = [];
  List<FlSpot> monthlyScores = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeChartData();
    _updateChartData();

    _service.onSensorUpdate = (accX, accY, accZ, gyroX, gyroY, gyroZ) {
      setState(() {});
    };
    _service.onPredictionUpdate = (result) {
      setState(() {});
    };
    _service.onTripCompleted = (tripData) {
      setState(() {
        tripHistory.add(DrivingTrip(
          startTime: tripData['startTime'],
          endTime: tripData['endTime'],
          score: tripData['score'],
          harshBrakingCount: tripData['harshBrakingCount'],
          harshCorneringCount: tripData['harshCorneringCount'],
          distance: tripData['distance'],
          durationHours: tripData['durationHours'],
          ecoScore: tripData['ecoScore'],
          safetyScore: tripData['safetyScore'],
        ));
        _updateChartData();
      });
    };
  }

  void _initializeChartData() {
    dailyScores = List.generate(24, (index) => FlSpot(index.toDouble(), 0));
    weeklyScores = List.generate(7, (index) => FlSpot(index.toDouble(), 0));
    monthlyScores = List.generate(30, (index) => FlSpot(index.toDouble(), 0));
  }

  void _updateChartData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('trips')
          .get();

      List<DrivingTrip> fetchedTrips = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return DrivingTrip(
          startTime: _convertToDateTime(data['tripStartTime']),
          endTime: DateTime.now(), // Adjust if endTime is stored
          score: (data['drivingScore'] as num?)?.toDouble() ?? 0.0,
          harshBrakingCount: (data['harshBrakingCount'] as int?) ?? 0,
          harshCorneringCount: (data['harshCorneringCount'] as int?) ?? 0,
          distance: (data['totalDistanceTraveled'] as num?)?.toDouble() ?? 0.0,
          durationHours: (data['tripDuration'] as num?)?.toDouble() != null
              ? (data['tripDuration'] as num).toDouble() / 3600
              : 0.0,
          ecoScore: (data['ecoScore'] as num?)?.toDouble() ?? 0.0,
          safetyScore: (data['safetyScore'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();

      setState(() {
        tripHistory = fetchedTrips;
        _processChartData();
      });
    } catch (e) {
      print("Error fetching trip data: $e");
    }
  }

  DateTime _convertToDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    } else {
      return DateTime.now();
    }
  }

  void _processChartData() {
    DateTime now = DateTime.now();

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

    var weekStart = now.subtract(Duration(days: now.weekday - 1));
    var weekTrips = tripHistory.where((trip) => trip.startTime.isAfter(weekStart));
    weeklyScores = List.generate(7, (index) {
      var dayTrips = weekTrips.where((trip) => trip.startTime.weekday == (index + 1));
      return FlSpot(
        index.toDouble(),
        dayTrips.isNotEmpty
            ? dayTrips.fold(0.0, (sum, trip) => sum + trip.score) / dayTrips.length
            : 0.0,
      );
    });

    var monthStart = DateTime(now.year, now.month, 1);
    var monthTrips = tripHistory.where((trip) => trip.startTime.isAfter(monthStart));
    monthlyScores = List.generate(30, (index) {
      var dayTrips = monthTrips.where((trip) => trip.startTime.day == (index + 1));
      return FlSpot(
        index.toDouble(),
        dayTrips.isNotEmpty
            ? dayTrips.fold(0.0, (sum, trip) => sum + trip.score) / dayTrips.length
            : 0.0,
      );
    });
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

  Map<String, double> _getPeriodScores(String period) {
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
      return {
        'ecoScore': _service.isCollecting ? _service.calculateEcoScore() : 0.0,
        'safetyScore': _service.isCollecting ? _service.calculateSafetyScore() : 0.0,
      };
    }

    double totalEcoScore = periodTrips.fold(0.0, (sum, trip) => sum + trip.ecoScore);
    double totalSafetyScore = periodTrips.fold(0.0, (sum, trip) => sum + trip.safetyScore);
    return {
      'ecoScore': totalEcoScore / periodTrips.length,
      'safetyScore': totalSafetyScore / periodTrips.length,
    };
  }

  @override
  void dispose() {
    _tabController.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
                  iconTheme: IconThemeData(color: Colors.white), // Change arrow color

        backgroundColor: Colors.blueAccent,
        elevation: 0,
        title: Text(
          'Driving Score',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2,color: Colors.white),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ), 
        bottom: TabBar(
          controller: _tabController,
          tabs: _periods.map((period) => Tab(text: period)).toList(),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.white,
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
        onPressed: _service.isCollecting ? _service.stopTracking : _service.startTracking,
        icon: Icon(_service.isCollecting ? Icons.stop : Icons.play_arrow),
        label: Text(_service.isCollecting ? 'Stop Analysis' : 'Start Analysis'),
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
          if (_service.predictionResult != 'No data' && period == 'Day') _buildPredictionsCard(),
          if (_service.predictionResult != 'No data' && period == 'Day') _buildRecommendationsCard(),
          if (_service.predictionResult != 'No data' && period == 'Day') _buildEcoSafetyScoreCards(period),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String period) {
    DrivingStats stats = _calculatePeriodStats(period);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A73E8), Color(0xFF6AB7FF)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text('$period Score', style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.9))),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: Text(
                        stats.score.isNaN ? '0' : stats.score.toInt().toString(),
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1A73E8)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Trips', stats.trips.toString(), Icons.route),
                    _buildStatItem('Hours', stats.hours.toStringAsFixed(1), Icons.timer),
                    _buildStatItem('Distance', '${stats.distance.toInt()} km', Icons.straighten),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF1A73E8)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[600])),
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
            Text('Current Readings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildSensorRow('Accelerometer X', _service.accX),
            _buildSensorRow('Accelerometer Y', _service.accY),
            _buildSensorRow('Accelerometer Z', _service.accZ),
            Divider(),
            _buildSensorRow('Gyroscope X', _service.gyroX),
            _buildSensorRow('Gyroscope Y', _service.gyroY),
            _buildSensorRow('Gyroscope Z', _service.gyroZ),
          ],
        ),
      ),
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

  Widget _buildPerformanceChart(String period, List<FlSpot> scores) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$period Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Container(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
                    getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (period == 'Day') {
                            return Text('${value.toInt()}h', style: TextStyle(color: Colors.grey[600], fontSize: 12));
                          } else if (period == 'Week') {
                            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            return Text(days[value.toInt()], style: TextStyle(color: Colors.grey[600], fontSize: 12));
                          } else {
                            return Text((value.toInt() + 1).toString(), style: TextStyle(color: Colors.grey[600], fontSize: 12));
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        reservedSize: 28,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.withOpacity(0.2))),
                  lineBarsData: [
                    LineChartBarData(
                      spots: scores,
                      isCurved: true,
                      color: Color(0xFF1A73E8),
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Color(0xFF1A73E8),
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [Color(0xFF1A73E8).withOpacity(0.3), Color(0xFF1A73E8).withOpacity(0.0)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
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
    List<DrivingTrip> periodTrips = tripHistory.where((trip) {
      DateTime now = DateTime.now();
      if (period == 'Day') {
        return trip.startTime.day == now.day && trip.startTime.month == now.month && trip.startTime.year == now.year;
      } else if (period == 'Week') {
        return trip.startTime.isAfter(now.subtract(Duration(days: now.weekday - 1)));
      } else {
        return trip.startTime.month == now.month && trip.startTime.year == now.year;
      }
    }).toList();

    int periodHarshBraking = periodTrips.fold(0, (sum, trip) => sum + trip.harshBrakingCount);
    int periodHarshCornering = periodTrips.fold(0, (sum, trip) => sum + trip.harshCorneringCount);
    double periodSpeeding = _service.isCollecting ? _service.speedingScore : 0.0;
    double periodPhoneUsage = _service.isCollecting ? _service.phoneUsageScore : 0.0;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Behavior Metrics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildMetricRow('Harsh Braking', _service.isCollecting ? _service.harshBrakingCount : periodHarshBraking, Colors.orange),
            _buildMetricRow('Harsh Cornering', _service.isCollecting ? _service.harshCorneringCount : periodHarshCornering, Colors.blue),
            _buildMetricRow('Speeding', periodSpeeding, Colors.green),
            _buildMetricRow('Phone Usage', periodPhoneUsage, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, dynamic value, Color color) {
    double percentage = value is int ? value / 50 : value.toDouble();
    Color darkColor = HSLColor.fromColor(color).withLightness((HSLColor.fromColor(color).lightness - 0.2).clamp(0.0, 1.0)).toColor();
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkColor)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  value is int ? '$value' : '${(percentage * 100).toInt()}%',
                  style: TextStyle(fontWeight: FontWeight.w600, color: color),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
              ),
              FractionallySizedBox(
                widthFactor: percentage.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, darkColor], begin: Alignment.centerLeft, end: Alignment.centerRight),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsCard() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment_rounded, color: Colors.blueAccent, size: 24),
                SizedBox(width: 10),
                Text('Predictions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent.shade700)),
              ],
            ),
            Divider(color: Colors.blueAccent.withOpacity(0.1), thickness: 2, height: 30),
            _buildPredictionItem('Current Trip Prediction:', _service.predictionResult, icon: Icons.trending_up_rounded, isMain: true),
            SizedBox(height: 16),
            _buildPredictionItem('Harsh Braking:', _service.harshBrakingCount.toString(), icon: Icons.speed_rounded),
            SizedBox(height: 12),
            _buildPredictionItem('Harsh Cornering:', _service.harshCorneringCount.toString(), icon: Icons.turn_slight_right_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionItem(String label, String value, {required IconData icon, bool isMain = false}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(isMain ? 0.15 : 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.blueAccent, size: isMain ? 22 : 18),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isMain ? 18 : 16,
                  fontWeight: isMain ? FontWeight.bold : FontWeight.w600,
                  color: isMain ? Colors.blueAccent.shade700 : Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsCard() {
    final recommendations = _generateRecommendations(_service.predictionResult);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Color(0xFFFFA000)),
                SizedBox(width: 8),
                Text('Recommendations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Divider(),
            SizedBox(height: 8),
            ...recommendations.map((rec) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Color(0xFF1A73E8).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.check_circle_outline, color: Color(0xFF1A73E8), size: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(child: Text(rec, style: TextStyle(fontSize: 16, height: 1.4))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  List<String> _generateRecommendations(String prediction) {
    if (_service.harshBrakingCount > 3) {
      return [
        'Try to anticipate stops by looking further ahead.',
        'Maintain a safe following distance to avoid sudden braking.',
        'Gradually apply brakes when approaching traffic lights or stop signs.',
      ];
    } else if (_service.harshCorneringCount > 2) {
      return [
        'Reduce your speed before entering corners.',
        'Use both hands on the steering wheel for better control.',
        'Avoid sudden steering movements.',
      ];
    } else if (_service.speedingScore > 0.2) {
      return [
        'Observe speed limits for better fuel efficiency and safety.',
        'Use cruise control on highways to maintain consistent speed.',
        'Plan your journey to avoid rushing.',
      ];
    } else if (_service.phoneUsageScore > 0.1) {
      return [
        'Put your phone on Do Not Disturb mode while driving.',
        'Use hands-free systems if you need to take calls.',
        'Pull over safely if you need to use your phone.',
      ];
    }

    switch (prediction) {
      case 'Aggressive Driving':
        return [
          'Practice smooth acceleration and deceleration.',
          'Leave earlier to avoid rushing.',
          'Take deep breaths when feeling stressed while driving.',
        ];
      case 'Distracted Driving':
        return [
          'Keep your phone out of reach while driving.',
          'Set up your navigation before starting your journey.',
          'Avoid eating or multitasking while driving.',
        ];
      default:
        return [
          'Great job! Continue your safe driving habits.',
          'Consider taking breaks on longer journeys.',
          'Stay hydrated and alert while driving.',
        ];
    }
  }

  Widget _buildEcoSafetyScoreCards(String period) {
    Map<String, double> scores = _getPeriodScores(period);
    double ecoScore = scores['ecoScore'] ?? 0.0;
    double safetyScore = scores['safetyScore'] ?? 0.0;

    Color getScoreColor(double score) {
      if (score >= 80) return Colors.green;
      if (score >= 60) return Colors.amber;
      return Colors.redAccent;
    }

    String formatScore(double score) => score.toInt().toString();

    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Eco Score', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                      Icon(Icons.eco, color: getScoreColor(ecoScore)),
                    ],
                  ),
                  SizedBox(height: 12),
                  CircularProgressIndicator(
                    value: ecoScore / 100,
                    backgroundColor: Colors.green.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(getScoreColor(ecoScore)),
                    strokeWidth: 10,
                  ),
                  SizedBox(height: 12),
                  Text(formatScore(ecoScore), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(_getEcoScoreDescription(ecoScore), style: TextStyle(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Safety Score', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                      Icon(Icons.shield, color: getScoreColor(safetyScore)),
                    ],
                  ),
                  SizedBox(height: 12),
                  CircularProgressIndicator(
                    value: safetyScore / 100,
                    backgroundColor: Color(0xFF1A73E8).withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(getScoreColor(safetyScore)),
                    strokeWidth: 10,
                  ),
                  SizedBox(height: 12),
                  Text(formatScore(safetyScore), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(_getSafetyScoreDescription(safetyScore), style: TextStyle(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getEcoScoreDescription(double score) {
    if (score >= 85) return 'Excellent fuel efficiency';
    if (score >= 70) return 'Good fuel efficiency';
    if (score >= 50) return 'Average fuel efficiency';
    return 'Needs improvement';
  }

  String _getSafetyScoreDescription(double score) {
    if (score >= 85) return 'Very safe driving';
    if (score >= 70) return 'Safe driving';
    if (score >= 50) return 'Average safety';
    return 'Safety concerns';
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