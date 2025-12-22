import 'package:hive/hive.dart';

// part 'activity_model.g.dart';

@HiveType(typeId: 0)
class ActivityModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String activityType;

  @HiveField(3)
  final Map<String, dynamic>? metadata;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final String? postId;

  @HiveField(6)
  final String? storyId;

  @HiveField(7)
  final String? targetUserId;

  @HiveField(8)
  final String? username;

  @HiveField(9)
  final String? userAvatar;

  const ActivityModel({
    required this.id,
    required this.userId,
    required this.activityType,
    this.metadata,
    required this.timestamp,
    this.postId,
    this.storyId,
    this.targetUserId,
    this.username,
    this.userAvatar,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      activityType: json['activity_type'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      postId: json['post_id'] as String?,
      storyId: json['story_id'] as String?,
      targetUserId: json['target_user_id'] as String?,
      username: json['username'] as String?,
      userAvatar: json['user_avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'activity_type': activityType,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
      'post_id': postId,
      'story_id': storyId,
      'target_user_id': targetUserId,
      'username': username,
      'user_avatar': userAvatar,
    };
  }

  ActivityModel copyWith({
    String? id,
    String? userId,
    String? activityType,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
    String? postId,
    String? storyId,
    String? targetUserId,
    String? username,
    String? userAvatar,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      activityType: activityType ?? this.activityType,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
      postId: postId ?? this.postId,
      storyId: storyId ?? this.storyId,
      targetUserId: targetUserId ?? this.targetUserId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
    );
  }

  // Helper methods
  String getActivityDescription() {
    switch (activityType) {
      case 'post_view':
        return 'Viewed a post';
      case 'post_like':
        return 'Liked a post';
      case 'story_view':
        return 'Viewed a story';
      case 'profile_view':
        return 'Viewed a profile';
      case 'search':
        return 'Performed a search';
      case 'message_sent':
        return 'Sent a message';
      case 'login':
        return 'Logged in';
      case 'video_watch':
        return 'Watched a video';
      case 'follow':
        return 'Followed a user';
      case 'comment':
        return 'Commented on a post';
      case 'share':
        return 'Shared a post';
      case 'user_verified':
        return 'Verified a user';
      default:
        return activityType.replaceAll('_', ' ').toUpperCase();
    }
  }

  String? getMetadataValue(String key) {
    return metadata?[key]?.toString();
  }
}
