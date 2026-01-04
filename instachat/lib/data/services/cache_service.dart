import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheService {
  static const Duration _defaultCacheDuration = Duration(minutes: 5);

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Cache data with expiration
  Future<void> set(String key, dynamic data, {Duration? duration}) async {
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'expiresAt': DateTime.now()
          .add(duration ?? _defaultCacheDuration)
          .toIso8601String(),
    };

    await _prefs.setString(key, jsonEncode(cacheData));
  }

  // Get cached data if not expired
  dynamic get(String key) {
    final cached = _prefs.getString(key);
    if (cached == null) return null;

    try {
      final cacheData = jsonDecode(cached);
      final expiresAt = DateTime.parse(cacheData['expiresAt']);

      if (DateTime.now().isAfter(expiresAt)) {
        // Cache expired, remove it
        _prefs.remove(key);
        return null;
      }

      return cacheData['data'];
    } catch (e) {
      // Invalid cache data, remove it
      _prefs.remove(key);
      return null;
    }
  }

  // Check if data is cached and not expired
  bool hasValidCache(String key) {
    return get(key) != null;
  }

  // Remove specific cache entry
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  // Clear all cache
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Get cache info
  Map<String, dynamic> getCacheInfo() {
    final keys = _prefs.getKeys();
    return {
      'total_entries': keys.length,
      'keys': keys.toList(),
    };
  }

  // Cache keys for different data types
  static String conversationsKey(String userId) => 'conversations_$userId';
  static String messagesKey(String conversationId) => 'messages_$conversationId';
  static String postsKey({int page = 1}) => 'posts_page_$page';
  static String userKey(String userId) => 'user_$userId';
  static String feedKey({String type = 'home', int page = 1}) => '${type}_feed_page_$page';
  static String searchKey(String query) => 'search_$query';
}
