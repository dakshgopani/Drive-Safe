import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../widgets/rewards/reward_card.dart';
import '../../models/rewards.dart';

class RewardsScreen extends StatefulWidget {
  @override
  _RewardsScreenState createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  List<Reward> rewards = [];
  int userPoints = 200; // Example user points (fetch dynamically if needed)

  @override
  void initState() {
    super.initState();
    loadRewards();
  }

  /// Fetch rewards from Firebase
  void loadRewards() async {
    try {
      final data = await FirebaseService.fetchRewardsOnce();
      setState(() {
        rewards = data;
      });
    } catch (e) {
      print('Error loading rewards: $e');
    }
  }

  /// Handle reward redemption
  void redeemReward(Reward reward) {
    if (userPoints >= reward.pointsRequired) {
      setState(() {
        userPoints -= reward.pointsRequired;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You redeemed ${reward.title}!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough points to redeem ${reward.title}!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rewards'),
        backgroundColor: Color.fromARGB(255, 126, 191, 209),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color.fromARGB(255, 126, 191, 209), const Color.fromARGB(255, 209, 222, 228)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: 20),
              // Points Tracker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Points: $userPoints',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.account_circle, color: Colors.white, size: 32),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Rewards List
              Expanded(
                child: rewards.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: rewards.length,
                        itemBuilder: (context, index) {
                          final reward = rewards[index];
                          return RewardCard(
                            reward: reward,
                            isUnlocked: userPoints >= reward.pointsRequired,
                            onRedeem: () => redeemReward(reward),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
