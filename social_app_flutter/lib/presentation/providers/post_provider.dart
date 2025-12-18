import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/post_model.dart';
import '../../data/models/user_model.dart';

part 'post_provider.g.dart';

@riverpod
class PostFeedNotifier extends _$PostFeedNotifier {
  @override
  FutureOr<List<PostModel>> build() async {
    // Fetch initial posts when provider is created
    return _fetchPosts();
  }

  // Load more posts (pagination)
  Future<void> loadMore() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final currentPosts = state.value ?? [];
      final newPosts = await _fetchPosts(page: currentPosts.length ~/ 20);
      return [...currentPosts, ...newPosts];
    });
  }

  // Like a post
  Future<void> likePost(String postId) async {
    // Optimistic update (update UI immediately)
    state = AsyncValue.data(
      state.value!.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            isLiked: !post.isLiked,
            likesCount: post.isLiked
              ? post.likesCount - 1
              : post.likesCount + 1,
          );
        }
        return post;
      }).toList(),
    );

    // Then update on server
    try {
      // await ref.read(postRepositoryProvider).likePost(postId);

      // Track activity
      // ref.read(activityTrackerProvider).trackPostLike(postId);
    } catch (e) {
      // Revert on error
      await refresh();
    }
  }

  // Refresh feed
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPosts());
  }

  Future<List<PostModel>> _fetchPosts({int page = 0}) async {
    // final repository = ref.read(postRepositoryProvider);
    // return await repository.getFeed(page: page);

    // Mock data
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    final mockUser = UserModel(
      id: '1',
      username: 'testuser',
      email: 'test@example.com',
    );

    return List.generate(
      10,
      (index) => PostModel(
        id: '${page * 20 + index}',
        userId: mockUser.id,
        user: mockUser,
        postType: 'photo',
        caption: 'This is a test post #${page * 20 + index}',
        mediaUrl: 'https://picsum.photos/400/400?random=${page * 20 + index}',
        hashtags: ['test', 'flutter'],
        likesCount: 42,
        commentsCount: 5,
        sharesCount: 2,
        viewsCount: 100,
        isLiked: false,
        createdAt: DateTime.now().subtract(Duration(hours: index)),
      ),
    );
  }
}

final postFeedProvider = AsyncNotifierProvider<PostFeedNotifier, List<PostModel>>(
  () => PostFeedNotifier(),
);

// ============================================
// 🎓 USING ASYNC PROVIDERS IN WIDGETS
// ============================================

class FeedScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postFeedProvider);

    return postsAsync.when(
      // ⏳ LOADING: Show loading indicator
      loading: () => Center(child: CircularProgressIndicator()),

      // ❌ ERROR: Show error message
      error: (error, stack) => Center(
        child: Column(
          children: [
            Text('Error: $error'),
            ElevatedButton(
              onPressed: () {
                // Retry
                ref.invalidate(postFeedProvider);
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),

      // ✅ DATA: Show posts
      data: (posts) {
        if (posts.isEmpty) {
          return Center(child: Text('No posts yet'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Pull to refresh
            await ref.read(postFeedProvider.notifier).refresh();
          },
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                post: post,
                onLike: () {
                  ref.read(postFeedProvider.notifier).likePost(post.id);
                },
              );
            },
          ),
        );
      },
    );
  }
}

// Mock PostCard widget
class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onLike;

  const PostCard({required this.post, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(post.user.avatar ?? 'https://picsum.photos/50'),
            ),
            title: Text(post.user.username),
            subtitle: Text(post.createdAt.toString()),
          ),
          if (post.mediaUrl.isNotEmpty)
            Image.network(post.mediaUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
          if (post.caption != null)
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(post.caption!),
            ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  post.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: post.isLiked ? Colors.red : null,
                ),
                onPressed: onLike,
              ),
              Text('${post.likesCount}'),
              SizedBox(width: 16),
              IconButton(
                icon: Icon(Icons.comment),
                onPressed: () {},
              ),
              Text('${post.commentsCount}'),
            ],
          ),
        ],
      ),
    );
  }
}
