import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/post_model.dart';
import '../../data/services/api_service.dart';

// Reels Provider
final reelsProvider = StateNotifierProvider<ReelsNotifier, AsyncValue<List<PostModel>>>((ref) {
  return ReelsNotifier();
});

class ReelsNotifier extends StateNotifier<AsyncValue<List<PostModel>>> {
  final ApiService _api = ApiService();

  ReelsNotifier() : super(const AsyncValue.loading()) {
    loadReels();
  }

  Future<void> loadReels() async {
    state = const AsyncValue.loading();
    try {
      // Fetch reels (posts with type 'reel' or 'video')
      final reels = await _api.getFeed(page: 1, limit: 20);
      // Filter for video/reel posts
      final reelPosts = reels.where((post) =>
        post.postType == 'video' || post.postType == 'reel').toList();
      state = AsyncValue.data(reelPosts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Load more reels
  Future<void> loadMore() async {
    final currentReels = state.value ?? [];
    final nextPage = (currentReels.length ~/ 20) + 1;

    try {
      final newPosts = await _api.getFeed(page: nextPage, limit: 20);
      final newReels = newPosts.where((post) =>
        post.postType == 'video' || post.postType == 'reel').toList();
      state = AsyncValue.data([...currentReels, ...newReels]);
    } catch (e) {
      // Keep current state on error
    }
  }

  // Like a reel
  Future<void> likeReel(String reelId) async {
    final currentReels = state.value ?? [];
    final reelIndex = currentReels.indexWhere((reel) => reel.id == reelId);

    if (reelIndex == -1) return;

    final reel = currentReels[reelIndex];
    final wasLiked = reel.isLiked;

    // Optimistic update
    final updatedReel = reel.copyWith(
      isLiked: !wasLiked,
      likesCount: wasLiked ? reel.likesCount - 1 : reel.likesCount + 1,
    );

    state = AsyncValue.data(
      currentReels.map((r) => r.id == reelId ? updatedReel : r).toList(),
    );

    // Sync with server
    try {
      if (wasLiked) {
        await _api.unlikePost(reelId);
      } else {
        await _api.likePost(reelId);
      }
    } catch (e) {
      // Revert on error
      state = AsyncValue.data(
        currentReels.map((r) => r.id == reelId ? reel : r).toList(),
      );
    }
  }

  // Follow user from reel
  Future<void> followUser(String userId) async {
    try {
      await _api.followUser(userId);
      // Update UI to show user is followed
      // This would require updating the user data in the reels
    } catch (e) {
      // Handle error
    }
  }

  // Refresh reels
  Future<void> refresh() async {
    await loadReels();
  }
}

// Provider for current reel index
final currentReelIndexProvider = StateProvider<int>((ref) => 0);
