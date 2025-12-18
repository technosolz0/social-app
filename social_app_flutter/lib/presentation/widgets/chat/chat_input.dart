import 'package:flutter/material.dart';

// ============================================
// lib/presentation/widgets/chat/chat_input.dart
// Chat Input Widget with Attachments
// ============================================

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final VoidCallback onEmojiTap;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final VoidCallback onVoiceTap;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onEmojiTap,
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.onVoiceTap,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          // Camera button
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: widget.onCameraTap,
          ),

          // Gallery button
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: widget.onGalleryTap,
          ),

          // Text input
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                  ),

                  // Emoji button
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions),
                    onPressed: widget.onEmojiTap,
                  ),
                ],
              ),
            ),
          ),

          // Voice/Send button
          IconButton(
            icon: Icon(
              widget.controller.text.isEmpty
                ? Icons.mic
                : Icons.send,
              color: widget.controller.text.isEmpty
                ? Colors.grey
                : Colors.blue,
            ),
            onPressed: () {
              if (widget.controller.text.isNotEmpty) {
                widget.onSend(widget.controller.text);
              } else {
                widget.onVoiceTap();
              }
            },
          ),
        ],
      ),
    );
  }
}
