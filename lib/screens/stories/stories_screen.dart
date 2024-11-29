import 'package:flutter/material.dart';
import '../../models/story.dart';
import '../../services/firebase_service.dart';
import '../../widgets/stories/story_card.dart';
import 'create_story_screen.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseService _firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driving Stories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter functionality
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Story>>(
        stream: _firebaseService.getStories(),
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

          final stories = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              return StoryCard(
                story: stories[index],
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/stories/detail',
                    arguments: stories[index],
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateStoryScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}