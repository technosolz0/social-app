import 'user_model.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final UserModel? actor;
  final String? postId;
  final String? commentId;
  final String? storyId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.actor,
    this.postId,
    this.commentId,
    this.storyId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      actor: json['actor'] != null ? UserModel.fromJson(json['actor'] as Map<String, dynamic>) : null,
      postId: json['postId'] as String?,
      commentId: json['commentId'] as String?,
      storyId: json['storyId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'body': body,
      'actor': actor?.toJson(),
      'postId': postId,
      'commentId': commentId,
      'storyId': storyId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? body,
    UserModel? actor,
    String? postId,
    String? commentId,
    String? storyId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      actor: actor ?? this.actor,
      postId: postId ?? this.postId,
      commentId: commentId ?? this.commentId,
      storyId: storyId ?? this.storyId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
