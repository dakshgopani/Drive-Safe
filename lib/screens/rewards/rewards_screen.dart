import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/rewards.dart';
import '../../models/user_profile.dart';
import '../../services/firebase_service.dart';
import '../../widgets/rewards/reward_card.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    final userProfile = Provider.of<UserProfile>(context);
    final firebaseService = Provider.of<FirebaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top section with points and history button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Icon(Icons.star, size: 40),
                    Text('${userProfile.points} Points'),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to history screen
                    // ...
                  },
                  child: const Text('History'),
                ),
              ],
            ),
            // All Rewards section
            Expanded(
              child: FutureBuilder<List<Reward>>(
                future: firebaseService.getAllRewards(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading rewards'));
                  } else if (snapshot.hasData) {
                    final rewards = snapshot.data!;
                    return ListView.builder(
                      itemCount: rewards.length,
                      itemBuilder: (context, index) {
                        final reward = rewards[index];
                        return RewardCard(
                          reward: reward,
                          isUnlocked: userProfile.unlockedRewards.contains(reward.id),
                          onRedeem: () async {
                            if (userProfile.points >= reward.pointsRequired) {
                              try {
                                userProfile.points -= reward.pointsRequired;
                                userProfile.unlockedRewards.add(reward.id);

                                await firebaseService.updateUserProfile(userProfile);

                                Provider.of<UserProfile>(context, listen: false).update(userProfile);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Reward redeemed successfully!'),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error redeeming reward: $e'),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Insufficient points to redeem this reward.'),
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('Something went wrong'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}