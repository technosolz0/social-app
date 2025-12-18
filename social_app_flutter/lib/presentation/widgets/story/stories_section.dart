import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'story_circle.dart';

// Mock story model
class StoryModel {
  final String id;
  final UserModel user;
  final bool isViewed;

  const StoryModel({
    required this.id,
    required this.user,
    this.isViewed = false,
  });
}

// Mock user model for stories
class UserModel {
  final String id;
  final String username;
  final String? avatar;

  const UserModel({
    required this.id,
    required this.username,
    this.avatar,
  });
}

// Mock stories provider
final storiesProvider = StateNotifierProvider<StoriesNotifier, AsyncValue<List<StoryModel>>>(
  (ref) => StoriesNotifier(),
);

class StoriesNotifier extends StateNotifier<AsyncValue<List<StoryModel>>> {
  StoriesNotifier() : super(const AsyncValue.loading()) {
    _loadStories();
  }

  Future<void> _loadStories() async {
    // Mock loading
    await Future.delayed(const Duration(seconds: 1));
    state = AsyncValue.data([
      StoryModel(
        id: '1',
        user: UserModel(id: '1', username: 'alice', avatar: 'https://picsum.photos/50'),
      ),
      StoryModel(
        id: '2',
        user: UserModel(id: '2', username: 'bob', avatar: 'https://picsum.photos/51'),
      ),
    ]);
  }
}

// ============================================
// lib/presentation/widgets/story/stories_section.dart
// 🎨 STORIES HORIZONTAL LIST
// ============================================

class StoriesSection extends ConsumerWidget {
  const StoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(storiesProvider);

    return storiesAsync.when(
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (stories) {
        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: stories.length + 1, // +1 for "Your Story"
            itemBuilder: (context, index) {
              if (index == 0) {
                // Your story
                return YourStoryCircle(
                  onTap: () {
                    // context.push('/create-story');
                  },
                );
              }

              final story = stories[index - 1];
              return StoryCircle(
                story: story,
                onTap: () {
                  // Track story view
                  // ref.read(activityTrackerProvider)
                  //     .trackStoryView(story.id);

                  // context.push('/story/${story.id}');
                },
              );
            },
          ),
        );
      },
    );
  }
}

// Your story circle
class YourStoryCircle extends StatelessWidget {
  final VoidCallback onTap;

  const YourStoryCircle({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 2),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(2),
                child: const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.add, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 4),
            const SizedBox(
              width: 70,
              child: Text(
                'Your story',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
