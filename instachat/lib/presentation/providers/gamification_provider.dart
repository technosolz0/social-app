import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_service.dart';
import '../../core/utils/logger.dart';
import '../../data/models/gamification_model.dart';

// State class for gamification
class GamificationState {
  final int totalPoints;
  final int currentLevel;
  final int nextLevelThreshold;
  final double levelProgress;
  final List<BadgeModel> badges;
  final int currentStreak;
  final bool isLoading;

  const GamificationState({
    this.totalPoints = 0,
    this.currentLevel = 1,
    this.nextLevelThreshold = 100,
    this.levelProgress = 0.0,
    this.badges = const [],
    this.currentStreak = 0,
    this.isLoading = false,
  });

  GamificationState copyWith({
    int? totalPoints,
    int? currentLevel,
    int? nextLevelThreshold,
    double? levelProgress,
    List<BadgeModel>? badges,
    int? currentStreak,
    bool? isLoading,
  }) {
    return GamificationState(
      totalPoints: totalPoints ?? this.totalPoints,
      currentLevel: currentLevel ?? this.currentLevel,
      nextLevelThreshold: nextLevelThreshold ?? this.nextLevelThreshold,
      levelProgress: levelProgress ?? this.levelProgress,
      badges: badges ?? this.badges,
      currentStreak: currentStreak ?? this.currentStreak,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Main Gamification Provider
final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, AsyncValue<GamificationState>>((
      ref,
    ) {
      return GamificationNotifier();
    });

// Leaderboard Provider
final leaderboardProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final notifier = ref.read(gamificationProvider.notifier);
  return await notifier.getLeaderboard();
});

// Quests Provider
final questsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // In a real app, you might have a dedicated service method
  // For now, we'll return mock data or simulate API call
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    {
      'id': '1',
      'title': 'First Post',
      'description': 'Create your first post to earn 50 points',
      'points': 50,
      'progress': 0,
      'target': 1,
      'completed': false,
      'category': 'creative',
    },
    {
      'id': '2',
      'title': 'Daily Login',
      'description': 'Log in every day for 7 days',
      'points': 100,
      'progress': 1,
      'target': 7,
      'completed': false,
      'category': 'daily',
    },
    {
      'id': '3',
      'title': 'Social Butterfly',
      'description': 'Follow 5 users',
      'points': 75,
      'progress': 3,
      'target': 5,
      'completed': false,
      'category': 'social',
    },
  ];
});

class GamificationNotifier
    extends StateNotifier<AsyncValue<GamificationState>> {
  GamificationNotifier() : super(const AsyncValue.loading()) {
    loadUserPoints();
  }

  Timer? _refreshTimer;
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadUserPoints() async {
    try {
      // Don't set loading if we already have data (silent refresh)
      if (!state.hasValue) {
        state = const AsyncValue.loading();
      }

      final data = await _apiService.getUserPoints();

      // Parse badges safely
      List<BadgeModel> badges = [];
      if (data['badges'] != null && data['badges'] is List) {
        try {
          badges = (data['badges'] as List)
              .map((e) => BadgeModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (e) {
          Logger.e('Error parsing badges', e);
        }
      } else if (data['recent_badges'] != null &&
          data['recent_badges'] is List) {
        // Fallback if full badge objects aren't available, we might need to mock or just specific names
        // For now, let's leave empty if full models aren't provided, or assume backend update
      }

      final newState = GamificationState(
        totalPoints: data['total_points'] ?? 0,
        currentLevel: data['current_level'] ?? 1,
        nextLevelThreshold: data['next_level_threshold'] ?? 100,
        levelProgress: (data['level_progress'] ?? 0).toDouble(),
        badges: badges,
        currentStreak: data['current_streak'] ?? 0,
        isLoading: false,
      );

      state = AsyncValue.data(newState);
    } catch (e, stack) {
      Logger.e('Failed to load user points', e, stack);
      state = AsyncValue.error(e, stack);
    }
  }

  // Determine points gained and return for animation
  Future<int> checkPointsChange() async {
    final oldPoints = state.value?.totalPoints ?? 0;
    await loadUserPoints();
    final newPoints = state.value?.totalPoints ?? 0;
    return newPoints > oldPoints ? newPoints - oldPoints : 0;
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    // Mock leaderboard data for now if API endpoint isn't ready or just return mock
    return [
      {'user_id': '1', 'username': 'Alex', 'points': 1250, 'avatar': null},
      {'user_id': '2', 'username': 'Sam', 'points': 980, 'avatar': null},
      {'user_id': '3', 'username': 'Jordan', 'points': 850, 'avatar': null},
    ];
  }

  Future<void> awardPoints(String action, int points) async {
    // Optimistic update
    if (state.hasValue) {
      final current = state.value!;
      state = AsyncValue.data(
        current.copyWith(totalPoints: current.totalPoints + points),
      );
    }
    // Notify backend if needed, or assume backend handles it via other actions
    // _apiService.awardPoints(...) if endpoint exists

    // Reload to get authoritative state
    await loadUserPoints();
  }

  void startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => loadUserPoints(),
    );
  }
}
