import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme_constants.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLiked = false;
  int _likesCount = 42;
  int _commentsCount = 5;

  // Mock post data
  final Map<String, dynamic> _postData = {
    'id': '1',
    'user': {
      'username': 'john_doe',
      'avatar': null,
      'isVerified': true,
    },
    'caption': 'Beautiful sunset at the beach! 🌅 #sunset #beach #nature',
    'mediaUrl': 'https://picsum.photos/400/600?random=1',
    'likesCount': 42,
    'commentsCount': 5,
    'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
  };

  // Mock comments
  final List<Map<String, dynamic>> _comments = [
    {
      'id': '1',
      'user': {'username': 'jane_smith', 'avatar': null},
      'text': 'Wow, amazing view! 😍',
      'createdAt': DateTime.now().subtract(const Duration(hours: 1)),
      'likesCount': 3,
    },
    {
      'id': '2',
      'user': {'username': 'mike_johnson', 'avatar': null},
      'text': 'Where was this taken?',
      'createdAt': DateTime.now().subtract(const Duration(minutes: 30)),
      'likesCount': 1,
    },
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'user': {'username': 'current_user', 'avatar': null},
      'text': _commentController.text.trim(),
      'createdAt': DateTime.now(),
      'likesCount': 0,
    };

    setState(() {
      _comments.insert(0, newComment);
      _commentsCount++;
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show post options
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
                          backgroundImage: _postData['user']['avatar'] != null
                              ? NetworkImage(_postData['user']['avatar'])
                              : null,
                          child: _postData['user']['avatar'] == null
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
                                    _postData['user']['username'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (_postData['user']['isVerified']) ...[
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
                                '2h ago',
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

                  // Post Image
                  Image.network(
                    _postData['mediaUrl'],
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.cover,
                  ),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            color: _isLiked ? Colors.red : null,
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
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                    child: Text(
                      '$_likesCount likes',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Caption
                  if (_postData['caption'] != null)
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${_postData['user']['username']} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: _postData['caption'],
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
                        if (_commentsCount > 2)
                          TextButton(
                            onPressed: () {
                              // Show all comments
                            },
                            child: Text('View all $_commentsCount comments'),
                          ),
                        ..._comments.take(2).map((comment) => _buildComment(comment)),
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
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
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
                  onPressed: _addComment,
                  child: const Text(
                    'Post',
                    style: TextStyle(
                      color: Colors.blue,
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

  Widget _buildComment(Map<String, dynamic> comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            backgroundImage: comment['user']['avatar'] != null
                ? NetworkImage(comment['user']['avatar'])
                : null,
            child: comment['user']['avatar'] == null
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
                        text: '${comment['user']['username']} ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: comment['text'],
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '1h ago',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingMedium),
                    Text(
                      '${comment['likesCount']} likes',
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
            icon: const Icon(Icons.favorite_border, size: 16),
            onPressed: () {
              // Like comment
            },
          ),
        ],
      ),
    );
  }
}
