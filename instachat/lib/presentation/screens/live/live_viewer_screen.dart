import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';

class LiveViewerScreen extends ConsumerStatefulWidget {
  final String streamId;

  const LiveViewerScreen({super.key, required this.streamId});

  @override
  ConsumerState<LiveViewerScreen> createState() => _LiveViewerScreenState();
}

class _LiveViewerScreenState extends ConsumerState<LiveViewerScreen> {
  late VideoPlayerController _videoController;
  final TextEditingController _commentController = TextEditingController();
  final List<String> _comments = [];
  bool _isPlaying = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _mockComments();
  }

  Future<void> _initializePlayer() async {
    // Mock HLS stream (Big Buck Bunny or similar)
    const mockUrl =
        'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8';

    _videoController = VideoPlayerController.networkUrl(Uri.parse(mockUrl));

    try {
      await _videoController.initialize();
      await _videoController.play();
      setState(() => _isPlaying = true);
    } catch (e) {
      debugPrint('Error loading stream: $e');
      setState(() => _isError = true);
    }
  }

  void _mockComments() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _comments.add('User${DateTime.now().second}: nice stream! 🔥');
          if (_comments.length > 20) _comments.removeAt(0);
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _sendComment() {
    if (_commentController.text.trim().isEmpty) return;
    setState(() {
      _comments.add('Me: ${_commentController.text}');
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Player
          Center(
            child: _isError
                ? const Text(
                    'Stream not available',
                    style: TextStyle(color: Colors.white),
                  )
                : _isPlaying
                ? AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: VideoPlayer(_videoController),
                  )
                : const CircularProgressIndicator(),
          ),

          // Gradient Overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black54, Colors.transparent, Colors.black87],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.3, 1.0],
              ),
            ),
          ),

          // Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=3',
                    ),
                    radius: 18,
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'StreamerUser',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ViewCountBadge(),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Area (Chat & Input)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chat List
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      reverse:
                          true, // Show newest at bottom? List usually grows down.
                      // Let's keep normal order, stick to bottom.
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[_comments.length - 1 - index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            comment,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              shadows: [
                                Shadow(blurRadius: 2, color: Colors.black),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Comment...',
                            hintStyle: const TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.3),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                          ),
                          onSubmitted: (_) => _sendComment(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          // Mock Like Animation
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendComment,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ViewCountBadge extends StatelessWidget {
  const ViewCountBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.remove_red_eye, color: Colors.white, size: 10),
          SizedBox(width: 4),
          Text(
            '1.2k',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
