import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Base URL - Auto-switching based on platform
  // Default for physical device: 10.129.254.167
  // (Change this to your computer's local IP if different)
  static const String _localIp = '10.129.254.167';

  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://api.production.com'; // Replace with production URL
    }

    // Check if running on Android Emulator
    // Model 'sdk_gphone' is standard for Google emulators.
    // Manually checking environment is tricky in Dart, but we can infer.
    // Safer default for emulator is 10.0.2.2 which maps to host localhost.
    if (!kIsWeb && Platform.isAndroid) {
      // return 'http://10.0.2.2:8000'; // for emulator
      return 'http://10.129.254.167:8000'; // for physical device
    }

    // For iOS Simulator, localhost works
    if (!kIsWeb && Platform.isIOS) {
      return 'http://127.0.0.1:8000';
    }

    return 'http://$_localIp:8000';
  }

  static String get apiVersion => '/api/v1';
  static String get apiBaseUrl => '$baseUrl$apiVersion';

  // WebSocket URL
  static String get wsBaseUrl {
    if (kReleaseMode) return 'wss://api.production.com/ws';
    if (!kIsWeb && Platform.isAndroid) {
      // return 'ws://10.0.2.2:8002/ws'; // for emulator
      return 'ws://10.129.254.167:8002/ws'; // for physical device
    }
    if (!kIsWeb && Platform.isIOS) return 'ws://127.0.0.1:8002/ws';
    return 'ws://$_localIp:8002/ws';
  }

  static String get wsUrl => wsBaseUrl;

  // FastAPI Service URL (port 8001)
  static String get fastApiUrl {
    if (kReleaseMode) return 'https://fastapi.production.com';
    if (!kIsWeb && Platform.isAndroid) {
      // return 'http://10.0.2.2:8001'; // for emulator
      return 'http://10.129.254.167:8001'; // for physical device
    }
    if (!kIsWeb && Platform.isIOS) return 'http://127.0.0.1:8001';
    return 'http://$_localIp:8001';
  }

  static String get fastApiBaseUrl => fastApiUrl;

  // Auth Endpoints
  static String get login => '$apiBaseUrl/users/login/';
  static String get register => '$apiBaseUrl/users/';
  static String get logout => '$apiBaseUrl/auth/logout/';
  static String get refreshToken => '$apiBaseUrl/auth/refresh/';
  static String get getCurrentUser => '$apiBaseUrl/users/me/';
  static String get passwordReset => '$apiBaseUrl/users/password-reset/';
  static String get passwordResetConfirm =>
      '$apiBaseUrl/users/password-reset-confirm/';

  // User Endpoints
  static String get users => '$apiBaseUrl/users/';
  static String userById(String id) => '$users$id/';
  static String userFollowers(String id) => '$users$id/followers/';
  static String userFollowing(String id) => '$users$id/following/';

  // Social Endpoints
  static String get social => '$apiBaseUrl/social/';
  static String get follows => '$social/follows/';
  static String get followUser => '$follows/follow_user/';
  static String get unfollowUser => '$follows/unfollow_user/';
  static String get likes => '$social/likes/';
  static String get comments => '$social/comments/';

  // Post Endpoints
  static String get posts => '$apiBaseUrl/posts/';
  static String postById(String id) => '$posts$id/';
  static String get feed => '${posts}feed/';
  static String get trending => '${posts}trending/';
  static String get explore => '${posts}explore/';
  static String likePost(String id) => '$posts$id/like/';
  static String unlikePost(String id) => '$posts$id/unlike/';
  static String postComments(String id) => '$posts$id/comments/';
  static String addComment(String id) => '$posts$id/add_comment/';
  static String sharePost(String id) => '$posts$id/share/';

  // Story Endpoints
  static String get stories => '$apiBaseUrl/stories/';
  static String storyById(String id) => '$stories$id/';
  static String viewStory(String id) => '$stories$id/view/';
  static String get myStories => '$stories/my_stories/';
  static String get storyHighlights => '$stories/highlights/';

  // Reel Endpoints
  static String get reels => '$apiBaseUrl/reels/';
  static String reelById(String id) => '$reels$id/';

  // Chat Endpoints
  static String get conversations => '$apiBaseUrl/chat/conversations/';
  static String conversationById(String id) => '$conversations$id/';
  static String conversationMessages(String id) =>
      '$apiBaseUrl/chat/messages/?conversation_id=$id';
  static String sendMessage(String id) => '$apiBaseUrl/chat/messages/';

  // Notification Endpoints
  static String get notifications => '$apiBaseUrl/notifications/';
  static String notificationById(String id) => '$notifications$id/';
  static String markNotificationRead(String id) => '$notifications$id/read/';
  static String get unreadCount => '$notifications/unread_count/';
  static String get markAllRead => '$notifications/mark_all_read/';
  static String get clearAll => '$notifications/clear_all/';

  // Push Token Endpoints
  static String get pushTokens => '$apiBaseUrl/notifications/api/push-tokens/';

  // Notification Preferences Endpoints
  static String get notificationPreferences =>
      '$apiBaseUrl/notifications/api/preferences/';

  // Search Endpoints
  // Search Endpoints
  static String get search => '$apiBaseUrl/search';
  static String get searchUsers => '$search/users/';
  static String get searchPosts => '$search/posts/';

  // Gamification Endpoints
  static String get gamification => '$apiBaseUrl/gamification/';
  static String get points => '$gamification/points/';
  static String get badges => '$gamification/badges/';
  static String get leaderboard => '$gamification/leaderboard/';
  static String get quests => '$gamification/quests/';

  // Activity Endpoints
  static String get activities => '$apiBaseUrl/activities/';

  // FastAPI Feed Endpoints
  static String get fastApiFeed => '$fastApiBaseUrl/feed';
  static String get forYouFeed => '$fastApiFeed/for-you/';
  static String get trendingFeed => '$fastApiFeed/trending/';
  static String get exploreFeed => '$fastApiFeed/explore/';

  // FastAPI Recommendations Endpoints
  static String get fastApiRecommendations => '$fastApiBaseUrl/recommendations';
  static String get userRecommendations => '$fastApiRecommendations/users/';
  static String get contentRecommendations =>
      '$fastApiRecommendations/content/';
  static String get hashtagRecommendations =>
      '$fastApiRecommendations/hashtags/';

  // Storage Endpoints
  static String get upload => '$apiBaseUrl/upload/';
  static String get uploadImage => '$upload/image/';
  static String get uploadVideo => '$upload/video/';

  // Request timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
