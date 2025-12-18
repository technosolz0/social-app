import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/post_model.dart';

// ============================================
// lib/presentation/widgets/post/post_actions.dart
// 🎨 REUSABLE ACTION BUTTONS
// ============================================

class PostActions extends ConsumerWidget {
  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const PostActions({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Like button
          IconButton(
            icon: Icon(
              post.isLiked ? Icons.favorite : Icons.favorite_border,
              color: post.isLiked ? Colors.red : null,
            ),
            onPressed: onLike,
          ),

          // Comment button
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: onComment,
          ),

          // Share button
          IconButton(
            icon: const Icon(Icons.send_outlined),
            onPressed: onShare,
          ),

          const Spacer(),

          // Save button
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // Save post
              // ref.read(savedPostsProvider.notifier).savePost(post.id);
            },
          ),
        ],
      ),
    );
  }
}
