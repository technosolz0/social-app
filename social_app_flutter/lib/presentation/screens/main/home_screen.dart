import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_constants.dart';
import '../../../data/models/post_model.dart';
import '../../providers/activity_tracker_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import '../../widgets/post/post_card.dart';
import '../../widgets/story/stories_section.dart';

// ============================================
// lib/presentation/screens/main/home_screen.dart
// Instagram Feed Screen
// ============================================

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load more when reaching bottom
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(postFeedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postFeedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Instagram',
          style: TextStyle(
            fontFamily: 'Billabong',
            fontSize: 32,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Navigate to activity screen
              context.push('/activity');
            },
          ),
          IconButton(
            icon: const Icon(Icons.send_outlined),
            onPressed: () {
              // Navigate to messages
              context.push('/messages');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(postFeedProvider.notifier).refresh();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Stories Section
            const SliverToBoxAdapter(
              child: StoriesSection(),
            ),

            // Posts
            postsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => SliverToBoxAdapter(
                child: custom_error.CustomErrorWidget(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(postFeedProvider),
                ),
              ),
              data: (posts) {
                if (posts.isEmpty) {
                  return const SliverFillRemaining(
                    child: EmptyStateWidget(
                      message: 'No posts yet. Follow someone!',
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= posts.length) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final post = posts[index];
                      return PostCard(
                        post: post,
                        onLike: () {
                          ref.read(postFeedProvider.notifier).likePost(post.id);
                        },
                        onComment: () {
                          context.push('/post/${post.id}/comments');
                        },
                        onShare: () {
                          _sharePost(post);
                        },
                      );
                    },
                    childCount: posts.length + 1,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sharePost(PostModel post) {
    // Track activity
    ref.read(activityTrackerProvider).trackShare(post.id);

    // Share using share_plus
    Share.share(
      'Check out this post: ${AppConstants.baseUrl}/post/${post.id}',
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

// Mock activity tracker extension
extension on ActivityTracker {
  void trackShare(String postId) {
    // Mock implementation
  }
}
