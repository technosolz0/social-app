import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:ui';

import '../../../data/models/post_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/activity_tracker_provider.dart';
import 'post_actions.dart';
import 'post_caption.dart';
import 'post_header.dart';
import 'post_media.dart';

// ============================================
// lib/presentation/widgets/post/post_card.dart
// 🎨 BEAUTIFUL COLORFUL POST CARD WIDGET
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
    with TickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late AnimationController _pointsAnimationController;
  bool _showHeartAnimation = false;
  bool _showPointsAnimation = false;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pointsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  void _handleLike() {
    widget.onLike();

    // Show heart animation
    setState(() => _showHeartAnimation = true);
    _likeAnimationController.forward(from: 0).then((_) {
      setState(() => _showHeartAnimation = false);
    });

    // Show points animation if liking (not unliking)
    if (!widget.post.isLiked) {
      setState(() => _showPointsAnimation = true);
      _pointsAnimationController.forward(from: 0).then((_) {
        setState(() => _showPointsAnimation = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = AppTheme.getGradientByIndex(widget.post.id.hashCode);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1A1F3A).withValues(alpha: 0.8),
                  const Color(0xFF252B49).withValues(alpha: 0.6),
                ]
              : [Colors.white, Colors.white.withValues(alpha: 0.95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient Header Bar
              Container(
                height: 4,
                decoration: BoxDecoration(gradient: gradient),
              ),

              // Header (Avatar + Username)
              Padding(
                padding: const EdgeInsets.all(16),
                child: PostHeader(
                  user: widget.post.user,
                  onTap: () {
                    ref
                        .read(activityTrackerProvider.notifier)
                        .trackProfileView(widget.post.userId);
                  },
                ),
              ),

              // Media (Image/Video) with Gradient Overlay
              GestureDetector(
                onDoubleTap: () {
                  if (!widget.post.isLiked) {
                    _handleLike();
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Media Content
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          PostMedia(
                            mediaUrl: widget.post.mediaUrl,
                            postType: widget.post.postType,
                            onView: () {
                              ref
                                  .read(activityTrackerProvider.notifier)
                                  .trackPostView(widget.post.id);
                            },
                          ),
                          // Subtle gradient overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.1),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.8),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 100,
                          ),
                        ),
                      ),

                    // Points notification
                    if (_showPointsAnimation)
                      Positioned(
                        top: 60,
                        child: SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(0, 0),
                                end: const Offset(0, -2),
                              ).animate(
                                CurvedAnimation(
                                  parent: _pointsAnimationController,
                                  curve: Curves.easeOut,
                                ),
                              ),
                          child: FadeTransition(
                            opacity: Tween<double>(begin: 1.0, end: 0.0)
                                .animate(
                                  CurvedAnimation(
                                    parent: _pointsAnimationController,
                                    curve: const Interval(0.5, 1.0),
                                  ),
                                ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppTheme.sunsetGradient,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.warningColor.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '+5 Points',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Actions (Like, Comment, Share, Save) with Colorful Icons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PostActions(
                  post: widget.post,
                  onLike: _handleLike,
                  onComment: widget.onComment,
                  onShare: widget.onShare,
                ),
              ),

              // Likes count with gradient
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => gradient.createShader(bounds),
                  child: Text(
                    '${widget.post.likesCount} likes',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Caption
              if (widget.post.caption != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PostCaption(
                    user: widget.post.user,
                    caption: widget.post.caption!,
                    hashtags: widget.post.hashtags,
                  ),
                ),

              // View comments with accent color
              if (widget.post.commentsCount > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: GestureDetector(
                    onTap: widget.onComment,
                    child: Text(
                      'View all ${widget.post.commentsCount} comments',
                      style: TextStyle(
                        color: AppTheme.getSubtitleColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

              // Time ago with icon
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppTheme.getSubtitleColor(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeago.format(widget.post.createdAt),
                      style: TextStyle(
                        color: AppTheme.getSubtitleColor(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _pointsAnimationController.dispose();
    super.dispose();
  }
}
