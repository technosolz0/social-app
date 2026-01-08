class ApiConstants {
  // Base URL - Change this to your backend URL
  // For mobile emulator/device, use host machine IP instead of localhost
  // Android emulator: 10.129.254.167, iOS simulator: 127.0.0.1 or host IP
  // For physical devices, use your computer's IP address
  static const String baseUrl = 'http://10.129.254.167:8000';
  static const String apiVersion = '/api/v1';
  static const String apiBaseUrl = '$baseUrl$apiVersion';

  // WebSocket URL
  static const String wsUrl = 'ws://10.129.254.167:8002/ws';

  // FastAPI Service URL (port 8001)
  static const String fastApiBaseUrl = 'http://10.129.254.167:8001';

  // Auth Endpoints
  static const String login = '$apiBaseUrl/users/login/';
  static const String register =
      '$apiBaseUrl/users/'; // POST to users/ for registration
  static const String logout = '$apiBaseUrl/auth/logout/';
  static const String refreshToken = '$apiBaseUrl/auth/refresh/';
  static const String getCurrentUser = '$apiBaseUrl/users/me/';
  static const String passwordReset = '$apiBaseUrl/users/password-reset/';
  static const String passwordResetConfirm = '$apiBaseUrl/users/password-reset-confirm/';

  // User Endpoints
  static const String users = '$apiBaseUrl/users/';
  static String userById(String id) => '$users$id/';
  static String userFollowers(String id) => '$users$id/followers/';
  static String userFollowing(String id) => '$users$id/following/';

  // Social Endpoints
  static const String social = '$apiBaseUrl/social/';
  static const String follows = '$social/follows/';
  static const String followUser = '$follows/follow_user/';
  static const String unfollowUser = '$follows/unfollow_user/';
  static const String likes = '$social/likes/';
  static const String comments = '$social/comments/';

  // Post Endpoints
  static const String posts = '$apiBaseUrl/posts/';
  static String postById(String id) => '$posts$id/';
  static const String feed = '$posts/feed/';
  static const String trending = '$posts/trending/';
  static const String explore = '$posts/explore/';
  static String likePost(String id) => '$posts$id/like/';
  static String unlikePost(String id) => '$posts$id/unlike/';
  static String postComments(String id) => '$posts$id/comments/';
  static String addComment(String id) => '$posts$id/add_comment/';
  static String sharePost(String id) => '$posts$id/share/';

  // Story Endpoints
  static const String stories = '$apiBaseUrl/stories/';
  static String storyById(String id) => '$stories$id/';
  static String viewStory(String id) => '$stories$id/view/';
  static const String myStories = '$stories/my_stories/';
  static const String storyHighlights = '$stories/highlights/';

  // Reel Endpoints
  static const String reels = '$apiBaseUrl/reels/';
  static String reelById(String id) => '$reels$id/';

  // Chat Endpoints
  static const String conversations = '$apiBaseUrl/chat/conversations/';
  static String conversationById(String id) => '$conversations$id/';
  static String conversationMessages(String id) =>
      '$apiBaseUrl/chat/messages/?conversation_id=$id';
  static String sendMessage(String id) => '$apiBaseUrl/chat/messages/';

  // Notification Endpoints
  static const String notifications = '$apiBaseUrl/notifications/';
  static String notificationById(String id) => '$notifications$id/';
  static String markNotificationRead(String id) => '$notifications$id/read/';
  static const String unreadCount = '$notifications/unread_count/';
  static const String markAllRead = '$notifications/mark_all_read/';
  static const String clearAll = '$notifications/clear_all/';

  // Push Token Endpoints
  static const String pushTokens = '$apiBaseUrl/push-tokens/';

  // Notification Preferences Endpoints
  static const String notificationPreferences = '$apiBaseUrl/preferences/';

  // Search Endpoints
  static const String search = '$apiBaseUrl/search/';
  static const String searchUsers = '$search/users/';
  static const String searchPosts = '$search/posts/';

  // Gamification Endpoints
  static const String gamification = '$apiBaseUrl/gamification/';
  static const String points = '$gamification/points/';
  static const String badges = '$gamification/badges/';
  static const String leaderboard = '$gamification/leaderboard/';
  static const String quests = '$gamification/quests/';

  // Activity Endpoints
  static const String activities = '$apiBaseUrl/activities/';

  // FastAPI Feed Endpoints
  static const String fastApiFeed = '$fastApiBaseUrl/feed';
  static const String forYouFeed = '$fastApiFeed/for-you/';
  static const String trendingFeed = '$fastApiFeed/trending/';
  static const String exploreFeed = '$fastApiFeed/explore/';

  // FastAPI Recommendations Endpoints
  static const String fastApiRecommendations =
      '$fastApiBaseUrl/recommendations';
  static const String userRecommendations = '$fastApiRecommendations/users/';
  static const String contentRecommendations =
      '$fastApiRecommendations/content/';
  static const String hashtagRecommendations =
      '$fastApiRecommendations/hashtags/';

  // Storage Endpoints
  static const String upload = '$apiBaseUrl/upload/';
  static const String uploadImage = '$upload/image/';
  static const String uploadVideo = '$upload/video/';

  // Request timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
