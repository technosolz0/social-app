import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/message_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/conversation_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/websocket_service.dart';
import '../../data/services/local_storage_service.dart';
import 'auth_provider.dart';
import 'activity_tracker_provider.dart';

class ChatNotifier extends FamilyAsyncNotifier<List<MessageModel>, String> {
  late String _conversationId;
  final ApiService _api = ApiService();
  final WebSocketService _webSocket = WebSocketService();
  final LocalStorageService _storage = LocalStorageService();
  StreamSubscription? _messageSubscription;

  @override
  Future<List<MessageModel>> build(String conversationId) async {
    _conversationId = conversationId;

    // 1. Load from local search immediately
    final localMessages = _storage.getMessagesForConversation(conversationId);

    // 2. Listen for incoming messages from WebSocket
    _messageSubscription?.cancel();
    _messageSubscription = _webSocket.messageStream.listen((message) {
      if (message.conversationId == _conversationId) {
        _onNewMessageReceived(message);
      }
    });

    // 3. Trigger background fetch for older/missed messages
    _loadMessagesFromApi();

    return localMessages;
  }

  void _onNewMessageReceived(MessageModel message) async {
    // 1. Save to local storage
    await _storage.saveMessage(message);
    
    // 2. Update state
    final currentMessages = state.value ?? [];
    if (!currentMessages.any((m) => m.id == message.id)) {
      state = AsyncValue.data([...currentMessages, message]..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
    }
  }

  Future<void> _loadMessagesFromApi() async {
    try {
      final messages = await _api.getConversationMessages(_conversationId);
      for (var msg in messages) {
        await _storage.saveMessage(msg);
      }
      state = AsyncValue.data(_storage.getMessagesForConversation(_conversationId));
    } catch (e) {
      print('Error loading messages from API: $e');
    }
  }

  // Send message
  Future<void> sendMessage({
    required String content,
    String messageType = 'text',
    String? mediaUrl,
    Duration? expiresIn,
  }) async {
    try {
      // 1. Optimistic update (optional, but API call is preferred for getting correct timestamp/id)
      final message = await _api.sendMessage(
        _conversationId,
        messageType: messageType,
        content: content,
        mediaUrl: mediaUrl,
      );

      // 2. Save to local storage
      await _storage.saveMessage(message);

      // 3. Update state
      final currentMessages = state.value ?? [];
      state = AsyncValue.data([...currentMessages, message]..sort((a, b) => b.createdAt.compareTo(a.createdAt)));

      // 4. Send through WebSocket for real-time updates (if required by backend to broadast)
      _webSocket.sendMessage(
        conversationId: _conversationId,
        messageType: messageType,
        content: content,
        mediaUrl: mediaUrl,
      );
    } catch (error) {
      print('Error sending message: $error');
    }
  }

  // Mark messages as read
  Future<void> markAsRead(String messageId) async {
    try {
      await _api.customRequest(
        method: 'POST',
        path: '/api/v1/chat/messages/$messageId/mark_read',
      );
      // Update local message state as read
      final currentMessages = state.value ?? [];
      state = AsyncValue.data(
        currentMessages.map((m) => m.id == messageId ? m.copyWith(isRead: true) : m).toList(),
      );
    } catch (error) {
      print('Error marking message as read: $error');
    }
  }

  // Refresh messages manually
  Future<void> refreshMessages() async {
    state = const AsyncValue.loading();
    await _loadMessagesFromApi();
  }
}

final chatProvider = AsyncNotifierProvider.family<
  ChatNotifier,
  List<MessageModel>,
  String
>(ChatNotifier.new);

// ============================================
// 🎓 USING STREAM PROVIDERS
// ============================================

class ChatRoomScreen extends ConsumerWidget {
  final String conversationId;

  const ChatRoomScreen({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(chatProvider(conversationId));

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
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

// Message bubble widget
class MessageBubble extends ConsumerWidget {
  final MessageModel message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final currentUserId = authState.user?.id;
    final isMe = message.sender.id == currentUserId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
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

  const ChatInput({super.key, required this.onSend});

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
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
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                widget.onSend(_controller.text);
                _controller.clear();
              }
            },
            child: const Icon(Icons.send),
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
