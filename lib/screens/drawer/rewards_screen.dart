import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scratcher/scratcher.dart';
import 'store_screen.dart';

class RewardsSystem extends StatefulWidget {
  final String userId;
  final String requestId; // ✅ Add requestId here

  const RewardsSystem({
    super.key,
    required this.userId,
    required this.requestId,
  });

  @override
  _RewardsSystemState createState() => _RewardsSystemState();

  static void showScratchCardPopup(
      BuildContext context, String userId, String requestId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          _ScratchCardDialog(userId: userId, requestId: requestId),
    );
  }
}

class _RewardsSystemState extends State<RewardsSystem> {
  bool _showScratchCard = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _showScratchCard = true;
      });
      RewardsSystem.showScratchCardPopup(
          context, widget.userId, widget.requestId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(title: const Text("Rewards & Points")),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(seconds: 1),
          child: _showScratchCard
              ? ElevatedButton(
            onPressed: () => RewardsSystem.showScratchCardPopup(
                context, widget.userId, widget.requestId),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Open Scratch Card!",
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          )
              : const Text("🎉 Stay Tuned for Your Surprise!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _ScratchCardDialog extends StatefulWidget {
  final String userId;
  final String requestId; // ✅ Store requestId properly

  const _ScratchCardDialog({required this.userId, required this.requestId});

  @override
  _ScratchCardDialogState createState() => _ScratchCardDialogState();
}

class _ScratchCardDialogState extends State<_ScratchCardDialog> {
  int? _scratchPoints;
  bool _isScratched = false;

  @override
  void initState() {
    super.initState();
    _fetchOrGenerateScratchPoints();
  }

  /// ✅ Fetches existing scratch card points or generates new ones
  Future<void> _fetchOrGenerateScratchPoints() async {
    try {
      DocumentSnapshot scratchDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('rewards')
          .doc(widget.requestId) // ✅ Use requestId as doc ID
          .get();

      if (scratchDoc.exists && scratchDoc.data() != null) {
        setState(() {
          _scratchPoints =
          (scratchDoc.data() as Map<String, dynamic>)['points'];
        });
      } else {
        _generateScratchPoints();
      }
    } catch (e) {
      print("❌ Error fetching scratch points: $e");
    }
  }

  /// ✅ Generates random scratch points (only once) and saves in Firestore
  Future<void> _generateScratchPoints() async {
    int newPoints = (Random().nextInt(10) + 1) * 10;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('rewards')
        .doc(widget.requestId) // ✅ Unique per donation
        .set({'points': newPoints});

    setState(() {
      _scratchPoints = newPoints;
    });

    print(
        "✅ Scratch Points Generated: $newPoints for Request ID: ${widget.requestId}");
  }

  /// ✅ Adds scratch points **only once per requestId**
  Future<void> _addScratchPoints(int points, String requestId) async {
    try {
      DocumentReference userRef =
      FirebaseFirestore.instance.collection('users').doc(widget.userId);

      DocumentSnapshot userDoc = await userRef.get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // ✅ Check if user already received reward for this requestId
        List<dynamic> rewardedRequests = userData['rewardedRequests'] ?? [];

        if (rewardedRequests.contains(requestId)) {
          print("⚠️ User already claimed points for requestId: $requestId");
          return;
        }

        // ✅ Add requestId to the rewarded list & update Firestore
        rewardedRequests.add(requestId);

        await userRef.update({
          'points': FieldValue.increment(points),
          'rewardedRequests': rewardedRequests,
          // 🔄 Save all rewarded donations
        });

        print("✅ Scratch Points ($points) added for requestId: $requestId!");
      }
    } catch (e) {
      print("❌ Error adding scratch points: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "🎉 Woho! Congratulations! 🎊",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("You have won a Scratch Card!",
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Scratcher(
            brushSize: 40,
            threshold: 50,
            color: Colors.grey,
            onScratchEnd: () {
              setState(() {
                _isScratched = true;
              });
              if (_scratchPoints != null) {
                _addScratchPoints(_scratchPoints!, widget.requestId);
              }
            },
            child: Container(
              width: 150,
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _isScratched ? "🎉 +$_scratchPoints Points" : "Scratch Me!",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => StoreScreen(userId: widget.userId)),
              );
              // Navigator.pushNamed(context, '/store');
            },
            child: const Text("Go to Store"),
          )
        ],
      ),
    );
  }
}
