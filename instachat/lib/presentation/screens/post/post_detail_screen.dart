import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/services/api_service.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  PostModel? _post;
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  bool _isLoadingComments = false;
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _loadPost();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadPost() async {
    try {
      final apiService = ApiService();
      final post = await apiService.getPostById(widget.postId);
      setState(() {
        _post = post;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load post: $e')));
      }
    }
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);
    try {
      final apiService = ApiService();
      final commentsData = await apiService.getPostComments(widget.postId);
      final comments = commentsData
          .map((json) => CommentModel.fromJson(json))
          .toList();
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() => _isLoadingComments = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load comments: $e')));
      }
    }
  }

  Future<void> _toggleLike() async {
    if (_post == null) return;

    final wasLiked = _post!.isLiked;
    final newLikesCount = wasLiked
        ? (_post!.likesCount - 1).clamp(0, 999999)
        : _post!.likesCount + 1;

    setState(() {
      _post = _post!.copyWith(isLiked: !wasLiked, likesCount: newLikesCount);
    });

    try {
      final apiService = ApiService();
      if (wasLiked) {
        await apiService.unlikePost(_post!.id);
      } else {
        await apiService.likePost(_post!.id);
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _post = _post!.copyWith(
          isLiked: wasLiked,
          likesCount: _post!.likesCount,
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update like: $e')));
      }
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _post == null) return;

    setState(() => _isSubmittingComment = true);

    try {
      final apiService = ApiService();
      final commentData = await apiService.addPostComment(_post!.id, text);
      final newComment = CommentModel.fromJson(commentData);

      setState(() {
        _comments.insert(0, newComment);
        _post = _post!.copyWith(commentsCount: _post!.commentsCount + 1);
        _commentController.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to post comment: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmittingComment = false);
      }
    }
  }

  Future<void> _likeComment(String commentId) async {
    final commentIndex = _comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) return;

    final comment = _comments[commentIndex];
    final wasLiked = comment.isLiked;
    final newLikesCount = wasLiked
        ? (comment.likesCount - 1).clamp(0, 999999)
        : comment.likesCount + 1;

    setState(() {
      _comments[commentIndex] = comment.copyWith(
        isLiked: !wasLiked,
        likesCount: newLikesCount,
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
      // Revert on error
      setState(() {
        _comments[commentIndex] = comment;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update comment like: $e')),
        );
      }
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_post == null) {
      return const Scaffold(body: Center(child: Text('Post not found')));
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Post'),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Show post options (share, report, etc.)
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Post Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post Header
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _post!.user.avatar != null
                                ? NetworkImage(_post!.user.avatar!)
                                : null,
                            child: _post!.user.avatar == null
                                ? const Icon(Icons.person, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: AppSizes.paddingMedium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _post!.user.username,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (_post!.user.isVerified) ...[
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.verified,
                                        size: 14,
                                        color: Colors.blue,
                                      ),
                                    ],
                                  ],
                                ),
                                Text(
                                  _formatTimeAgo(_post!.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    // Post Media
                    if (_post!.postType == 'video')
                      Container(
                        width: double.infinity,
                        height: 400,
                        color: Colors.black,
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      )
                    else
                      Image.network(
                        _post!.mediaUrl,
                        width: double.infinity,
                        height: 400,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 400,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.error,
                              size: 48,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),

                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _post!.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _post!.isLiked ? Colors.red : null,
                            ),
                            onPressed: _toggleLike,
                          ),
                          IconButton(
                            icon: const Icon(Icons.comment_outlined),
                            onPressed: () {
                              // Focus on comment input
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.send_outlined),
                            onPressed: () {
                              // Share post
                            },
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.bookmark_border),
                            onPressed: () {
                              // Save post
                            },
                          ),
                        ],
                      ),
                    ),

                    // Likes Count
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingMedium,
                      ),
                      child: Text(
                        '${_post!.likesCount} likes',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Caption
                    if (_post!.caption != null && _post!.caption!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${_post!.user.username} ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: _post!.caption,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Comments Section
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_post!.commentsCount > 2)
                            TextButton(
                              onPressed: () {
                                // Navigate to full comments screen
                              },
                              child: Text(
                                'View all ${_post!.commentsCount} comments',
                              ),
                            ),
                          if (_isLoadingComments)
                            const Center(child: CircularProgressIndicator())
                          else
                            ..._comments
                                .take(2)
                                .map((comment) => _buildComment(comment)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Comment Input
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _addComment(),
                    ),
                  ),
                  TextButton(
                    onPressed:
                        _isSubmittingComment ||
                            _commentController.text.trim().isEmpty
                        ? null
                        : _addComment,
                    child: _isSubmittingComment
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
      ),
    );
  }

  Widget _buildComment(CommentModel comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            backgroundImage: comment.user.avatar != null
                ? NetworkImage(comment.user.avatar!)
                : null,
            child: comment.user.avatar == null
                ? const Icon(Icons.person, size: 16, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Row(
                  children: [
                    Text(
                      _formatTimeAgo(comment.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: AppSizes.paddingMedium),
                    Text(
                      '${comment.likesCount} likes',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingMedium),
                    GestureDetector(
                      onTap: () {
                        // Reply to comment
                      },
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              comment.isLiked ? Icons.favorite : Icons.favorite_border,
              size: 16,
              color: comment.isLiked ? Colors.red : null,
            ),
            onPressed: () => _likeComment(comment.id),
          ),
        ],
      ),
    );
  }
}
