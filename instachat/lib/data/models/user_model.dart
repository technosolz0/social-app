import 'gamification_model.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String? avatar;
  final String? bio;
  final String? website;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isVerified;
  final bool isPrivate;
  final GamificationModel? gamification;
  final bool? isFollowing;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    this.bio,
    this.website,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.isVerified = false,
    this.isPrivate = false,
    this.gamification,
    this.isFollowing,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      website: json['website'] as String?,
      followersCount: json['followersCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
      postsCount: json['postsCount'] as int? ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      isPrivate: json['isPrivate'] as bool? ?? false,
      gamification: json['gamification'] != null
          ? GamificationModel.fromJson(
              json['gamification'] as Map<String, dynamic>,
            )
          : null,
      isFollowing: json['is_following'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'bio': bio,
      'website': website,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'isVerified': isVerified,
      'isPrivate': isPrivate,
      'gamification': gamification?.toJson(),
      'is_following': isFollowing,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? avatar,
    String? bio,
    String? website,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    bool? isVerified,
    bool? isPrivate,
    GamificationModel? gamification,
    bool? isFollowing,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      isVerified: isVerified ?? this.isVerified,
      isPrivate: isPrivate ?? this.isPrivate,
      gamification: gamification ?? this.gamification,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
