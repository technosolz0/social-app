class ApiConstants {
  // Base URL - Change this to your backend URL
  // For mobile emulator/device, use host machine IP instead of localhost
  // Android emulator: 10.225.247.167, iOS simulator: 127.0.0.1 or host IP
  static const String baseUrl = 'http://10.225.247.167:8000';
  static const String apiVersion = '/api/v1';
  static const String apiBaseUrl = '$baseUrl$apiVersion';

  // WebSocket URL
  static const String wsUrl = 'ws://10.225.247.167:8002/ws';

  // FastAPI Service URL (port 8001)
  static const String fastApiBaseUrl = 'http://10.225.247.167:8001';

  // Auth Endpoints
  static const String login = '$apiBaseUrl/users/login/';
  static const String register =
      '$apiBaseUrl/users/'; // POST to users/ for registration
  static const String logout = '$apiBaseUrl/auth/logout/';
  static const String refreshToken = '$apiBaseUrl/auth/refresh/';
  static const String getCurrentUser = '$apiBaseUrl/users/me/';

  // User Endpoints
  static const String users = '$apiBaseUrl/users/';
  static String userById(String id) => '$users$id/';
  static String userFollowers(String id) => '$users$id/followers/';
  static String userFollowing(String id) => '$users$id/following/';
  static String followUser(String id) => '$users$id/follow/';
  static String unfollowUser(String id) => '$users$id/unfollow/';

  // Post Endpoints
  static const String posts = '$apiBaseUrl/posts/';
  static String postById(String id) => '$posts$id/';
  static const String feed = '$apiBaseUrl/feed/';
  static String likePost(String id) => '$posts$id/like/';
  static String unlikePost(String id) => '$posts$id/unlike/';
  static String postComments(String id) => '$posts$id/comments/';

  // Story Endpoints
  static const String stories = '$apiBaseUrl/stories/';
  static String storyById(String id) => '$stories$id/';
  static String viewStory(String id) => '$stories$id/view/';

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
  static String markNotificationRead(String id) => '$notifications$id/read/';

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
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
