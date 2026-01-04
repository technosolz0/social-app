import 'package:flutter/material.dart';

import '../../../data/models/user_model.dart';

// ============================================
// lib/presentation/widgets/post/post_caption.dart
// 🎨 REUSABLE CAPTION WIDGET
// ============================================

class PostCaption extends StatelessWidget {
  final UserModel user;
  final String caption;
  final List<String> hashtags;

  const PostCaption({
    super.key,
    required this.user,
    required this.caption,
    required this.hashtags,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${user.username} ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: caption,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
