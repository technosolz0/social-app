import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/activity_model.dart';

class LocalStorageService {
  static const String _activitiesBoxName = 'activities';
  static const String _userDataBoxName = 'user_data';

  // Secure Storage keys
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  late Box<ActivityModel> _activitiesBox;
  late Box _userDataBox;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Initialize Hive boxes
  Future<void> init() async {
    await Hive.initFlutter();

    // Open boxes (adapters are auto-generated)
    _activitiesBox = await Hive.openBox<ActivityModel>(_activitiesBoxName);
    _userDataBox = await Hive.openBox(_userDataBoxName);
  }

  // Close all boxes
  Future<void> close() async {
    await _activitiesBox.close();
    await _userDataBox.close();
  }

  // ===========================================================================
  // ACTIVITY STORAGE METHODS
  // ===========================================================================

  // Save activity to local storage
  Future<void> saveActivity(ActivityModel activity) async {
    await _activitiesBox.put(activity.id, activity);
  }

  // Get all activities
  List<ActivityModel> getAllActivities() {
    return _activitiesBox.values.toList();
  }

  // Get activities by type
  List<ActivityModel> getActivitiesByType(String activityType) {
    return _activitiesBox.values
        .where((activity) => activity.activityType == activityType)
        .toList();
  }

  // Get recent activities (limit)
  List<ActivityModel> getRecentActivities({int limit = 50}) {
    final activities = _activitiesBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return activities.take(limit).toList();
  }

  // Get activities within date range
  List<ActivityModel> getActivitiesInRange(DateTime start, DateTime end) {
    return _activitiesBox.values
        .where((activity) =>
            activity.timestamp.isAfter(start) &&
            activity.timestamp.isBefore(end))
        .toList();
  }

  // Delete activity
  Future<void> deleteActivity(String activityId) async {
    await _activitiesBox.delete(activityId);
  }

  // Clear all activities
  Future<void> clearAllActivities() async {
    await _activitiesBox.clear();
  }

  // Get activity count
  int getActivityCount() {
    return _activitiesBox.length;
  }

  // Get activities statistics
  Map<String, int> getActivityStats() {
    final activities = _activitiesBox.values;
    final stats = <String, int>{};

    for (final activity in activities) {
      stats[activity.activityType] = (stats[activity.activityType] ?? 0) + 1;
    }

    return stats;
  }

  // ===========================================================================
  // SECURE STORAGE METHODS (Auth tokens, sensitive data)
  // ===========================================================================

  // Save auth token securely
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: _authTokenKey, value: token);
  }

  // Get auth token
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _authTokenKey);
  }

  // Save refresh token securely
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  // Save user ID
  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  // Get user ID
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  // Clear all secure data (logout)
  Future<void> clearSecureData() async {
    await _secureStorage.deleteAll();
  }

  // ===========================================================================
  // USER DATA STORAGE METHODS (Non-sensitive user preferences)
  // ===========================================================================

  // Save user preference
  Future<void> saveUserPreference(String key, dynamic value) async {
    await _userDataBox.put(key, value);
  }

  // Get user preference
  dynamic getUserPreference(String key) {
    return _userDataBox.get(key);
  }

  // Save theme preference
  Future<void> saveThemeMode(String mode) async {
    await saveUserPreference('theme_mode', mode);
  }

  // Get theme preference
  String getThemeMode() {
    return getUserPreference('theme_mode') ?? 'system';
  }

  // Save language preference
  Future<void> saveLanguage(String language) async {
    await saveUserPreference('language', language);
  }

  // Get language preference
  String getLanguage() {
    return getUserPreference('language') ?? 'en';
  }

  // Save notification settings
  Future<void> saveNotificationSettings(Map<String, bool> settings) async {
    await saveUserPreference('notification_settings', settings);
  }

  // Get notification settings
  Map<String, bool> getNotificationSettings() {
    return Map<String, bool>.from(
        getUserPreference('notification_settings') ?? {});
  }

  // Save last sync timestamp
  Future<void> saveLastSyncTimestamp(DateTime timestamp) async {
    await saveUserPreference('last_sync', timestamp.toIso8601String());
  }

  // Get last sync timestamp
  DateTime? getLastSyncTimestamp() {
    final timestampStr = getUserPreference('last_sync') as String?;
    return timestampStr != null ? DateTime.parse(timestampStr) : null;
  }

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Get storage info
  Map<String, dynamic> getStorageInfo() {
    return {
      'activities_count': _activitiesBox.length,
      'user_data_count': _userDataBox.length,
      'activities_stats': getActivityStats(),
      'last_sync': getLastSyncTimestamp()?.toIso8601String(),
    };
  }

  // Clear all data (factory reset)
  Future<void> clearAllData() async {
    await _activitiesBox.clear();
    await _userDataBox.clear();
    await _secureStorage.deleteAll();
  }
}
