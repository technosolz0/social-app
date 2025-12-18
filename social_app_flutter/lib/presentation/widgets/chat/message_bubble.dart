import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../data/models/message_model.dart';

// ============================================
// lib/presentation/widgets/chat/message_bubble.dart
// Chat Message Bubble
// ============================================

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.messageType == 'image')
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        message.mediaUrl!,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Text(
                      message.content ?? '',
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),

                  const SizedBox(height: 4),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeago.format(message.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe
                            ? Colors.white70
                            : Colors.grey[600],
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead
                            ? Icons.done_all
                            : Icons.done,
                          size: 14,
                          color: message.isRead
                            ? Colors.blue[200]
                            : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
