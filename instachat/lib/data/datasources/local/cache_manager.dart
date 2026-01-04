import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

// ============================================
// lib/data/datasources/local/cache_manager.dart
// 💾 HIVE-BASED CACHE MANAGER FOR APP DATA
// ============================================

class CacheManager {
  static const CacheManager _instance = CacheManager._internal();
  const CacheManager._internal();
  factory CacheManager() => _instance;

  static const String _postsBox = 'posts_cache';
  static const String _usersBox = 'users_cache';
  static const String _feedBox = 'feed_cache';
  static const String _settingsBox = 'settings_cache';

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  /// Initialize Hive and open all boxes
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters if needed (for complex objects)
    // Hive.registerAdapter(PostModelAdapter());

    await Future.wait([
      Hive.openBox(_postsBox),
      Hive.openBox(_usersBox),
      Hive.openBox(_feedBox),
      Hive.openBox(_settingsBox),
    ]);
  }

  // ===========================================================================
  // POSTS CACHE
  // ===========================================================================

  /// Cache posts data
  Future<void> cachePosts(List<Map<String, dynamic>> posts, {String? key}) async {
    final box = Hive.box(_postsBox);
    final cacheKey = key ?? 'posts_list';
    final cacheData = {
      'data': posts,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiresAt': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
    };
    await box.put(cacheKey, jsonEncode(cacheData));
  }

  /// Get cached posts
  List<Map<String, dynamic>>? getCachedPosts({String? key}) {
    final box = Hive.box(_postsBox);
    final cacheKey = key ?? 'posts_list';
    final cachedData = box.get(cacheKey);

    if (cachedData == null) return null;

    try {
      final decoded = jsonDecode(cachedData);
      final expiresAt = decoded['expiresAt'];
      final now = DateTime.now().millisecondsSinceEpoch;

      // Check if cache is expired
      if (now > expiresAt) {
        box.delete(cacheKey);
        return null;
      }

      return List<Map<String, dynamic>>.from(decoded['data']);
    } catch (e) {
      // Invalid cache data, remove it
      box.delete(cacheKey);
      return null;
    }
  }

  /// Cache individual post
  Future<void> cachePost(String postId, Map<String, dynamic> post) async {
    final box = Hive.box(_postsBox);
    final cacheData = {
      'data': post,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiresAt': DateTime.now().add(const Duration(hours: 2)).millisecondsSinceEpoch,
    };
    await box.put('post_$postId', jsonEncode(cacheData));
  }

  /// Get cached post
  Map<String, dynamic>? getCachedPost(String postId) {
    final box = Hive.box(_postsBox);
    final cachedData = box.get('post_$postId');

    if (cachedData == null) return null;

    try {
      final decoded = jsonDecode(cachedData);
      final expiresAt = decoded['expiresAt'];
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now > expiresAt) {
        box.delete('post_$postId');
        return null;
      }

      return decoded['data'];
    } catch (e) {
      box.delete('post_$postId');
      return null;
    }
  }

  // ===========================================================================
  // USERS CACHE
  // ===========================================================================

  /// Cache user profile
  Future<void> cacheUser(String userId, Map<String, dynamic> user) async {
    final box = Hive.box(_usersBox);
    final cacheData = {
      'data': user,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiresAt': DateTime.now().add(const Duration(hours: 6)).millisecondsSinceEpoch,
    };
    await box.put('user_$userId', jsonEncode(cacheData));
  }

  /// Get cached user
  Map<String, dynamic>? getCachedUser(String userId) {
    final box = Hive.box(_usersBox);
    final cachedData = box.get('user_$userId');

    if (cachedData == null) return null;

    try {
      final decoded = jsonDecode(cachedData);
      final expiresAt = decoded['expiresAt'];
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now > expiresAt) {
        box.delete('user_$userId');
        return null;
      }

      return decoded['data'];
    } catch (e) {
      box.delete('user_$userId');
      return null;
    }
  }

  /// Cache user search results
  Future<void> cacheUserSearch(String query, List<Map<String, dynamic>> users) async {
    final box = Hive.box(_usersBox);
    final cacheData = {
      'data': users,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiresAt': DateTime.now().add(const Duration(minutes: 30)).millisecondsSinceEpoch,
    };
    await box.put('search_$query', jsonEncode(cacheData));
  }

  /// Get cached user search
  List<Map<String, dynamic>>? getCachedUserSearch(String query) {
    final box = Hive.box(_usersBox);
    final cachedData = box.get('search_$query');

    if (cachedData == null) return null;

    try {
      final decoded = jsonDecode(cachedData);
      final expiresAt = decoded['expiresAt'];
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now > expiresAt) {
        box.delete('search_$query');
        return null;
      }

      return List<Map<String, dynamic>>.from(decoded['data']);
    } catch (e) {
      box.delete('search_$query');
      return null;
    }
  }

  // ===========================================================================
  // FEED CACHE
  // ===========================================================================

  /// Cache feed data
  Future<void> cacheFeed(String feedType, List<Map<String, dynamic>> feed, {int page = 1}) async {
    final box = Hive.box(_feedBox);
    final cacheKey = '${feedType}_page_$page';
    final cacheData = {
      'data': feed,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiresAt': DateTime.now().add(const Duration(minutes: 15)).millisecondsSinceEpoch,
      'page': page,
    };
    await box.put(cacheKey, jsonEncode(cacheData));
  }

  /// Get cached feed
  List<Map<String, dynamic>>? getCachedFeed(String feedType, {int page = 1}) {
    final box = Hive.box(_feedBox);
    final cacheKey = '${feedType}_page_$page';
    final cachedData = box.get(cacheKey);

    if (cachedData == null) return null;

    try {
      final decoded = jsonDecode(cachedData);
      final expiresAt = decoded['expiresAt'];
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now > expiresAt) {
        box.delete(cacheKey);
        return null;
      }

      return List<Map<String, dynamic>>.from(decoded['data']);
    } catch (e) {
      box.delete(cacheKey);
      return null;
    }
  }

  /// Cache trending hashtags
  Future<void> cacheTrendingHashtags(List<String> hashtags) async {
    final box = Hive.box(_feedBox);
    final cacheData = {
      'data': hashtags,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiresAt': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
    };
    await box.put('trending_hashtags', jsonEncode(cacheData));
  }

  /// Get cached trending hashtags
  List<String>? getCachedTrendingHashtags() {
    final box = Hive.box(_feedBox);
    final cachedData = box.get('trending_hashtags');

    if (cachedData == null) return null;

    try {
      final decoded = jsonDecode(cachedData);
      final expiresAt = decoded['expiresAt'];
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now > expiresAt) {
        box.delete('trending_hashtags');
        return null;
      }

      return List<String>.from(decoded['data']);
    } catch (e) {
      box.delete('trending_hashtags');
      return null;
    }
  }

  // ===========================================================================
  // SETTINGS CACHE
  // ===========================================================================

  /// Cache user settings
  Future<void> cacheSettings(Map<String, dynamic> settings) async {
    final box = Hive.box(_settingsBox);
    final cacheData = {
      'data': settings,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiresAt': DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch,
    };
    await box.put('user_settings', jsonEncode(cacheData));
  }

  /// Get cached settings
  Map<String, dynamic>? getCachedSettings() {
    final box = Hive.box(_settingsBox);
    final cachedData = box.get('user_settings');

    if (cachedData == null) return null;

    try {
      final decoded = jsonDecode(cachedData);
      final expiresAt = decoded['expiresAt'];
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now > expiresAt) {
        box.delete('user_settings');
        return null;
      }

      return decoded['data'];
    } catch (e) {
      box.delete('user_settings');
      return null;
    }
  }

  /// Cache app configuration
  Future<void> cacheAppConfig(Map<String, dynamic> config) async {
    final box = Hive.box(_settingsBox);
    final cacheData = {
      'data': config,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiresAt': DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch,
    };
    await box.put('app_config', jsonEncode(cacheData));
  }

  /// Get cached app config
  Map<String, dynamic>? getCachedAppConfig() {
    final box = Hive.box(_settingsBox);
    final cachedData = box.get('app_config');

    if (cachedData == null) return null;

    try {
      final decoded = jsonDecode(cachedData);
      final expiresAt = decoded['expiresAt'];
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now > expiresAt) {
        box.delete('app_config');
        return null;
      }

      return decoded['data'];
    } catch (e) {
      box.delete('app_config');
      return null;
    }
  }

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Clear all cache
  Future<void> clearAllCache() async {
    await Future.wait([
      Hive.box(_postsBox).clear(),
      Hive.box(_usersBox).clear(),
      Hive.box(_feedBox).clear(),
      Hive.box(_settingsBox).clear(),
    ]);
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await _clearExpiredFromBox(Hive.box(_postsBox), now);
    await _clearExpiredFromBox(Hive.box(_usersBox), now);
    await _clearExpiredFromBox(Hive.box(_feedBox), now);
    await _clearExpiredFromBox(Hive.box(_settingsBox), now);
  }

  Future<void> _clearExpiredFromBox(Box box, int now) async {
    final keysToDelete = <String>[];

    for (final key in box.keys) {
      try {
        final cachedData = box.get(key);
        if (cachedData != null) {
          final decoded = jsonDecode(cachedData);
          final expiresAt = decoded['expiresAt'];
          if (now > expiresAt) {
            keysToDelete.add(key);
          }
        }
      } catch (e) {
        // Invalid data, mark for deletion
        keysToDelete.add(key);
      }
    }

    for (final key in keysToDelete) {
      await box.delete(key);
    }
  }

  /// Get cache statistics
  Future<Map<String, int>> getCacheStats() async {
    return {
      'posts_cache': Hive.box(_postsBox).length,
      'users_cache': Hive.box(_usersBox).length,
      'feed_cache': Hive.box(_feedBox).length,
      'settings_cache': Hive.box(_settingsBox).length,
    };
  }

  /// Close all boxes (call when app is terminating)
  Future<void> close() async {
    await Future.wait([
      Hive.box(_postsBox).close(),
      Hive.box(_usersBox).close(),
      Hive.box(_feedBox).close(),
      Hive.box(_settingsBox).close(),
    ]);
  }
}
