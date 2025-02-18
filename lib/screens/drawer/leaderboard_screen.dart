import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/firebase_service.dart';
import '../../widgets/leaderboard_item.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String selectedMetric = 'safetyScore';
  final FirebaseService _firebaseService = FirebaseService();

  final List<Map<String, dynamic>> _metrics = [
  {'value': 'safetyScore', 'label': 'Safety Score', 'icon': Icons.security},
  {'value': 'ecoScore', 'label': 'Eco Score', 'icon': Icons.eco},
  {'value': 'totalDistance', 'label': 'Total Distance', 'icon': Icons.speed},
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Leaderboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Metrics Selector
          Container(
            height: 60,
            color: Colors.blueAccent,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _metrics.length,
              itemBuilder: (context, index) {
                final metric = _metrics[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ChoiceChip(
                    label: Row(
                      children: [
                        Icon(
                          metric['icon'] as IconData, 
                          size: 20,
                          color: selectedMetric == metric['value'] 
                            ? Colors.blueAccent 
                            : Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          metric['label']!, 
                          style: TextStyle(
                            color: selectedMetric == metric['value'] 
                              ? Colors.blueAccent 
                              : Colors.white,
                          ),
                        ),
                      ],
                    ),
                    selected: selectedMetric == metric['value'],
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() => selectedMetric = metric['value']!);
                      }
                    },
                    selectedColor: Colors.white,
                    backgroundColor: Colors.blueAccent.shade200,
                  ),
                );
              },
            ),
          ),

          // Leaderboard List
          Expanded(
            child: StreamBuilder<List<UserProfile>>(
              stream: _firebaseService.getLeaderboard(metric: selectedMetric),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blueAccent),
                  );
                }

                final users = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return LeaderboardItem(
                      user: users[index],
                      rank: index + 1,
                      metric: selectedMetric,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Leaderboard Metric',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 16),
            ..._metrics.map((metric) => ListTile(
              leading: Icon(
                metric['icon'] as IconData, 
                color: Colors.blueAccent,
              ),
              title: Text(metric['label']!),
              onTap: () {
                setState(() => selectedMetric = metric['value']!);
                Navigator.pop(context);
              },
              trailing: selectedMetric == metric['value'] 
                ? Icon(Icons.check, color: Colors.green) 
                : null,
            )),
          ],
        ),
      ),
    );
  }
}