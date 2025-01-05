import 'package:flutter/material.dart';
import '../../models/user_profile.dart';

class LeaderboardItem extends StatelessWidget {
  final UserProfile user;
  final int rank;
  final String metric;

  const LeaderboardItem({
    super.key,
    required this.user,
    required this.rank,
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(user.photoUrl),
            ),
            if (rank <= 3)
              Positioned(
                right: -2,
                top: -2,
                child: Icon(
                  Icons.star,
                  color: _getRankColor(rank),
                  size: 20,
                ),
              ),
          ],
        ),
        title: Text(
          user.displayName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          _getMetricValue(),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        trailing: Container(
          width: 40,
          height: 40,
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
                fontSize: 16,
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
