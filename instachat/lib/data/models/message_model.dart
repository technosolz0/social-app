import 'user_model.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final UserModel sender;
  final String messageType; // text, image, video, audio
  final String? content;
  final String? mediaUrl;
  final bool isRead;
  final String? replyTo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.messageType,
    this.content,
    this.mediaUrl,
    this.isRead = false,
    this.replyTo,
    required this.createdAt,
    this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation'] as String,
      sender: UserModel.fromJson(json['sender'] as Map<String, dynamic>),
      messageType: json['message_type'] as String,
      content: json['content'] as String?,
      mediaUrl: json['media_url'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      replyTo: json['reply_to'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation': conversationId,
      'sender': sender.toJson(),
      'message_type': messageType,
      'content': content,
      'media_url': mediaUrl,
      'is_read': isRead,
      'reply_to': replyTo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    UserModel? sender,
    String? messageType,
    String? content,
    String? mediaUrl,
    bool? isRead,
    String? replyTo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      sender: sender ?? this.sender,
      messageType: messageType ?? this.messageType,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      isRead: isRead ?? this.isRead,
      replyTo: replyTo ?? this.replyTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
