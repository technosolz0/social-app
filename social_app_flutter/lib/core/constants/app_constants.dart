// ============================================
// lib/core/constants/app_constants.dart
// App-wide constants
// ============================================

import 'package:flutter/material.dart';

class AppConstants {
  // API
  static const String baseUrl = 'https://api.instagram.com';
  static const String apiVersion = 'v1';

  // Storage keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';

  // Limits
  static const int maxPostCaptionLength = 2200;
  static const int maxCommentLength = 1000;
  static const int maxUsernameLength = 30;
  static const int maxBioLength = 80;

  // Pagination
  static const int postsPerPage = 20;
  static const int commentsPerPage = 20;
  static const int messagesPerPage = 50;

  // Cache
  static const Duration cacheTimeout = Duration(hours: 1);
  static const int maxCacheSize = 100;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Colors (Instagram theme)
  static const int primaryColor = 0xFFE4405F;
  static const int secondaryColor = 0xFF8134AF;
  static const int accentColor = 0xFFF77737;

  // Social media links
  static const String instagramUrl = 'https://instagram.com';
  static const String privacyPolicyUrl = '$instagramUrl/legal/privacy/';
  static const String termsOfServiceUrl = '$instagramUrl/legal/terms/';

  // App info
  static const String appName = 'Instagram Clone';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@instagramclone.com';

  // Feature flags
  static const bool enableStories = true;
  static const bool enableReels = true;
  static const bool enableLive = false;
  static const bool enableGamification = true;
  static const bool enableDarkMode = true;

  // Camera filters
  static List<CameraFilter> get filters => [
    CameraFilter(name: 'None', icon: Icons.filter_none),
    CameraFilter(name: 'Vintage', icon: Icons.palette),
    CameraFilter(name: 'Black & White', icon: Icons.invert_colors),
    CameraFilter(name: 'Sepia', icon: Icons.color_lens),
    CameraFilter(name: 'Bright', icon: Icons.brightness_6),
    CameraFilter(name: 'Warm', icon: Icons.wb_sunny),
    CameraFilter(name: 'Cool', icon: Icons.ac_unit),
    CameraFilter(name: 'Dramatic', icon: Icons.flash_on),
  ];
}

class CameraFilter {
  final String name;
  final IconData icon;

  const CameraFilter({
    required this.name,
    required this.icon,
  });
}
