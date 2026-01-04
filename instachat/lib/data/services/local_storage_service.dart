import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_model.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';
import '../models/story_model.dart';
import '../models/comment_model.dart';
import '../models/gamification_model.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static const String _activitiesBoxName = 'activities';
  static const String _userDataBoxName = 'user_data';
  static const String _postsBoxName = 'posts';
  static const String _conversationsBoxName = 'conversations';
  static const String _messagesBoxName = 'messages';
  static const String _notificationsBoxName = 'notifications';
  static const String _storiesBoxName = 'stories';
  static const String _commentsBoxName = 'comments';

  // Secure Storage keys
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  late Box<ActivityModel> _activitiesBox;
  late Box _userDataBox;
  late Box<PostModel> _postsBox;
  late Box<ConversationModel> _conversationsBox;
  late Box<MessageModel> _messagesBox;
  late Box<NotificationModel> _notificationsBox;
  late Box<StoryModel> _storiesBox;
  late Box<CommentModel> _commentsBox;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late SharedPreferences _prefs;

  // Initialize Hive boxes
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await Hive.initFlutter();

    // Register Adapters (only for models that have Hive annotations)
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ActivityModelAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(GamificationModelAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(BadgeModelAdapter());
    // Note: Other models don't have Hive annotations yet, so their adapters are not generated

    // Open boxes
    _activitiesBox = await Hive.openBox<ActivityModel>(_activitiesBoxName);
    _userDataBox = await Hive.openBox(_userDataBoxName);
    _postsBox = await Hive.openBox<PostModel>(_postsBoxName);
    _conversationsBox = await Hive.openBox<ConversationModel>(_conversationsBoxName);
    _messagesBox = await Hive.openBox<MessageModel>(_messagesBoxName);
    _notificationsBox = await Hive.openBox<NotificationModel>(_notificationsBoxName);
    _storiesBox = await Hive.openBox<StoryModel>(_storiesBoxName);
    _commentsBox = await Hive.openBox<CommentModel>(_commentsBoxName);
  }

  // Close all boxes
  Future<void> close() async {
    if (Hive.isBoxOpen(_activitiesBoxName)) await _activitiesBox.close();
    if (Hive.isBoxOpen(_userDataBoxName)) await _userDataBox.close();
    if (Hive.isBoxOpen(_postsBoxName)) await _postsBox.close();
    if (Hive.isBoxOpen(_conversationsBoxName)) await _conversationsBox.close();
    if (Hive.isBoxOpen(_messagesBoxName)) await _messagesBox.close();
    if (Hive.isBoxOpen(_notificationsBoxName)) await _notificationsBox.close();
    if (Hive.isBoxOpen(_storiesBoxName)) await _storiesBox.close();
    if (Hive.isBoxOpen(_commentsBoxName)) await _commentsBox.close();
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
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    } else {
      // For complex objects like List<Map<String, dynamic>>, convert to JSON string
      await _prefs.setString(key, jsonEncode(value));
    }
  }

  // Get user preference
  dynamic getUserPreference(String key) {
    return _prefs.get(key);
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
      'user_data_count': _prefs.getKeys().length,
      'last_sync': getLastSyncTimestamp()?.toIso8601String(),
    };
  }

  // Clear all data (factory reset)
  Future<void> clearAllData() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }

  // ===========================================================================
  // POST STORAGE METHODS (Using SharedPreferences for now)
  // ===========================================================================

  Future<void> savePost(PostModel post) async {
    final posts = getAllPosts();
    posts.removeWhere((p) => p.id == post.id);
    posts.add(post);
    await saveUserPreference('posts', posts.map((p) => p.toJson()).toList());
  }

  Future<void> savePosts(List<PostModel> posts) async {
    await saveUserPreference('posts', posts.map((p) => p.toJson()).toList());
  }

  List<PostModel> getAllPosts() {
    final postsJson = getUserPreference('posts') as List<dynamic>? ?? [];
    final posts = postsJson.map((json) => PostModel.fromJson(json)).toList();
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }

  Future<void> deletePost(String postId) async {
    final posts = getAllPosts();
    posts.removeWhere((p) => p.id == postId);
    await saveUserPreference('posts', posts.map((p) => p.toJson()).toList());
  }

  Future<void> clearAllPosts() async {
    await _prefs.remove('posts');
  }

  // ===========================================================================
  // CONVERSATION STORAGE METHODS (Using SharedPreferences for now)
  // ===========================================================================

  Future<void> saveConversation(ConversationModel conversation) async {
    final conversations = getAllConversations();
    conversations.removeWhere((c) => c.id == conversation.id);
    conversations.add(conversation);
    await saveUserPreference('conversations', conversations.map((c) => c.toJson()).toList());
  }

  Future<void> saveConversations(List<ConversationModel> conversations) async {
    await saveUserPreference('conversations', conversations.map((c) => c.toJson()).toList());
  }

  List<ConversationModel> getAllConversations() {
    final conversationsJson = getUserPreference('conversations') as List<dynamic>? ?? [];
    final conversations = conversationsJson.map((json) => ConversationModel.fromJson(json)).toList();
    conversations.sort((a, b) => (b.updatedAt ?? b.createdAt).compareTo(a.updatedAt ?? a.createdAt));
    return conversations;
  }

  // ===========================================================================
  // MESSAGE STORAGE METHODS (Using SharedPreferences for now)
  // ===========================================================================

  Future<void> saveMessage(MessageModel message) async {
    final messages = getMessagesForConversation(message.conversationId);
    messages.removeWhere((m) => m.id == message.id);
    messages.add(message);
    await saveUserPreference('messages_${message.conversationId}', messages.map((m) => m.toJson()).toList());
  }

  List<MessageModel> getMessagesForConversation(String conversationId) {
    final messagesJson = getUserPreference('messages_$conversationId') as List<dynamic>? ?? [];
    final messages = messagesJson.map((json) => MessageModel.fromJson(json)).toList();
    messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return messages;
  }

  // ===========================================================================
  // NOTIFICATION STORAGE METHODS (Using SharedPreferences for now)
  // ===========================================================================

  Future<void> saveNotification(NotificationModel notification) async {
    final notifications = getAllNotifications();
    notifications.removeWhere((n) => n.id == notification.id);
    notifications.add(notification);
    await saveUserPreference('notifications', notifications.map((n) => n.toJson()).toList());
  }

  Future<void> saveNotifications(List<NotificationModel> notifications) async {
    await saveUserPreference('notifications', notifications.map((n) => n.toJson()).toList());
  }

  List<NotificationModel> getAllNotifications() {
    final notificationsJson = getUserPreference('notifications') as List<dynamic>? ?? [];
    final notifications = notificationsJson.map((json) => NotificationModel.fromJson(json)).toList();
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final notifications = getAllNotifications();
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      await saveUserPreference('notifications', notifications.map((n) => n.toJson()).toList());
    }
  }

  // ===========================================================================
  // STORY STORAGE METHODS (Using SharedPreferences for now)
  // ===========================================================================

  Future<void> saveStory(StoryModel story) async {
    final stories = getAllStories();
    stories.removeWhere((s) => s.id == story.id);
    stories.add(story);
    await saveUserPreference('stories', stories.map((s) => s.toJson()).toList());
  }

  Future<void> saveStories(List<StoryModel> stories) async {
    await saveUserPreference('stories', stories.map((s) => s.toJson()).toList());
  }

  List<StoryModel> getAllStories() {
    final storiesJson = getUserPreference('stories') as List<dynamic>? ?? [];
    final stories = storiesJson.map((json) => StoryModel.fromJson(json)).toList();
    // Filter out expired stories
    final now = DateTime.now();
    stories.removeWhere((s) => s.expiresAt.isBefore(now));
    stories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return stories;
  }

  // ===========================================================================
  // COMMENT STORAGE METHODS (Using SharedPreferences for now)
  // ===========================================================================

  Future<void> saveComment(CommentModel comment) async {
    final comments = getCommentsForPost(comment.postId);
    comments.removeWhere((c) => c.id == comment.id);
    comments.add(comment);
    await saveUserPreference('comments_${comment.postId}', comments.map((c) => c.toJson()).toList());
  }

  Future<void> saveComments(List<CommentModel> comments) async {
    if (comments.isEmpty) return;
    final postId = comments.first.postId;
    await saveUserPreference('comments_$postId', comments.map((c) => c.toJson()).toList());
  }

  List<CommentModel> getCommentsForPost(String postId) {
    final commentsJson = getUserPreference('comments_$postId') as List<dynamic>? ?? [];
    final comments = commentsJson.map((json) => CommentModel.fromJson(json)).toList();
    comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return comments;
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
}
