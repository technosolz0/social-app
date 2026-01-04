import 'user_model.dart';

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final UserModel user;
  final String text;
  final String? parentId; // For nested replies
  final List<CommentModel> replies;
  final int likesCount;
  final bool isLiked;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.user,
    required this.text,
    this.parentId,
    this.replies = const [],
    this.likesCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final user = UserModel.fromJson(json['user'] as Map<String, dynamic>);
    final replies = (json['replies'] as List<dynamic>?)?.map((reply) => CommentModel.fromJson(reply as Map<String, dynamic>)).toList() ?? [];

    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: user.id,
      user: user,
      text: json['text'] as String,
      parentId: json['parent_id'] as String?,
      replies: replies,
      likesCount: json['likes_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'user': user.toJson(),
      'text': text,
      'parent_id': parentId,
      'replies': replies.map((reply) => reply.toJson()).toList(),
      'likes_count': likesCount,
      'is_liked': isLiked,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    UserModel? user,
    String? text,
    String? parentId,
    List<CommentModel>? replies,
    int? likesCount,
    bool? isLiked,
    DateTime? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      text: text ?? this.text,
      parentId: parentId ?? this.parentId,
      replies: replies ?? this.replies,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
