import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/firebase_service.dart';
import '../../widgets/leaderboard/leaderboard_filter.dart';
import '../../widgets/leaderboard/leaderboard_item.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String selectedMetric = 'safetyScore';
  String? selectedRegion;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          LeaderboardFilter(
            selectedMetric: selectedMetric,
            selectedRegion: selectedRegion,
            onMetricChanged: (value) {
              setState(() => selectedMetric = value);
            },
            onRegionChanged: (value) {
              setState(() => selectedRegion = value);
            },
          ),
          Expanded(
            child: StreamBuilder<List<UserProfile>>(
              stream: _firebaseService.getLeaderboard(
                metric: selectedMetric,
                region: selectedRegion,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final users = snapshot.data!;
                
                return ListView.builder(
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
        title: const Text('Filter Leaderboard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: selectedMetric,
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
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}