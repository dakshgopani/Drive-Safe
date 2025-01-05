import 'package:flutter/material.dart';
import '../../models/feedback.dart';
import '../../services/firebase_service.dart';
import '../../widgets/feedback/feedback_card.dart';
import 'create_feedback_screen.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Peer Feedback'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Received'),
              Tab(text: 'Sent'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFeedbackList(firebaseService.getReceivedFeedback()),
            _buildFeedbackList(firebaseService.getSentFeedback()),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateFeedbackScreen(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildFeedbackList(Stream<List<DrivingFeedback>> feedbackStream) {
    return StreamBuilder<List<DrivingFeedback>>(
      stream: feedbackStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final feedbackList = snapshot.data!;

        return ListView.builder(
          itemCount: feedbackList.length,
          itemBuilder: (context, index) {
            return FeedbackCard(
              feedback: feedbackList[index],
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/feedback/detail',
                  arguments: feedbackList[index],
                );
              },
            );
          },
        );
      },
    );
  }
}