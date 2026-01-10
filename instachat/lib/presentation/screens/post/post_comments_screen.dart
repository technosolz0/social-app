import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/post/comment_bottom_sheet.dart'; // Reuse CommentItem

class PostCommentsScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostCommentsScreen({super.key, required this.postId});

  @override
  ConsumerState<PostCommentsScreen> createState() => _PostCommentsScreenState();
}

class _PostCommentsScreenState extends ConsumerState<PostCommentsScreen> {
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
      final commentsData = await apiService.getPostComments(widget.postId);
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load comments: $e')),
        );
      }
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final apiService = ApiService();
      final newCommentData = await apiService.addComment(widget.postId, text);
      final newComment = CommentModel.fromJson(newCommentData);

      setState(() {
        _comments.insert(0, newComment);
        _commentController.clear();
      });

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post comment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _likeComment(String commentId) async {
    final commentIndex = _comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) return;

    final comment = _comments[commentIndex];
    final wasLiked = comment.isLiked;

    setState(() {
      _comments[commentIndex] = comment.copyWith(
        isLiked: !wasLiked,
        likesCount: wasLiked ? (comment.likesCount - 1).clamp(0, 999999) : comment.likesCount + 1,
      );
    });

    try {
      final apiService = ApiService();
      if (wasLiked) {
        await apiService.unlikeComment(commentId);
      } else {
        await apiService.likeComment(commentId);
      }
    } catch (e) {
      setState(() {
        _comments[commentIndex] = comment;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update like: $e')),
        );
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
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

    final commentIndex = _comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) return;
    final removedComment = _comments[commentIndex];
    
    setState(() {
      _comments.removeAt(commentIndex);
    });

    try {
      final apiService = ApiService();
      await apiService.customRequest(
        method: 'DELETE',
        path: '/comments/$commentId/',
      );
    } catch (e) {
      setState(() {
        _comments.insert(commentIndex, removedComment);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete comment: $e')),
        );
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

    setState(() => _isSubmitting = true);
    try {
      final apiService = ApiService();
      final replyData = await apiService.addComment(widget.postId, text, parentId: parentCommentId);
      final reply = CommentModel.fromJson(replyData);

      final parentIndex = _comments.indexWhere((c) => c.id == parentCommentId);
      if (parentIndex != -1) {
        final parentComment = _comments[parentIndex];
        final updatedReplies = [...parentComment.replies, reply];
        final updatedComment = parentComment.copyWith(replies: updatedReplies);

        setState(() {
          _comments[parentIndex] = updatedComment;
          _commentController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post reply: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _deleteReply(String commentId, String replyId) async {
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

    final parentIndex = _comments.indexWhere((c) => c.id == commentId);
    if (parentIndex == -1) return;

    final parentComment = _comments[parentIndex];
    final replyIndex = parentComment.replies.indexWhere((r) => r.id == replyId);
    if (replyIndex == -1) return;

    final removedReply = parentComment.replies[replyIndex];
    final updatedReplies = [...parentComment.replies]..removeAt(replyIndex);
    final updatedComment = parentComment.copyWith(replies: updatedReplies);

    setState(() {
      _comments[parentIndex] = updatedComment;
    });

    try {
      final apiService = ApiService();
      await apiService.customRequest(
        method: 'DELETE',
        path: '/comments/$replyId/',
      );
    } catch (e) {
      final revertedReplies = [...updatedReplies]..insert(replyIndex, removedReply);
      final revertedComment = parentComment.copyWith(replies: revertedReplies);
      setState(() {
        _comments[parentIndex] = revertedComment;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete reply: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authNotifierProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
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
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return CommentItem(
                            comment: comment,
                            currentUserId: currentUser?.id,
                            onLike: () => _likeComment(comment.id),
                            onReply: () => _replyToComment(comment.id, comment.user.username),
                            onDelete: () => _deleteComment(comment.id),
                            onReplySubmit: _submitReply,
                            onReplyDelete: (replyId) => _deleteReply(comment.id, replyId),
                          );
                        },
                      ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!, width: 0.5)),
              color: Colors.white,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: currentUser?.avatar != null
                      ? NetworkImage(currentUser!.avatar!)
                      : null,
                  backgroundColor: Colors.grey[200],
                  child: currentUser?.avatar == null
                      ? const Icon(Icons.person, size: 20, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
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
                    onChanged: (value) => setState(() {}),
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
                TextButton(
                  onPressed: _isSubmitting || _commentController.text.trim().isEmpty
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
      ),
    );
  }
}
