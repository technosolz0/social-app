import 'user_model.dart';

class PostModel {
  final String id;
  final String userId;
  final UserModel user;
  final String postType; // photo, video, reel
  final String? caption;
  final String mediaUrl;
  final String? thumbnailUrl;
  final List<String> hashtags;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int viewsCount;
  final bool isLiked;
  final DateTime createdAt;

  const PostModel({
    required this.id,
    required this.userId,
    required this.user,
    required this.postType,
    this.caption,
    required this.mediaUrl,
    this.thumbnailUrl,
    this.hashtags = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.viewsCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      postType: json['postType'] as String,
      caption: json['caption'] as String?,
      mediaUrl: json['mediaUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      hashtags: (json['hashtags'] as List<dynamic>?)?.cast<String>() ?? [],
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      sharesCount: json['sharesCount'] as int? ?? 0,
      viewsCount: json['viewsCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'user': user.toJson(),
      'postType': postType,
      'caption': caption,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'hashtags': hashtags,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'viewsCount': viewsCount,
      'isLiked': isLiked,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  PostModel copyWith({
    String? id,
    String? userId,
    UserModel? user,
    String? postType,
    String? caption,
    String? mediaUrl,
    String? thumbnailUrl,
    List<String>? hashtags,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    int? viewsCount,
    bool? isLiked,
    DateTime? createdAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      postType: postType ?? this.postType,
      caption: caption ?? this.caption,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      hashtags: hashtags ?? this.hashtags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
