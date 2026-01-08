import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/post_model.dart';
import '../../../data/services/api_service.dart';
import '../../widgets/post/comment_bottom_sheet.dart';

class ReelsFeedScreen extends ConsumerStatefulWidget {
  const ReelsFeedScreen({super.key});

  @override
  ConsumerState<ReelsFeedScreen> createState() => _ReelsFeedScreenState();
}

class _ReelsFeedScreenState extends ConsumerState<ReelsFeedScreen> {
  final PageController _pageController = PageController();
  List<PostModel> _reels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReels();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadReels() async {
    try {
      final apiService = ApiService();
      // Fetch reels using custom request since explicit method might be missing
      final response = await apiService.customRequest(
        method: 'GET',
        path: '/reels/',
      );
      
      final List<dynamic> data = response.data['results'] ?? response.data;
      final reels = data.map((json) => PostModel.fromJson(json)).toList();
      
      if (mounted) {
        setState(() {
          _reels = reels;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // Fallback for demo/mock if API fails
        setState(() {
          _isLoading = false;
          // Use empty list or mock data
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_reels.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.white),
        ),
        body: const Center(
          child: Text(
            'No Reels found',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _reels.length,
            itemBuilder: (context, index) {
              return ReelItem(post: _reels[index]);
            },
          ),
          // Floating Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class ReelItem extends StatefulWidget {
  final PostModel post;

  const ReelItem({super.key, required this.post});

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  late VideoPlayerController _videoController;
  bool _initialized = false;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.network(widget.post.mediaUrl);
    try {
      await _videoController.initialize();
      await _videoController.setLooping(true);
      await _videoController.play();
      if (mounted) {
        setState(() => _initialized = true);
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  void _togglePlay() {
    if (_initialized) {
      setState(() {
        if (_videoController.value.isPlaying) {
          _videoController.pause();
          _isPlaying = false;
        } else {
          _videoController.play();
          _isPlaying = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Layer
        GestureDetector(
          onTap: _togglePlay,
          child: Container(
            color: Colors.black,
            child: _initialized
                ? AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: VideoPlayer(_videoController),
                  )
                : const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),
        ),

        // Play/Pause Icon Overlay
        if (!_isPlaying && _initialized)
          const Center(
            child: Icon(Icons.play_circle_outline, size: 80, color: Colors.white54),
          ),

        // Overlay Info Layer
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black87],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: widget.post.user.avatar != null
                                ? NetworkImage(widget.post.user.avatar!)
                                : null,
                            child: widget.post.user.avatar == null
                                ? const Icon(Icons.person, size: 16)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.post.user.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Follow', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (widget.post.caption != null)
                        Text(
                          widget.post.caption!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                      const SizedBox(height: 10),
                      // Music/Audio Mock
                      const Row(
                        children: [
                          Icon(Icons.music_note, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Original Audio',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Side Action Buttons
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionButton(
                      icon: Icons.favorite,
                      label: widget.post.likesCount.toString(),
                      color: widget.post.isLiked ? Colors.red : Colors.white,
                      onTap: () {
                        // TODO: Implement like
                      },
                    ),
                    const SizedBox(height: 20),
                    _ActionButton(
                      icon: Icons.comment,
                      label: widget.post.commentsCount.toString(),
                      onTap: () {
                        CommentBottomSheet.show(context, widget.post);
                      },
                    ),
                    const SizedBox(height: 20),
                    _ActionButton(
                      icon: Icons.share,
                      label: 'Share',
                      onTap: () {},
                    ),
                    const SizedBox(height: 20),
                    _ActionButton(
                      icon: Icons.more_vert,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    this.label,
    this.color = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30, color: color),
          onPressed: onTap,
        ),
        if (label != null)
          Text(
            label!,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
      ],
    );
  }
}
