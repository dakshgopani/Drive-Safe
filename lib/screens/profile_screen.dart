import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'profile_setup_page.dart';

class UserData {
  final Map<String, dynamic> data;

  UserData(this.data);
}

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String email;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.email,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  Stream<UserData> getUserStream() {
    return _firestore
        .collection('users')
        .doc(user?.uid)
        .snapshots()
        .asyncMap((userSnapshot) async {
      final userData = userSnapshot.data() as Map<String, dynamic>? ?? {};

      // Fetch trips subcollection
      final tripsSnapshot = await _firestore
          .collection('users')
          .doc(user?.uid)
          .collection('trips')
          .get();

      // Calculate driving stats
      double totalDistance = 0;
      int totalTrips = tripsSnapshot.docs.length;
      double totalHoursDriven = 0;
      Set<String> uniqueRoutes = {};

      for (var trip in tripsSnapshot.docs) {
        final tripData = trip.data();
        totalDistance += double.parse(tripData['totalDistance'] ?? '0')/1000;
        totalHoursDriven += (tripData['tripDuration'] as num? ?? 0) / 60;
        uniqueRoutes
            .add('${tripData['startLocation']} - ${tripData['destination']}');
      }

      // Update userData with calculated stats
      userData['drivingStats'] = {
        'Total Distance': '${totalDistance.toStringAsFixed(2)} km',
        'Hours Driven': '${totalHoursDriven.toStringAsFixed(2)} hrs',
        // 'Favorite Routes': '${uniqueRoutes.length}',
        'Favorite Routes': '${userData['favoriteRoutes']?.length ?? 0}',
        'Total Trips': '$totalTrips',
      };

      return UserData(userData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserData>(
      stream: getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.blueAccent,
              ),
            ),
          );
        }

        final userData = snapshot.data?.data ?? {};

        // Extract user data with fallbacks
        final name = userData['name'] ?? widget.userName;
        final email = userData['email'] ?? widget.email;
        final phone = userData['phone'] ?? 'Not set';
        final carCompany = userData['carMake'] ?? 'Not set';
        final carModel = userData['carModel'] ?? 'Not set';
        final carNumber = userData['carNumber'] ?? 'Not set';

        // Extract driving statistics
        final drivingStats = userData['drivingStats'] ??
            {
              'Total Distance': '0 km',
              'Hours Driven': '0 hrs',
              'Favorite Routes': '0',
              'Total Trips': '0',
            };

        // Extract achievements
        final achievements = (userData['achievements'] as List<dynamic>? ?? [])
            .map((achievement) => Achievement(
          title: achievement['title'] ?? '',
          description: achievement['description'] ?? '',
          icon: _getIconData(achievement['icon'] ?? 'stars'),
          color: _getColor(achievement['color'] ?? 'amber'),
        ))
            .toList();

        if (achievements.isEmpty) {
          achievements.addAll([
            Achievement(
              title: 'New Driver',
              description: 'Started your driving journey',
              icon: Icons.directions_car,
              color: Colors.blue,
            ),
          ]);
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildAppBar(name),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildProfileHeader(name, email),
                    _buildInfoSection(context, phone, email),
                    _buildCarDetails(context, carCompany, carModel, carNumber),
                    _buildDrivingStats(drivingStats),
                    _buildAchievements(achievements),
                    _buildRecentActivity(userData['recentActivity']),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(String name) {
    return SliverAppBar(
      expandedHeight: 50,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text("User Profile")
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.2, end: 0),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.blueAccent,
                const Color.fromARGB(255, 129, 168, 235).withOpacity(0.5),
              ],
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // Navigate to profile setup for editing
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => ProfileSetupScreen(userId: user?.uid ?? ''),
            //   ),
            // );
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Hero(
            tag: 'profile-avatar',
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent.withOpacity(0.1),
              child: Text(
                name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn().scale(),
          const SizedBox(height: 8),
          Text(
            email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ).animate().fadeIn().scale(),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String phone, String email) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoItem(
                context,
                icon: Icons.phone,
                title: 'Phone',
                value: phone,
              ),
              const Divider(height: 32),
              _buildInfoItem(
                context,
                icon: Icons.email,
                title: 'Email',
                value: email,
              ),
            ],
          ),
        ),
      ),
    ).animate().slideX();
  }

  Widget _buildCarDetails(
      BuildContext context,
      String carCompany,
      String carModel,
      String carNumber,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vehicle Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoItem(
                context,
                icon: Icons.car_repair,
                title: 'Car Company',
                value: carCompany,
              ),
              const Divider(height: 32),
              _buildInfoItem(
                context,
                icon: Icons.directions_car,
                title: 'Car Model',
                value: carModel,
              ),
              const Divider(height: 32),
              _buildInfoItem(
                context,
                icon: Icons.numbers,
                title: 'Car Number',
                value: carNumber,
              ),
            ],
          ),
        ),
      ),
    ).animate().slideX(delay: 100.ms);
  }

  Widget _buildDrivingStats(Map<String, String> drivingStats) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: drivingStats.length,
        itemBuilder: (context, index) {
          String key = drivingStats.keys.elementAt(index);
          String value = drivingStats[key]!;
          return _buildStatCard(key, value, index);
        },
      ),
    );
  }

  Widget _buildAchievements(List<Achievement> achievements) {
    if (achievements.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Achievements',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              return _buildAchievementCard(achievements[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(List<dynamic>? activities) {
    final List<Map<String, dynamic>> recentActivities =
    (activities as List<dynamic>? ?? []).map((activity) {
      return {
        'title': activity['title'] ?? 'Unknown Activity',
        'subtitle': activity['subtitle'] ?? '',
        'time': activity['time'] ?? 'Recently',
        'icon': _getIconData(activity['icon'] ?? 'location_on'),
      };
    }).toList();

    if (recentActivities.isEmpty) {
      recentActivities.add({
        'title': 'Welcome!',
        'subtitle': 'Start your driving journey',
        'time': 'Just now',
        'icon': Icons.waving_hand,
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentActivities.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final activity = recentActivities[index];
            return _buildActivityItem(activity, index);
          },
        ),
      ],
    );
  }

  // Helper methods
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'stars':
        return Icons.stars;
      case 'explore':
        return Icons.explore;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'location_on':
        return Icons.location_on;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'favorite':
        return Icons.favorite;
      default:
        return Icons.star;
    }
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'amber':
        return Colors.amber;
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  // Existing widget building methods remain the same
  Widget _buildInfoItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
      }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueAccent.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(
      delay: Duration(milliseconds: 100 * index),
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, int index) {
    return Container(
      width: 140,
      margin: const EdgeInsets.all(4),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                achievement.icon,
                size: 40,
                color: achievement.color,
              ),
              const SizedBox(height: 12),
              Text(
                achievement.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                achievement.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate().slideX(
      begin: 0.2,
      end: 0,
      delay: Duration(milliseconds: 100 * index),
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            activity['icon'] as IconData,
            color: Colors.blueAccent,
          ),
        ),
        title: Text(activity['title'] as String),
        subtitle: Text(activity['subtitle'] as String),
        trailing: Text(
          activity['time'] as String,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ),
    ).animate().slideX(
      begin: 0.2,
      end: 0,
      delay: Duration(milliseconds: 100 * index),
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Add start driving functionality
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.blueAccent,
            ),
            child: const Text(
              'Start Driving',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              // Add view history functionality
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'View History',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(delay: 200.ms);
  }
}

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}