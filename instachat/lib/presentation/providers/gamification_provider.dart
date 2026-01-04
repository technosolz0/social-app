import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_model.dart';
import '../../data/models/gamification_model.dart';
import '../../data/services/api_service.dart';

// Simple gamification provider
final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, AsyncValue<GamificationModel>>((
      ref,
    ) {
      return GamificationNotifier();
    });

class GamificationNotifier
    extends StateNotifier<AsyncValue<GamificationModel>> {
  GamificationNotifier() : super(const AsyncValue.loading()) {
    _loadGamificationData();
  }

  Future<void> _loadGamificationData() async {
    try {
      final apiService = ApiService();

      // Get user points and level
      final pointsResponse = await apiService.customRequest(
        method: 'GET',
        path: '/api/v1/gamification/points',
      );

      // Get user badges
      final badgesResponse = await apiService.customRequest(
        method: 'GET',
        path: '/api/v1/gamification/badges',
      );

      final data = GamificationModel(
        totalPoints: pointsResponse.data['total_points'] ?? 0,
        currentLevel: pointsResponse.data['current_level'] ?? 1,
        currentStreak: pointsResponse.data['current_streak'] ?? 0,
        badges:
            (badgesResponse.data['results'] as List<dynamic>?)
                ?.map((json) => BadgeModel.fromJson(json))
                .toList() ??
            [],
      );

      state = AsyncValue.data(data);
    } catch (e) {
      // Return default data if API fails
      final data = GamificationModel(
        totalPoints: 0,
        currentLevel: 1,
        currentStreak: 0,
        badges: [],
      );
      state = AsyncValue.data(data);
    }
  }

  // Award points for various activities
  Future<void> awardPoints(String activityType, int points) async {
    final currentData = state.value;
    if (currentData == null) return;

    final newPoints = currentData.totalPoints + points;
    final newLevel = _calculateLevel(newPoints);

    final updatedData = GamificationModel(
      totalPoints: newPoints,
      currentLevel: newLevel,
      currentStreak: currentData.currentStreak,
      badges: currentData.badges,
    );

    state = AsyncValue.data(updatedData);

    // Sync with backend
    try {
      final apiService = ApiService();
      await apiService.customRequest(
        method: 'POST',
        path: '/api/v1/gamification/points',
        data: {'activity_type': activityType, 'points': points},
      );
    } catch (e) {
      // Revert on error
      state = AsyncValue.data(currentData);
    }
  }

  // Update streak
  Future<void> updateStreak(int newStreak) async {
    final currentData = state.value;
    if (currentData == null) return;

    final updatedData = GamificationModel(
      totalPoints: currentData.totalPoints,
      currentLevel: currentData.currentLevel,
      currentStreak: newStreak,
      badges: currentData.badges,
    );

    state = AsyncValue.data(updatedData);

    // Sync with backend
    try {
      final apiService = ApiService();
      await apiService.customRequest(
        method: 'PATCH',
        path: '/api/v1/gamification/streak',
        data: {'streak': newStreak},
      );
    } catch (e) {
      // Revert on error
      state = AsyncValue.data(currentData);
    }
  }

  // Award badge
  Future<void> awardBadge(BadgeModel badge) async {
    final currentData = state.value;
    if (currentData == null) return;

    final updatedBadges = [...currentData.badges, badge];
    final updatedData = GamificationModel(
      totalPoints: currentData.totalPoints,
      currentLevel: currentData.currentLevel,
      currentStreak: currentData.currentStreak,
      badges: updatedBadges,
    );

    state = AsyncValue.data(updatedData);

    // Sync with backend
    try {
      final apiService = ApiService();
      await apiService.customRequest(
        method: 'POST',
        path: '/api/v1/gamification/badges',
        data: badge.toJson(),
      );
    } catch (e) {
      // Revert on error
      state = AsyncValue.data(currentData);
    }
  }

  // Get leaderboard
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final apiService = ApiService();
      final response = await apiService.customRequest(
        method: 'GET',
        path: '/api/v1/gamification/leaderboard',
      );
      return List<Map<String, dynamic>>.from(response.data['results'] ?? []);
    } catch (e) {
      return [];
    }
  }

  // Get user quests/challenges
  Future<List<Map<String, dynamic>>> getQuests() async {
    try {
      final apiService = ApiService();
      final response = await apiService.customRequest(
        method: 'GET',
        path: '/api/v1/gamification/quests',
      );
      return List<Map<String, dynamic>>.from(response.data['results'] ?? []);
    } catch (e) {
      return [];
    }
  }

  int _calculateLevel(int points) {
    // Simple level calculation: every 250 points = 1 level
    return (points / 250).floor() + 1;
  }

  // Refresh data from server
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadGamificationData();
  }
}

// Provider for leaderboard
final leaderboardProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  final gamificationNotifier = ref.watch(gamificationProvider.notifier);
  return gamificationNotifier.getLeaderboard();
});

// Provider for quests
final questsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  final gamificationNotifier = ref.watch(gamificationProvider.notifier);
  return gamificationNotifier.getQuests();
});
