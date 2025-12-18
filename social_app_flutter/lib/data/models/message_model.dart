import 'user_model.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final UserModel sender;
  final String messageType; // text, image, video, audio
  final String? content;
  final String? mediaUrl;
  final bool isRead;
  final DateTime? expiresAt; // For disappearing messages
  final DateTime? readAt;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.sender,
    required this.messageType,
    this.content,
    this.mediaUrl,
    this.isRead = false,
    this.expiresAt,
    this.readAt,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      sender: UserModel.fromJson(json['sender'] as Map<String, dynamic>),
      messageType: json['messageType'] as String,
      content: json['content'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt'] as String) : null,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'sender': sender.toJson(),
      'messageType': messageType,
      'content': content,
      'mediaUrl': mediaUrl,
      'isRead': isRead,
      'expiresAt': expiresAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    UserModel? sender,
    String? messageType,
    String? content,
    String? mediaUrl,
    bool? isRead,
    DateTime? expiresAt,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      sender: sender ?? this.sender,
      messageType: messageType ?? this.messageType,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      isRead: isRead ?? this.isRead,
      expiresAt: expiresAt ?? this.expiresAt,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
