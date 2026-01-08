import 'package:flutter/material.dart';

class AppConstants {
  // Camera Filters
  static const List<FilterData> filters = [
    FilterData(name: 'None', icon: Icons.filter_none),
    FilterData(name: 'Vintage', icon: Icons.palette),
    FilterData(name: 'Black & White', icon: Icons.invert_colors),
    FilterData(name: 'Sepia', icon: Icons.color_lens),
    FilterData(name: 'Bright', icon: Icons.brightness_6),
    FilterData(name: 'Cool', icon: Icons.ac_unit),
    FilterData(name: 'Warm', icon: Icons.wb_sunny),
    FilterData(name: 'Dramatic', icon: Icons.flash_on),
    FilterData(name: 'Mono', icon: Icons.filter_b_and_w),
    FilterData(name: 'Retro', icon: Icons.camera_roll),
  ];

  // Video Recording Limits
  static const int maxVideoDuration = 60; // seconds
  static const int minVideoDuration = 3; // seconds

  // Image Quality Settings
  static const int imageQuality = 90; // JPEG quality 0-100
  static const double maxImageWidth = 1920;
  static const double maxImageHeight = 1080;

  // Reel Settings
  static const int maxReelDuration = 90; // seconds
  static const int minReelDuration = 15; // seconds
  static const int maxReelTitleLength = 100;
  static const int maxReelDescriptionLength = 500;

  // Cache Settings
  static const Duration imageCacheDuration = Duration(hours: 24);
  static const Duration videoCacheDuration = Duration(hours: 6);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB

  // Upload Settings
  static const int maxFileSize = 100 * 1024 * 1024; // 100MB
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> supportedVideoFormats = ['mp4', 'mov', 'avi', 'mkv'];

  // UI Constants
  static const double cameraButtonSize = 80.0;
  static const double filterPreviewSize = 60.0;
  static const double storyBorderWidth = 3.0;
  static const double avatarBorderRadius = 50.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Search
  static const int minSearchQueryLength = 2;
  static const Duration searchDebounceDuration = Duration(milliseconds: 300);

  // Stories
  static const Duration storyDuration = Duration(seconds: 5);
  static const Duration storyTransitionDuration = Duration(milliseconds: 300);

  // Notifications
  static const String notificationChannelId = 'social_app_channel';
  static const String notificationChannelName = 'Social App';
  static const String notificationChannelDescription = 'Social App Notifications';
}

class FilterData {
  final String name;
  final IconData icon;
  final Map<String, dynamic>? parameters;

  const FilterData({
    required this.name,
    required this.icon,
    this.parameters,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilterData && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
