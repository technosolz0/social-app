import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Social App';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int postsPerPage = 20;
  static const int commentsPerPage = 50;
  static const int usersPerPage = 30;

  // Media Limits
  static const int maxImageSizeMB = 10;
  static const int maxVideoSizeMB = 100;
  static const int maxVideoLengthSeconds = 60;
  static const int maxReelLengthSeconds = 90;
  static const int maxStoryDurationSeconds = 15;

  // Text Limits
  static const int maxCaptionLength = 2200;
  static const int maxCommentLength = 500;
  static const int maxBioLength = 150;
  static const int maxUsernameLength = 30;

  // Image Dimensions
  static const int maxImageWidth = 1080;
  static const int maxImageHeight = 1080;
  static const int thumbnailSize = 300;

  // Cache
  static const Duration cacheExpiry = Duration(hours: 24);
  static const int maxCacheItems = 100;

  // Activity Tracking
  static const Duration activitySyncInterval = Duration(minutes: 5);
  static const int maxActivitiesPerBatch = 50;

  // Chat
  static const int maxMessageLength = 1000;
  static const Duration typingIndicatorTimeout = Duration(seconds: 3);

  // Gamification
  static const List<int> levelThresholds = [
    0, 100, 250, 500, 1000, 2000, 3500, 5000, 7500, 10000, // 1-10
    15000, 20000, 30000, 40000, 50000, 65000, 80000, 100000, 125000,
    150000, // 11-20
    180000, 220000, 270000, 330000, 400000, 480000, 570000, 670000, 780000,
    900000, // 21-30
    1050000, 1220000, 1420000, 1650000, 1920000, 2230000, 2590000, 3000000,
    3500000, 4000000, // 31-40
  ];

  static const Map<String, int> pointsForActions = {
    'post_create': 50,
    'post_like': 1,
    'post_comment': 5,
    'story_create': 30,
    'reel_create': 100,
    'daily_login': 10,
    'streak_bonus': 20,
    'quest_complete': 30,
    'share_post': 10,
    'follow_user': 5,
  };

  // Filter Names
  static const List<String> imageFilters = [
    'None',
    'Vintage',
    'Cool',
    'Warm',
    'Bright',
    'Dark',
    'Sepia',
    'BlackAndWhite',
    'Dramatic',
    'Soft',
  ];

  // AR Filters
  static const List<String> arFilters = [
    'None',
    'Glasses',
    'Hat',
    'Mask',
    'BeautyFilter',
    'FaceSwap',
  ];

  // Story Stickers
  static const List<String> storyStickers = [
    'location',
    'mention',
    'hashtag',
    'music',
    'poll',
    'question',
    'countdown',
    'slider',
    'quiz',
  ];

  // Notification Types
  static const List<String> notificationTypes = [
    'like',
    'comment',
    'follow',
    'mention',
    'message',
    'story_view',
    'live_stream',
    'quest_complete',
    'level_up',
    'badge_earned',
  ];

  // Error Messages
  static const String networkError =
      'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'Something went wrong. Please try again.';
  static const String unauthorizedError = 'Please login to continue.';
  static const String notFoundError = 'Content not found.';

  // Success Messages
  static const String postCreated = 'Post created successfully!';
  static const String postDeleted = 'Post deleted successfully.';
  static const String commentAdded = 'Comment added!';
  static const String messageSent = 'Message sent!';
  static const String profileUpdated = 'Profile updated successfully!';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // Regular Expressions
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp usernameRegex = RegExp(
    r'^[a-zA-Z0-9._]{3,30}$',
  );
  static final RegExp hashtagRegex = RegExp(
    r'#[a-zA-Z0-9_]+',
  );
  static final RegExp mentionRegex = RegExp(
    r'@[a-zA-Z0-9._]+',
  );

  // Filters getter for compatibility
  static List<FilterData> get filters => kImageFilters;
}

class FilterData {
  final String name;
  final IconData icon;
  final Color? color;

  const FilterData({
    required this.name,
    required this.icon,
    this.color,
  });
}

// Predefined filters
const List<FilterData> kImageFilters = [
  FilterData(name: 'None', icon: Icons.cancel_outlined),
  FilterData(name: 'Vintage', icon: Icons.photo_filter, color: Colors.orange),
  FilterData(name: 'Cool', icon: Icons.ac_unit, color: Colors.blue),
  FilterData(name: 'Warm', icon: Icons.wb_sunny, color: Colors.orange),
  FilterData(name: 'Bright', icon: Icons.brightness_high, color: Colors.yellow),
  FilterData(name: 'Dark', icon: Icons.brightness_low, color: Colors.grey),
  FilterData(name: 'Sepia', icon: Icons.camera, color: Colors.brown),
  FilterData(name: 'B&W', icon: Icons.filter_b_and_w, color: Colors.black),
  FilterData(name: 'Dramatic', icon: Icons.flash_on, color: Colors.red),
  FilterData(name: 'Soft', icon: Icons.blur_on, color: Colors.pink),
];
