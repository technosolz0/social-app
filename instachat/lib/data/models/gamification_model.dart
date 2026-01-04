import 'package:hive/hive.dart';

part 'gamification_model.g.dart';

@HiveType(typeId: 1)
class GamificationModel {
  @HiveField(0)
  final int totalPoints;
  @HiveField(1)
  final int currentLevel;
  @HiveField(2)
  final int currentStreak;
  @HiveField(3)
  final List<BadgeModel> badges;

  const GamificationModel({
    this.totalPoints = 0,
    this.currentLevel = 1,
    this.currentStreak = 0,
    this.badges = const [],
  });

  factory GamificationModel.fromJson(Map<String, dynamic> json) {
    return GamificationModel(
      totalPoints: json['totalPoints'] as int? ?? 0,
      currentLevel: json['currentLevel'] as int? ?? 1,
      currentStreak: json['currentStreak'] as int? ?? 0,
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => BadgeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPoints': totalPoints,
      'currentLevel': currentLevel,
      'currentStreak': currentStreak,
      'badges': badges.map((e) => e.toJson()).toList(),
    };
  }
}

@HiveType(typeId: 2)
class BadgeModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String iconUrl;
  @HiveField(3)
  final String rarity;
  @HiveField(4)
  final DateTime earnedAt;

  const BadgeModel({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.rarity,
    required this.earnedAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconUrl: json['iconUrl'] as String,
      rarity: json['rarity'] as String,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconUrl': iconUrl,
      'rarity': rarity,
      'earnedAt': earnedAt.toIso8601String(),
    };
  }
}
