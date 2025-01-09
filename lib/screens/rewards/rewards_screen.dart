import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../widgets/rewards/spin_wheel_widget.dart';

class RewardsScreen extends StatefulWidget {
  @override
  _RewardsScreenState createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  List<Map<String, dynamic>> rewards = [];
  Stream<int>? selected;
  int selectedRewardIndex = -1; // Default to no selection
  int userPoints = 200; // Example user points (fetch dynamically if needed)

  @override
  void initState() {
    super.initState();
    loadRewards();
  }

  /// Fetch rewards from Firebase
  void loadRewards() async {
    try {
      final data = await FirebaseService.fetchRewardsOnce(); // Using one-time fetch
      setState(() {
        rewards = data;
      });
    } catch (e) {
      print('Error loading rewards: $e');
    }
  }

  /// Handle the end of the spin
  void handleSpinEnd(int index) {
    setState(() {
      selectedRewardIndex = index;
    });

    showDialog(
      context: context,
      builder: (_) => RewardDialog(
        reward: rewards[index],
        userPoints: userPoints,
        onRedeem: () {
          // Logic for redeeming the reward (deduct points, update Firebase, etc.)
          if (userPoints >= rewards[index]['pointsRequired']) {
            setState(() {
              // userPoints -= rewards[index]['pointsRequired']!;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Reward redeemed successfully!'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Not enough points to redeem this reward!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rewards'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blue.shade300],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: 60),
              // Points Tracker
              Padding(
                padding: const EdgeInsets.all(16.0),
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
              Expanded(
                child: rewards.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : SpinWheelWidget(
                        rewards: rewards,
                        selected: selected,
                        onSpinEnd: handleSpinEnd,
                      ),
              ),
              SizedBox(height: 20),
              // Instructions
              Text(
                'Spin the wheel to win a reward!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class RewardDialog extends StatelessWidget {
  final Map<String, dynamic> reward;
  final int userPoints;
  final VoidCallback onRedeem;

  const RewardDialog({
    Key? key,
    required this.reward,
    required this.userPoints,
    required this.onRedeem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Center(
        child: Text(
          'Congratulations!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.green,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(reward['imageUrl'], height: 100),
          SizedBox(height: 10),
          Text(
            reward['title'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(reward['description']),
          SizedBox(height: 10),
          Text(
            'Points Required: ${reward['pointsRequired']}',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              onRedeem(); // Call redeem callback
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: userPoints >= reward['pointsRequired']
                  ? Colors.green
                  : Colors.grey,
            ),
            child: Text(
              userPoints >= reward['pointsRequired'] ? 'Redeem' : 'Not Enough Points',
            ),
          ),
        ),
      ],
    );
  }
}
