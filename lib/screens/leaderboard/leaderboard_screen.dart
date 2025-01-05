import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/firebase_service.dart';
import '../../widgets/leaderboard/leaderboard_filter.dart';
import '../../widgets/leaderboard/leaderboard_item.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String selectedMetric = 'safetyScore';
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leaderboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          LeaderboardFilter(
            selectedMetric: selectedMetric,
            onMetricChanged: (value) {
              setState(() => selectedMetric = value);
            },
          ),
          Expanded(
            child: StreamBuilder<List<UserProfile>>(
              stream: _firebaseService.getLeaderboard(
                metric: selectedMetric,
              ),
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
                    child: CircularProgressIndicator(),
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

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Filter Leaderboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: selectedMetric,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: 'safetyScore',
                  child: Text('Safety Score'),
                ),
                DropdownMenuItem(
                  value: 'ecoScore',
                  child: Text('Eco Score'),
                ),
                DropdownMenuItem(
                  value: 'totalDistance',
                  child: Text('Total Distance'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedMetric = value);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
