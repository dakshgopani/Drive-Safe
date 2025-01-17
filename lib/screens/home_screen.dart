import 'package:algorithm_avengers_ves_final/screens/rewards/rewards_screen.dart';
import 'package:flutter/material.dart';
import 'forum/forum_screen.dart';
import 'leaderboard/leaderboard_screen.dart';
import 'stories/stories_screen.dart'; 


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const ForumScreen(),
    RewardsScreen(),
    const LeaderboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.forum),
            label: 'Forum',
          ),
          // NavigationDestination(
          //   icon: Icon(Icons.auto_stories),
          //   label: 'Stories',
          // ),
          NavigationDestination(
            icon: Icon(Icons.wallet_giftcard),
            label: 'Rewards',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
        ],
      ),
    );
  }
}
