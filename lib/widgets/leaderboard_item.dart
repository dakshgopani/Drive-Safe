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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getGradientColors(rank),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Hero(
            tag: 'user_avatar_${user.displayName}',
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(user.photoUrl),
                  backgroundColor: Colors.white,
                ),
                if (rank <= 3)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.star,
                        color: _getRankColor(rank),
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          title: Text(
            user.displayName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            _getMetricValue(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          trailing: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
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
        return Colors.blueAccent;
    }
  }

  List<Color> _getGradientColors(int rank) {
    switch (rank) {
      case 1:
        return [Colors.amber.shade300, Colors.amber.shade600];
      case 2:
        return [Colors.grey.shade400, Colors.grey.shade600];
      case 3:
        return [Colors.brown.shade300, Colors.brown.shade500];
      default:
        return [Colors.blueAccent.shade200, Colors.blueAccent.shade400];
    }
  }
}