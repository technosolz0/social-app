import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../data/models/comment_model.dart';
import '../../../data/models/post_model.dart';
import '../../../data/services/api_service.dart';
import '../../../core/extensions/datetime_extension.dart';

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
    setState(() => _isLoading = true);
    try {
      final apiService = ApiService();
      final commentsData = await apiService.getPostComments(widget.post.id);
      final comments = commentsData
          .map((json) => CommentModel.fromJson(json))
          .toList();
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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

    setState(() => _isSubmitting = true);
    try {
      final apiService = ApiService();
      final newCommentData = await apiService.addComment(widget.post.id, text);
      final newComment = CommentModel.fromJson(newCommentData);

      setState(() {
        _comments.insert(0, newComment);
        _commentController.clear();
      });

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
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _likeComment(String commentId) async {
    final commentIndex = _comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) return;

    final comment = _comments[commentIndex];
    final wasLiked = comment.isLiked;

    // Optimistic update
    setState(() {
      _comments[commentIndex] = comment.copyWith(
        isLiked: !wasLiked,
        likesCount: wasLiked ? comment.likesCount - 1 : comment.likesCount + 1,
      );
    });

    try {
      final apiService = ApiService();
      if (wasLiked) {
        // Unlike - assuming there's an unlike method, or we can use the same endpoint
        await apiService.likeComment(
          commentId,
        ); // This might need to be unlikeComment
      } else {
        await apiService.likeComment(commentId);
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _comments[commentIndex] = comment;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to like comment: $e')));
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${widget.post.commentsCount} Comments',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
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
                        return CommentItem(
                          comment: comment,
                          onLike: () => _likeComment(comment.id),
                          onReply: () {
                            // TODO: Implement reply functionality
                            _commentController.text =
                                '@${comment.user.username} ';
                            _commentController.selection =
                                TextSelection.fromPosition(
                                  TextPosition(
                                    offset: _commentController.text.length,
                                  ),
                                );
                          },
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
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  // User avatar
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      'https://picsum.photos/32',
                    ), // TODO: Use actual user avatar
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
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),

                  // Post button
                  TextButton(
                    onPressed:
                        _isSubmitting || _commentController.text.trim().isEmpty
                        ? null
                        : _submitComment,
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

class CommentItem extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback onLike;
  final VoidCallback onReply;

  const CommentItem({
    super.key,
    required this.comment,
    required this.onLike,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(
              comment.user.avatar ?? 'https://picsum.photos/32',
            ),
          ),
          const SizedBox(width: 12),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username and comment text
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${comment.user.username} ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: comment.text,
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
                      timeago.format(comment.createdAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    if (comment.likesCount > 0)
                      Text(
                        '${comment.likesCount} ${comment.likesCount == 1 ? 'like' : 'likes'}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: onReply,
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
                if (comment.replies.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      children: comment.replies.map((reply) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 32, top: 8),
                          child: CommentItem(
                            comment: reply,
                            onLike: () {}, // TODO: Implement reply liking
                            onReply: () {}, // TODO: Implement nested replies
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),

          // Like button
          IconButton(
            icon: Icon(
              comment.isLiked ? Icons.favorite : Icons.favorite_border,
              size: 16,
              color: comment.isLiked ? Colors.red : Colors.grey,
            ),
            onPressed: onLike,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
