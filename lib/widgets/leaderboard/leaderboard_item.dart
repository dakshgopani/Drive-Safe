import 'package:flutter/material.dart';
import '../../models/user_profile.dart';

class LeaderboardItem extends StatelessWidget {
  final UserProfile user;
  final int rank;
  final String metric;

  const LeaderboardItem({
    Key? key,
    required this.user,
    required this.rank,
    required this.metric,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.photoUrl),
            ),
            if (rank <= 3)
              Positioned(
                right: -4,
                top: -4,
                child: Icon(
                  Icons.star,
                  color: _getRankColor(rank),
                  size: 20,
                ),
              ),
          ],
        ),
        title: Text(user.displayName),
        subtitle: Text(_getMetricValue()),
        trailing: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _getRankColor(rank),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getMetricValue() {
    switch (metric) {
      case 'safetyScore':
        return 'Safety Score: ${user.safetyScore.toStringAsFixed(1)}';
      case 'ecoScore':
        return 'Eco Score: ${user.ecoScore.toStringAsFixed(1)}';
      case 'totalDistance':
        return 'Distance: ${user.totalDistance}km';
      default:
        return '';
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[300]!;
      default:
        return Colors.blue;
    }
  }
}