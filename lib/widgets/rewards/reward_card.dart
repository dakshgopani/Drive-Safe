import 'package:flutter/material.dart';

import '../../models/rewards.dart';

class RewardCard extends StatelessWidget {
  final Reward reward;
  final bool isUnlocked;
  final VoidCallback onRedeem;

  const RewardCard({super.key, 
    required this.reward,
    required this.isUnlocked,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(reward.imageUrl),
        title: Text(reward.title),
        subtitle: Text(reward.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${reward.pointsRequired} Points'),
            IconButton(
              icon: const Icon(Icons.redeem),
              onPressed: isUnlocked ? onRedeem : null,
              disabledColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}