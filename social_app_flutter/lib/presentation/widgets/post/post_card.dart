import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../data/models/post_model.dart';
import '../../providers/activity_tracker_provider.dart';
import 'post_actions.dart';
import 'post_caption.dart';
import 'post_header.dart';
import 'post_media.dart';

// ============================================
// lib/presentation/widgets/post/post_card.dart
// 🎨 REUSABLE POST CARD WIDGET
// ============================================

class PostCard extends ConsumerStatefulWidget {
  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  bool _showHeartAnimation = false;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header (Avatar + Username)
        PostHeader(
          user: widget.post.user,
          onTap: () {
            // Track profile view
            ref.read(activityTrackerProvider.notifier)
                .trackProfileView(widget.post.userId);
            // context.push('/profile/${widget.post.userId}');
          },
        ),

        // Media (Image/Video)
        GestureDetector(
          onDoubleTap: () {
            if (!widget.post.isLiked) {
              widget.onLike();
              _showHeartAnimation = true;
              _likeAnimationController.forward(from: 0).then((_) {
                setState(() => _showHeartAnimation = false);
              });
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              PostMedia(
                mediaUrl: widget.post.mediaUrl,
                postType: widget.post.postType,
                onView: () {
                  // Track post view
                  ref.read(activityTrackerProvider.notifier)
                      .trackPostView(widget.post.id);
                },
              ),

              // Heart animation on double tap
              if (_showHeartAnimation)
                ScaleTransition(
                  scale: Tween<double>(begin: 0.5, end: 1.2).animate(
                    CurvedAnimation(
                      parent: _likeAnimationController,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 100,
                  ),
                ),
            ],
          ),
        ),

        // Actions (Like, Comment, Share, Save)
        PostActions(
          post: widget.post,
          onLike: widget.onLike,
          onComment: widget.onComment,
          onShare: widget.onShare,
        ),

        // Likes count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${widget.post.likesCount} likes',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        // Caption
        if (widget.post.caption != null)
          PostCaption(
            user: widget.post.user,
            caption: widget.post.caption!,
            hashtags: widget.post.hashtags,
          ),

        // View comments
        if (widget.post.commentsCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: GestureDetector(
              onTap: widget.onComment,
              child: Text(
                'View all ${widget.post.commentsCount} comments',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),

        // Time ago
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            timeago.format(widget.post.createdAt),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),

        const Divider(height: 1),
      ],
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }
}
