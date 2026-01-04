import 'user_model.dart';

class StoryModel {
  final String id;
  final String userId;
  final UserModel user;
  final String mediaUrl;
  final String storyType; // image, video
  final bool isSeen;
  final DateTime createdAt;
  final DateTime expiresAt;

  const StoryModel({
    required this.id,
    required this.userId,
    required this.user,
    required this.mediaUrl,
    required this.storyType,
    this.isSeen = false,
    required this.createdAt,
    required this.expiresAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      mediaUrl: json['media_url'] as String,
      storyType: json['story_type'] as String,
      isSeen: json['is_seen'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'user': user.toJson(),
      'media_url': mediaUrl,
      'story_type': storyType,
      'is_seen': isSeen,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  StoryModel copyWith({
    String? id,
    String? userId,
    UserModel? user,
    String? mediaUrl,
    String? storyType,
    bool? isSeen,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return StoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      storyType: storyType ?? this.storyType,
      isSeen: isSeen ?? this.isSeen,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
