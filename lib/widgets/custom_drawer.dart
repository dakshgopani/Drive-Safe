import 'package:algorithm_avengers_ves_final/screens/drawer/car_game_page.dart';
import 'package:algorithm_avengers_ves_final/screens/drawer/community_chat_screen.dart';
import 'package:algorithm_avengers_ves_final/screens/drawer/driving_behaviour_analysis.dart';
import 'package:algorithm_avengers_ves_final/screens/drawer/insurance/policy_list_page.dart';
import 'package:algorithm_avengers_ves_final/screens/drawer/leaderboard_screen.dart';
import 'package:algorithm_avengers_ves_final/screens/drawer/settings_screen.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String userName;
  final String email;
  final VoidCallback onSignOut;

  const CustomDrawer({
    Key? key,
    required this.userName,
    required this.email,
    required this.onSignOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName, style: const TextStyle(fontSize: 18)),
            accountEmail: Text(email, style: const TextStyle(fontSize: 14)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(userName[0].toUpperCase(),
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            ),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildDrawerItem(Icons.directions_car, "Driving Behaviour Analysis", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>DrivingBehaviorPage()),);
                }),
                _buildDrawerItem(Icons.leaderboard, "Leaderboard", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>LeaderboardScreen()),);
                }),
                _buildDrawerItem(Icons.record_voice_over, "Record My Drive", () {}),
                _buildDrawerItem(Icons.car_rental_rounded, "Vehicle Insurance", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>PolicyListPage()),);
                }),
                _buildDrawerItem(Icons.analytics, "Performance Insights", () {}),
                _buildDrawerItem(Icons.gamepad_outlined, "Play Simulation Games", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>CarGamePage()),);
                }),
                _buildDrawerItem(Icons.forum, "Community Chat", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>CommunityChatScreen()),);
                }),
                _buildDrawerItem(Icons.settings, "Settings", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>SettingsScreen()),);
                }),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
            onTap: onSignOut,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
