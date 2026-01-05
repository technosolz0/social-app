import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:instachat/data/models/message_model.dart';

import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/chat/chat_input.dart' as chat_widgets;
import '../../widgets/chat/message_bubble.dart' as chat_widgets;
import 'package:image_picker/image_picker.dart';

// ============================================
// lib/presentation/screens/chat/chat_room_screen.dart
// Instagram-like Chat with Disappearing Messages
// ============================================

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final UserModel? otherUser;

  const ChatRoomScreen({
    super.key,
    required this.conversationId,
    this.otherUser,
  });

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showEmojiPicker = false;
  Duration? _disappearDuration;

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatProvider(widget.conversationId));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.otherUser?.avatar != null
                  ? NetworkImage(widget.otherUser!.avatar!)
                  : null,
              radius: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUser?.username ?? 'Chat',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Text(
                    'Active now',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {
              // Start video call
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              context.push('/chat-settings/${widget.conversationId}');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Disappearing messages banner
          if (_disappearDuration != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.blue.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Messages disappear after ${_disappearDuration!.inHours}h',
                    style: const TextStyle(fontSize: 12),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _disappearDuration = null);
                    },
                    child: const Text('Turn off'),
                  ),
                ],
              ),
            ),

          // Messages List
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Say hi! 👋'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe =
                        message.sender.id ==
                        ref.read(authNotifierProvider).user!.id;

                    return chat_widgets.MessageBubble(
                      message: message,
                      isMe: isMe,
                      onLongPress: () {
                        _showMessageOptions(message);
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Emoji Picker
          if (_showEmojiPicker)
            SizedBox(
              height: 250,
              child: Container(
                color: Colors.grey[100],
                child: const Center(child: Text('Emoji Picker Placeholder')),
              ),
            ),

          // Message Input
          chat_widgets.ChatInput(
            controller: _messageController,
            onSend: (content) {
              _sendMessage(content);
            },
            onEmojiTap: () {
              setState(() => _showEmojiPicker = !_showEmojiPicker);
            },
            onCameraTap: () {
              _openCamera();
            },
            onGalleryTap: () {
              _pickImage();
            },
            onVoiceTap: () {
              _recordVoice();
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(String content) {
    if (content.trim().isEmpty) return;

    ref
        .read(chatProvider(widget.conversationId).notifier)
        .sendMessage(content: content, expiresIn: _disappearDuration);

    _messageController.clear();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _showChatSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Disappearing Messages'),
            trailing: Switch(
              value: _disappearDuration != null,
              onChanged: (value) {
                Navigator.pop(context);
                _showDisappearingOptions();
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Block User'),
            onTap: () {
              Navigator.pop(context);
              // Block user
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Report'),
            onTap: () {
              Navigator.pop(context);
              // Report chat
            },
          ),
        ],
      ),
    );
  }

  void _showDisappearingOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disappearing Messages'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Duration>(
              title: const Text('Off'),
              value: Duration.zero,
              groupValue: _disappearDuration ?? Duration.zero,
              onChanged: (value) {
                setState(() => _disappearDuration = null);
                Navigator.pop(context);
              },
            ),
            RadioListTile<Duration>(
              title: const Text('24 hours'),
              value: const Duration(hours: 24),
              groupValue: _disappearDuration ?? Duration.zero,
              onChanged: (value) {
                setState(() => _disappearDuration = value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<Duration>(
              title: const Text('7 days'),
              value: const Duration(days: 7),
              groupValue: _disappearDuration ?? Duration.zero,
              onChanged: (value) {
                setState(() => _disappearDuration = value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<Duration>(
              title: const Text('90 days'),
              value: const Duration(days: 90),
              groupValue: _disappearDuration ?? Duration.zero,
              onChanged: (value) {
                setState(() => _disappearDuration = value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(MessageModel message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.reply),
            title: const Text('Reply'),
            onTap: () {
              Navigator.pop(context);
              // Reply to message
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy'),
            onTap: () {
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(text: message.content ?? ''));
            },
          ),
          if (message.sender.id == ref.read(authNotifierProvider).user!.id)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Unsend', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                ref.read(chatProvider(widget.conversationId).notifier).unsendMessage(message.id);
              },
            ),
        ],
      ),
    );
  }

  Future<void> _openCamera() async {
    final storageService = ref.read(storageServiceProvider);
    final file = await storageService.pickImage(source: ImageSource.camera);
    
    if (file != null) {
      final url = await storageService.uploadImage(file);
      if (url != null) {
        ref.read(chatProvider(widget.conversationId).notifier).sendMessage(
          content: '',
          messageType: 'image',
          mediaUrl: url,
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final storageService = ref.read(storageServiceProvider);
    final file = await storageService.pickImage(source: ImageSource.gallery);

    if (file != null) {
      final url = await storageService.uploadImage(file);
      if (url != null) {
        ref.read(chatProvider(widget.conversationId).notifier).sendMessage(
          content: '',
          messageType: 'image',
          mediaUrl: url,
        );
      }
    }
  }

  Future<void> _recordVoice() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice recording coming soon!')),
    );
  }

  Future<String> _uploadFile(File file) async {
    // Upload to server and return URL
    final url = await ref.read(storageServiceProvider).uploadFile(file);
    return url ?? 'https://example.com/uploaded_file.jpg'; // Fallback URL
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
