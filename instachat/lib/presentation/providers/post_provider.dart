import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/post_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/cache_service.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/storage_service.dart';

import '../widgets/post/comment_bottom_sheet.dart';
import '../widgets/post/post_card.dart';
import 'activity_tracker_provider.dart';

part 'post_provider.g.dart';

// Provider for LocalStorageService
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

// Provider for StorageService (file/media operations)
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

@riverpod
class PostFeedNotifier extends AutoDisposeAsyncNotifier<List<PostModel>> {
  ApiService get _api => ApiService();

  @override
  FutureOr<List<PostModel>> build() async {
    return await _api.getFeed(page: 1, limit: 20);
  }

  // Load more posts (pagination)
  Future<void> loadMore() async {
    final currentPosts = state.value ?? [];
    final nextPage = (currentPosts.length ~/ 20) + 1;

    try {
      final newPosts = await _api.getFeed(page: nextPage, limit: 20);
      state = AsyncValue.data([...currentPosts, ...newPosts]);
    } catch (e) {
      // Keep current state on error
    }
  }

  // Like a post
  Future<void> likePost(String postId) async {
    final currentPost = state.value?.firstWhere((post) => post.id == postId);
    if (currentPost == null) return;

    final wasLiked = currentPost.isLiked;

    // 1. Optimistic update in UI
    final updatedPost = currentPost.copyWith(
      isLiked: !wasLiked,
      likesCount: wasLiked ? currentPost.likesCount - 1 : currentPost.likesCount + 1,
    );

    state = AsyncValue.data(
      state.value!.map((post) => post.id == postId ? updatedPost : post).toList(),
    );

    // 2. Sync with server
    try {
      if (wasLiked) {
        await _api.unlikePost(postId);
      } else {
        await _api.likePost(postId);
      }
      ref.read(activityTrackerProvider.notifier).trackPostLike(postId);
    } catch (e) {
      // 3. Revert on error
      state = AsyncValue.data(
        state.value!.map((post) => post.id == postId ? currentPost : post).toList(),
      );
    }
  }

  // Refresh feed manually
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final posts = await _api.getFeed(page: 1, limit: 20);
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}



// ============================================
// 🎓 USING ASYNC PROVIDERS IN WIDGETS
// ============================================

class FeedScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postFeedNotifierProvider);

    return postsAsync.when(
      // ⏳ LOADING: Show loading indicator
      loading: () => const Center(child: CircularProgressIndicator()),

      // ❌ ERROR: Show error message
      error: (error, stack) => Center(
        child: Column(
          children: [
            Text('Error: $error'),
            ElevatedButton(
              onPressed: () {
                // Retry
                ref.invalidate(postFeedNotifierProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),

      // ✅ DATA: Show posts
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(child: Text('No posts yet'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Pull to refresh
            await ref.read(postFeedNotifierProvider.notifier).refresh();
          },
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                post: post,
                onLike: () {
                  ref.read(postFeedNotifierProvider.notifier).likePost(post.id);
                },
                onComment: () {
                  CommentBottomSheet.show(context, post);
                },
                onShare: () {
                  // TODO: Implement share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share functionality coming soon!')),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
