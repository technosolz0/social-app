import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../data/models/comment_model.dart';
import '../../../data/models/post_model.dart';
import '../../../data/services/api_service.dart';
import '../../../core/extensions/datetime_extension.dart';
import '../../providers/auth_provider.dart';

// ============================================
// lib/presentation/widgets/post/comment_bottom_sheet.dart
// 💬 INSTAGRAM-STYLE COMMENT BOTTOM SHEET
// ============================================

class CommentBottomSheet extends ConsumerStatefulWidget {
  final PostModel post;

  const CommentBottomSheet({super.key, required this.post});

  static void show(BuildContext context, PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => CommentBottomSheet(post: post),
    );
  }

  @override
  ConsumerState<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends ConsumerState<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final apiService = ApiService();
      final commentsData = await apiService.getPostComments(widget.post.id);
      final comments = commentsData
          .map((json) => CommentModel.fromJson(json))
          .toList();
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load comments: $e')));
      }
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    if (mounted) setState(() => _isSubmitting = true);
    try {
      final apiService = ApiService();
      final newCommentData = await apiService.addPostComment(
        widget.post.id,
        text,
      );
      final newComment = CommentModel.fromJson(newCommentData);

      if (mounted) {
        setState(() {
          _comments.insert(0, newComment);
          _commentController.clear();
        });
      }

      // Scroll to top to show new comment
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to post comment: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _likeComment(String commentId) async {
    final commentIndex = _comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) return;

    final comment = _comments[commentIndex];
    final wasLiked = comment.isLiked;

    // Optimistic update
    if (mounted) {
      setState(() {
        _comments[commentIndex] = comment.copyWith(
          isLiked: !wasLiked,
          likesCount: wasLiked
              ? (comment.likesCount - 1).clamp(0, 999999)
              : comment.likesCount + 1,
        );
      });
    }

    try {
      final apiService = ApiService();
      if (wasLiked) {
        await apiService.unlikeComment(commentId);
      } else {
        await apiService.likeComment(commentId);
      }
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _comments[commentIndex] = comment;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update like: $e')));
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Optimistically remove from UI
    final commentIndex = _comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) return;
    final removedComment = _comments[commentIndex];

    if (mounted) {
      setState(() {
        _comments.removeAt(commentIndex);
      });
    }

    try {
      final apiService = ApiService();
      await apiService.customRequest(
        method: 'DELETE',
        path: '/comments/$commentId/',
      );
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _comments.insert(commentIndex, removedComment);
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete comment: $e')));
      }
    }
  }

  Future<void> _replyToComment(String commentId, String username) async {
    _commentController.text = '@$username ';
    _commentController.selection = TextSelection.fromPosition(
      TextPosition(offset: _commentController.text.length),
    );
  }

  Future<void> _submitReply(String parentCommentId, String text) async {
    if (text.trim().isEmpty) return;

    if (mounted) setState(() => _isSubmitting = true);
    try {
      final apiService = ApiService();
      final replyData = await apiService.addPostComment(
        widget.post.id,
        text,
        parentId: parentCommentId,
      );
      final reply = CommentModel.fromJson(replyData);

      // Find parent comment and add reply
      final parentIndex = _comments.indexWhere((c) => c.id == parentCommentId);
      if (parentIndex != -1) {
        final parentComment = _comments[parentIndex];
        final updatedReplies = [...parentComment.replies, reply];
        final updatedComment = parentComment.copyWith(replies: updatedReplies);

        if (mounted) {
          setState(() {
            _comments[parentIndex] = updatedComment;
            _commentController.clear();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to post reply: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteReply(String commentId, String replyId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reply'),
        content: const Text('Are you sure you want to delete this reply?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Find parent comment and remove reply
    final parentIndex = _comments.indexWhere((c) => c.id == commentId);
    if (parentIndex == -1) return;

    final parentComment = _comments[parentIndex];
    final replyIndex = parentComment.replies.indexWhere((r) => r.id == replyId);
    if (replyIndex == -1) return;

    final removedReply = parentComment.replies[replyIndex];
    final updatedReplies = [...parentComment.replies]..removeAt(replyIndex);
    final updatedComment = parentComment.copyWith(replies: updatedReplies);

    if (mounted) {
      setState(() {
        _comments[parentIndex] = updatedComment;
      });
    }

    try {
      final apiService = ApiService();
      await apiService.customRequest(
        method: 'DELETE',
        path: '/comments/$replyId/',
      );
    } catch (e) {
      // Revert on error
      final revertedReplies = [...updatedReplies]
        ..insert(replyIndex, removedReply);
      final revertedComment = parentComment.copyWith(replies: revertedReplies);
      if (mounted) {
        setState(() {
          _comments[parentIndex] = revertedComment;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete reply: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Comments list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _comments.isEmpty
                  ? const Center(
                      child: Text(
                        'No comments yet.\nBe the first to comment!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        final currentUserId = ref
                            .watch(authNotifierProvider)
                            .user
                            ?.id;
                        return CommentItem(
                          comment: comment,
                          currentUserId: currentUserId,
                          onLike: () => _likeComment(comment.id),
                          onReply: () => _replyToComment(
                            comment.id,
                            comment.user.username,
                          ),
                          onDelete: () => _deleteComment(comment.id),
                          onReplySubmit: _submitReply,
                          onReplyDelete: (replyId) =>
                              _deleteReply(comment.id, replyId),
                        );
                      },
                    ),
            ),

            // Comment input
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!, width: 0.5),
                ),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  // User avatar
                  CircleAvatar(
                    radius: 18,
                    backgroundImage:
                        ref.watch(authNotifierProvider).user?.avatar != null
                        ? NetworkImage(
                            ref.watch(authNotifierProvider).user!.avatar!,
                          )
                        : null,
                    backgroundColor: Colors.grey[200],
                    child: ref.watch(authNotifierProvider).user?.avatar == null
                        ? const Icon(Icons.person, size: 20, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Text field
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onChanged: (value) {
                        if (mounted) setState(() {});
                      },
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),

                  // Post button
                  TextButton(
                    onPressed: () {
                      _isSubmitting || _commentController.text.trim().isEmpty
                          ? null
                          : _submitComment();
                      Navigator.pop(context);
                    },
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Post',
                            style: TextStyle(
                              color: _commentController.text.trim().isEmpty
                                  ? Colors.grey
                                  : Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================
// COMMENT ITEM WIDGET
// ============================================

class CommentItem extends StatefulWidget {
  final CommentModel comment;
  final String? currentUserId;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  final Function(String, String)? onReplySubmit;
  final Function(String)? onReplyDelete;

  const CommentItem({
    super.key,
    required this.comment,
    this.currentUserId,
    required this.onLike,
    required this.onReply,
    required this.onDelete,
    this.onReplySubmit,
    this.onReplyDelete,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem>
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

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _pointsAnimationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    widget.onLike();

    // Show heart animation
    if (mounted) setState(() => _showHeartAnimation = true);
    _likeAnimationController.forward(from: 0).then((_) {
      if (mounted) setState(() => _showHeartAnimation = false);
    });

    // Show points animation if liking (not unliking)
    if (!widget.comment.isLiked) {
      if (mounted) setState(() => _showPointsAnimation = true);
      _pointsAnimationController.forward(from: 0).then((_) {
        if (mounted) setState(() => _showPointsAnimation = false);
      });
    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.comment.user.id == widget.currentUserId)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onDelete();
                },
              ),
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                widget.onReply();
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Comment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Why are you reporting this comment?'),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text('Spam'),
              value: 'spam',
              groupValue: null,
              onChanged: (value) {
                Navigator.pop(context);
                _submitReport('spam');
              },
            ),
            RadioListTile<String>(
              title: const Text('Harassment'),
              value: 'harassment',
              groupValue: null,
              onChanged: (value) {
                Navigator.pop(context);
                _submitReport('harassment');
              },
            ),
            RadioListTile<String>(
              title: const Text('Inappropriate content'),
              value: 'inappropriate',
              groupValue: null,
              onChanged: (value) {
                Navigator.pop(context);
                _submitReport('inappropriate');
              },
            ),
            RadioListTile<String>(
              title: const Text('Hate speech'),
              value: 'hate_speech',
              groupValue: null,
              onChanged: (value) {
                Navigator.pop(context);
                _submitReport('hate_speech');
              },
            ),
            RadioListTile<String>(
              title: const Text('Other'),
              value: 'other',
              groupValue: null,
              onChanged: (value) {
                Navigator.pop(context);
                _submitReport('other');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _submitReport(String reason) async {
    try {
      final apiService = ApiService();
      await apiService.customRequest(
        method: 'POST',
        path: '/reports/',
        data: {
          'content_type': 'comment',
          'content_id': widget.comment.id,
          'reason': reason,
          'description': 'Reported from comment options',
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment reported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to report comment: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User avatar
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                  widget.comment.user.avatar ?? 'https://picsum.photos/32',
                ),
              ),
              const SizedBox(width: 12),

              // Comment content
              Expanded(
                child: GestureDetector(
                  onLongPress: () => _showOptions(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username and comment text
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${widget.comment.user.username} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: widget.comment.text,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Time and actions
                      Row(
                        children: [
                          Text(
                            timeago.format(widget.comment.createdAt),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (widget.comment.likesCount > 0)
                            Text(
                              '${widget.comment.likesCount} ${widget.comment.likesCount == 1 ? 'like' : 'likes'}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: widget.onReply,
                            child: const Text(
                              'Reply',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Replies (if any)
                      if (widget.comment.replies.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            children: widget.comment.replies.map((reply) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 32,
                                  top: 8,
                                ),
                                child: CommentItem(
                                  comment: reply,
                                  currentUserId: widget.currentUserId,
                                  onLike: widget.onReplySubmit != null
                                      ? () =>
                                            widget.onReplySubmit!(reply.id, '')
                                      : () {},
                                  onReply: widget.onReplySubmit != null
                                      ? () => widget.onReplySubmit!(
                                          reply.id,
                                          '@${reply.user.username} ',
                                        )
                                      : () {},
                                  onDelete: widget.onReplyDelete != null
                                      ? () => widget.onReplyDelete!(reply.id)
                                      : () {},
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Like button
              IconButton(
                icon: Icon(
                  widget.comment.isLiked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  size: 16,
                  color: widget.comment.isLiked ? Colors.red : Colors.grey,
                ),
                onPressed: _handleLike,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),

        // Heart animation overlay
        if (_showHeartAnimation)
          Positioned(
            right: 0,
            top: 0,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.2).animate(
                CurvedAnimation(
                  parent: _likeAnimationController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                child: const Icon(Icons.favorite, color: Colors.red, size: 24),
              ),
            ),
          ),

        // Points notification
        if (_showPointsAnimation)
          Positioned(
            right: 40,
            top: 0,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0),
                    end: const Offset(0, -1.5),
                  ).animate(
                    CurvedAnimation(
                      parent: _pointsAnimationController,
                      curve: Curves.easeOut,
                    ),
                  ),
              child: FadeTransition(
                opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                  CurvedAnimation(
                    parent: _pointsAnimationController,
                    curve: const Interval(0.5, 1.0),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '+3 Points',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
