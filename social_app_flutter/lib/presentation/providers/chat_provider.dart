import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/message_model.dart';
import '../../data/models/user_model.dart';

part 'chat_provider.g.dart';

@riverpod
class ChatNotifier extends _$ChatNotifier {
  @override
  Stream<List<MessageModel>> build(String conversationId) {
    // Return real-time stream of messages
    return _getMessagesStream(conversationId);
  }

  // Send message
  Future<void> sendMessage({
    required String content,
    String messageType = 'text',
    String? mediaUrl,
    Duration? expiresIn, // For disappearing messages
  }) async {
    final message = MessageModel(
      id: const Uuid().v4(),
      conversationId: conversationId,
      senderId: 'current_user_id', // ref.read(authProvider).user!.id,
      sender: UserModel(id: '1', username: 'current_user', email: 'user@example.com'), // ref.read(authProvider).user!,
      messageType: messageType,
      content: content,
      mediaUrl: mediaUrl,
      expiresAt: expiresIn != null
        ? DateTime.now().add(expiresIn)
        : null,
      createdAt: DateTime.now(),
    );

    // Send through WebSocket
    // ref.read(websocketServiceProvider).sendMessage(message);

    // For now, just add to local stream
    _addMessageToStream(message);

    // Track activity
    // ref.read(activityTrackerProvider).trackMessageSent();
  }

  // Mark messages as read
  Future<void> markAsRead(String messageId) async {
    // await ref.read(chatRepositoryProvider).markAsRead(messageId);
    // Mock implementation
  }

  Stream<List<MessageModel>> _getMessagesStream(String conversationId) async* {
    // Mock stream with some initial messages
    final messages = <MessageModel>[];

    // Add some mock messages
    final mockUser1 = UserModel(id: '1', username: 'alice', email: 'alice@example.com');
    final mockUser2 = UserModel(id: '2', username: 'bob', email: 'bob@example.com');

    messages.addAll([
      MessageModel(
        id: '1',
        conversationId: conversationId,
        senderId: mockUser1.id,
        sender: mockUser1,
        messageType: 'text',
        content: 'Hello!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      MessageModel(
        id: '2',
        conversationId: conversationId,
        senderId: mockUser2.id,
        sender: mockUser2,
        messageType: 'text',
        content: 'Hi there!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
    ]);

    yield messages;

    // Listen for new messages (mock)
    await for (final message in _messageController.stream) {
      if (message.conversationId == conversationId) {
        messages.add(message);
        yield List.from(messages);
      }
    }
  }

  final StreamController<MessageModel> _messageController = StreamController<MessageModel>.broadcast();

  void _addMessageToStream(MessageModel message) {
    _messageController.add(message);
  }

  @override
  void dispose() {
    _messageController.close();
    super.dispose();
  }
}

final chatProvider = StreamNotifierProvider.family<
  ChatNotifier,
  List<MessageModel>,
  String
>(() => ChatNotifier());

// ============================================
// 🎓 USING STREAM PROVIDERS
// ============================================

class ChatRoomScreen extends ConsumerWidget {
  final String conversationId;

  const ChatRoomScreen({required this.conversationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(chatProvider(conversationId));

    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (messages) {
                return ListView.builder(
                  reverse: true, // Latest at bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageBubble(message: message);
                  },
                );
              },
            ),
          ),
          ChatInput(
            onSend: (content) {
              ref.read(chatProvider(conversationId).notifier).sendMessage(
                content: content,
              );
            },
          ),
        ],
      ),
    );
  }
}

// Mock widgets
class MessageBubble extends StatelessWidget {
  final MessageModel message;

  const MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.senderId == 'current_user_id';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.content ?? '',
          style: TextStyle(color: isMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}

class ChatInput extends StatefulWidget {
  final Function(String) onSend;

  const ChatInput({required this.onSend});

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          FloatingActionButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                widget.onSend(_controller.text);
                _controller.clear();
              }
            },
            child: Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
