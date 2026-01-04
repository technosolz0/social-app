import 'user_model.dart';

class ConversationModel {
  final String id;
  final String conversationType; // 'direct' or 'group'
  final String? name; // For group chats
  final List<UserModel> participants;
  final UserModel createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? lastMessage;
  final int? unreadCount;

  const ConversationModel({
    required this.id,
    required this.conversationType,
    this.name,
    required this.participants,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.lastMessage,
    this.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      conversationType: json['conversation_type'] as String,
      name: json['name'] as String?,
      participants: (json['participants'] as List<dynamic>?)
          ?.map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      createdBy: UserModel.fromJson(json['created_by'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      lastMessage: json['last_message'] as Map<String, dynamic>?,
      unreadCount: json['unread_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_type': conversationType,
      'name': name,
      'participants': participants.map((e) => e.toJson()).toList(),
      'created_by': createdBy.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_message': lastMessage,
      'unread_count': unreadCount,
    };
  }
}
