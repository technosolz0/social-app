import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/logger.dart';
import '../../data/models/activity_model.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/api_service.dart';

part 'activity_tracker_provider.g.dart';

// Local Storage Service Provider
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

@riverpod
class ActivityTracker extends _$ActivityTracker {
  LocalStorageService get _storage => ref.read(localStorageServiceProvider);

  @override
  List<ActivityModel> build() {
    // Return empty list initially
    return [];
  }

  // Load activities from storage - call this after provider is built
  Future<void> loadActivities() async {
    await _loadActivitiesFromStorage();
  }

  Future<void> _loadActivitiesFromStorage() async {
    try {
      final activities = _storage.getRecentActivities(limit: 100);
      state = activities;
    } catch (e) {
      Logger.e('Failed to load activities from storage: $e');
    }
  }

  // Track different activities
  void trackPostView(String postId) {
    _track('post_view', {'post_id': postId}, postId: postId);
  }

  void trackPostLike(String postId) {
    _track('post_like', {'post_id': postId}, postId: postId);
  }

  void trackStoryView(String storyId) {
    _track('story_view', {'story_id': storyId}, storyId: storyId);
  }

  void trackSearch(String query) {
    _track('search', {'query': query});
  }

  void trackProfileView(String userId) {
    _track('profile_view', {'user_id': userId}, targetUserId: userId);
  }

  void trackMessageSent() {
    _track('message_sent', {});
  }

  void trackLogin() {
    _track('login', {});
  }

  void trackVideoWatchTime(String postId, int seconds) {
    _track('video_watch', {
      'post_id': postId,
      'watch_time': seconds,
    }, postId: postId);
  }

  // Private method to create activity
  void _track(
    String activityType,
    Map<String, dynamic> metadata, {
    String? postId,
    String? storyId,
    String? targetUserId,
  }) {
    final userId = ref.read(authNotifierProvider).user?.id ?? 'anonymous';
    
    final activity = ActivityModel(
      id: const Uuid().v4(),
      userId: userId,
      activityType: activityType,
      metadata: metadata,
      timestamp: DateTime.now(),
      postId: postId,
      storyId: storyId,
      targetUserId: targetUserId,
    );

    // Add to local state immediately for UI responsiveness
    // Using Future.microtask to avoid modifying provider during build phase
    Future.microtask(() {
      state = [...state, activity];
    });

    // Save to local storage
    _saveActivityToStorage(activity);

    // Send to server (async, fire and forget)
    _sendToServer(activity);
  }

  Future<void> _saveActivityToStorage(ActivityModel activity) async {
    try {
      await _storage.saveActivity(activity);
    } catch (e) {
      Logger.e('Failed to save activity to storage: $e');
    }
  }

  Future<void> _sendToServer(ActivityModel activity) async {
    try {
      final apiService = ApiService();
      await apiService.customRequest(
        method: 'POST',
        path: '/activities/',
        data: activity.toJson(),
      );
    } catch (e) {
      Logger.e('Failed to track activity: $e');
      // Could implement retry logic here
    }
  }

  // Sync activities with server
  Future<void> syncActivities() async {
    try {
      final unsyncedActivities = _storage.getAllActivities(); // Assuming all local are candidates for sync if not tracking sync state per item
      
      if (unsyncedActivities.isEmpty) return;

      final apiService = ApiService();
      
      // Batch sync if API supports it, otherwise sync one by one
      for (final activity in unsyncedActivities) {
        await apiService.customRequest(
          method: 'POST',
          path: '/gamification/activities/',
          data: activity.toJson(),
        );
      }

      // Update sync timestamp
      await _storage.saveLastSyncTimestamp(DateTime.now());
      Logger.i('Activities synced with server: ${unsyncedActivities.length}');

      // Optionally clear synced activities if they are only for tracking
      // await _storage.clearAllActivities();
    } catch (e) {
      Logger.e('Failed to sync activities: $e');
    }
  }

  // Get activities by type
  List<ActivityModel> getByType(String type) {
    return state.where((a) => a.activityType == type).toList();
  }

  // Get recent searches
  List<String> getRecentSearches({int limit = 10}) {
    return state
        .where((a) => a.activityType == 'search')
        .take(limit)
        .map((a) => a.metadata?['query'] as String)
        .toList();
  }

  // Get activity statistics
  Map<String, int> getActivityStats() {
    return _storage.getActivityStats();
  }

  // Clear history
  Future<void> clearHistory() async {
    state = [];
    await _storage.clearAllActivities();
  }

  // Load more activities (for pagination)
  Future<void> loadMoreActivities({int limit = 50}) async {
    try {
      final moreActivities = _storage.getRecentActivities(limit: state.length + limit);
      state = moreActivities;
    } catch (e) {
      Logger.d('Failed to load more activities: $e');
    }
  }
}



// ============================================
// 🎓 KEY RIVERPOD CONCEPTS SUMMARY
// ============================================

/*
1️⃣ WATCH vs READ vs LISTEN

WATCH: Rebuilds widget when state changes
  final user = ref.watch(authNotifierProvider).user;

READ: One-time read, no rebuilds
  ref.read(authNotifierProvider.notifier).login();

LISTEN: Execute code when state changes (not rebuild)
  ref.listen(authNotifierProvider, (prev, next) {
    if (next.isAuthenticated) {
      Navigator.push(...);
    }
  });

2️⃣ PROVIDER TYPES

Provider          - Read-only, never changes
StateProvider     - Simple state (counter, toggle)
FutureProvider    - Async data (API calls)
StreamProvider    - Real-time data (WebSocket)
NotifierProvider  - Complex state with logic

3️⃣ STATE MANAGEMENT PATTERN

1. Define State class (what data to hold)
2. Create Notifier class (logic to change state)
3. Create Provider (makes it available)
4. Watch in widgets (UI reacts to changes)

4️⃣ BEST PRACTICES

✅ Keep providers small and focused
✅ Use const constructors when possible
✅ Dispose streams/timers in notifier
✅ Use copyWith for immutable updates
✅ Handle errors gracefully
✅ Cache data when appropriate
✅ Use family for dynamic providers
*/
