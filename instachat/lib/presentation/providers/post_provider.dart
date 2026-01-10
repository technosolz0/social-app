import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/utils/logger.dart';
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
    try {
      Logger.d('Loading initial feed data...');
      final posts = await _api.getFeed(page: 1, limit: 20);
      Logger.i('Successfully loaded ${posts.length} posts for feed');
      return posts;
    } catch (e, stackTrace) {
      Logger.e('Failed to load initial feed data', e, stackTrace);
      // Re-throw to let Riverpod handle the error state
      rethrow;
    }
  }

  // Load more posts (pagination)
  Future<void> loadMore() async {
    final currentPosts = state.value ?? [];
    final nextPage = (currentPosts.length ~/ 20) + 1;

    try {
      Logger.d('Loading more posts - page $nextPage');
      final newPosts = await _api.getFeed(page: nextPage, limit: 20);
      Logger.i('Successfully loaded ${newPosts.length} more posts');
      state = AsyncValue.data([...currentPosts, ...newPosts]);
    } catch (e, stackTrace) {
      Logger.e('Failed to load more posts (page $nextPage)', e, stackTrace);
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
      likesCount: wasLiked
          ? currentPost.likesCount - 1
          : currentPost.likesCount + 1,
    );

    state = AsyncValue.data(
      state.value!
          .map((post) => post.id == postId ? updatedPost : post)
          .toList(),
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
        state.value!
            .map((post) => post.id == postId ? currentPost : post)
            .toList(),
      );
    }
  }

  // Create a new post
  Future<PostModel?> createPost({
    required String postType,
    required String mediaUrl,
    String? caption,
    List<String>? hashtags,
  }) async {
    try {
      Logger.d('Creating new post with type: $postType');
      final newPost = await _api.createPost(
        postType: postType,
        mediaUrl: mediaUrl,
        caption: caption,
        hashtags: hashtags,
      );

      // Add to the beginning of the feed
      final currentPosts = state.value ?? [];
      state = AsyncValue.data([newPost, ...currentPosts]);
      Logger.i('Successfully created post: ${newPost.id}');

      return newPost;
    } catch (e, stackTrace) {
      Logger.e('Failed to create post', e, stackTrace);
      // Don't update state on error
      return null;
    }
  }

  // Share a post
  Future<void> sharePost(String postId) async {
    try {
      Logger.d('Sharing post: $postId');
      await _api.sharePost(postId);
      // Update share count in local state
      final currentPosts = state.value ?? [];
      state = AsyncValue.data(
        currentPosts.map((post) {
          if (post.id == postId) {
            return post.copyWith(sharesCount: post.sharesCount + 1);
          }
          return post;
        }).toList(),
      );
      Logger.i('Successfully shared post: $postId');
    } catch (e, stackTrace) {
      Logger.e('Failed to share post: $postId', e, stackTrace);
      // Handle error
    }
  }

  // Add comment to post
  Future<void> addComment(
    String postId,
    String text, {
    String? parentId,
  }) async {
    try {
      Logger.d('Adding comment to post: $postId');
      final commentData = await _api.addPostComment(
        postId,
        text,
        parentId: parentId,
      );
      // Update comment count in local state
      final currentPosts = state.value ?? [];
      state = AsyncValue.data(
        currentPosts.map((post) {
          if (post.id == postId) {
            return post.copyWith(commentsCount: post.commentsCount + 1);
          }
          return post;
        }).toList(),
      );
      Logger.i('Successfully added comment to post: $postId');
    } catch (e, stackTrace) {
      Logger.e('Failed to add comment to post: $postId', e, stackTrace);
      // Handle error
    }
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    try {
      Logger.d('Deleting post: $postId');
      await _api.deletePost(postId);
      // Remove from local state
      final currentPosts = state.value ?? [];
      state = AsyncValue.data(
        currentPosts.where((post) => post.id != postId).toList(),
      );
      Logger.i('Successfully deleted post: $postId');
    } catch (e, stackTrace) {
      Logger.e('Failed to delete post: $postId', e, stackTrace);
      // Handle error
    }
  }

  // Refresh feed manually
  Future<void> refresh() async {
    try {
      Logger.d('Refreshing feed data...');
      state = const AsyncValue.loading();
      final posts = await _api.getFeed(page: 1, limit: 20);
      state = AsyncValue.data(posts);
      Logger.i('Successfully refreshed feed with ${posts.length} posts');
    } catch (e, stackTrace) {
      Logger.e('Failed to refresh feed data', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// ============================================
// 🎓 USING ASYNC PROVIDERS IN WIDGETS
// ============================================

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore) return;

    final notifier = ref.read(postFeedNotifierProvider.notifier);
    final currentPosts = ref.read(postFeedNotifierProvider).value ?? [];

    // Don't load more if we have less than 20 posts (likely no more data)
    if (currentPosts.length < 20) return;

    setState(() => _isLoadingMore = true);

    try {
      await notifier.loadMore();
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postFeedNotifierProvider);

    return postsAsync.when(
      // ⏳ LOADING: Show loading indicator
      loading: () => const Center(child: CircularProgressIndicator()),

      // ❌ ERROR: Show error message
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Failed to load feed',
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Retry
                ref.invalidate(postFeedNotifierProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),

      // ✅ DATA: Show posts with lazy loading
      data: (posts) {
        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.feed_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No posts yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Follow some users to see their posts here!',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Pull to refresh
            await ref.read(postFeedNotifierProvider.notifier).refresh();
          },
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: posts.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the end
              if (index == posts.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

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
                  ref
                      .read(postFeedNotifierProvider.notifier)
                      .sharePost(post.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post shared successfully!')),
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
