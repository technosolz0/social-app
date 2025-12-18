import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../data/models/user_model.dart';

// ============================================
// lib/presentation/widgets/post/post_header.dart
// 🎨 REUSABLE POST HEADER
// ============================================

class PostHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const PostHeader({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          backgroundImage: user.avatar != null
              ? CachedNetworkImageProvider(user.avatar!)
              : null,
          child: user.avatar == null
              ? Text(user.username[0].toUpperCase())
              : null,
        ),
      ),
      title: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Text(
              user.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (user.isVerified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, size: 14, color: Colors.blue),
          ],
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          _showPostOptions(context);
        },
      ),
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.bookmark_outline),
            title: const Text('Save'),
            onTap: () {
              Navigator.pop(context);
              // Save post
            },
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Copy Link'),
            onTap: () {
              Navigator.pop(context);
              // Copy link
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_outlined),
            title: const Text('Report'),
            onTap: () {
              Navigator.pop(context);
              // Report post
            },
          ),
        ],
      ),
    );
  }
}
