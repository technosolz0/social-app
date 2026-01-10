import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../../core/constants/theme_constants.dart';
import '../../providers/auth_provider.dart';

// Live Streaming Screen
class LiveStreamingScreen extends ConsumerStatefulWidget {
  const LiveStreamingScreen({super.key});

  @override
  ConsumerState<LiveStreamingScreen> createState() =>
      _LiveStreamingScreenState();
}

class _LiveStreamingScreenState extends ConsumerState<LiveStreamingScreen> {
  CameraController? _cameraController;
  bool _isStreaming = false;
  bool _isInitialized = false;
  int _viewerCount = 0;
  int _likeCount = 0;
  int _commentCount = 0;
  final TextEditingController _commentController = TextEditingController();
  final List<String> _comments = [];
  Timer? _viewerTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _startViewerSimulation();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _commentController.dispose();
    _viewerTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: true,
        );

        await _cameraController!.initialize();
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _startViewerSimulation() {
    _viewerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _isStreaming) {
        setState(() {
          _viewerCount +=
              (DateTime.now().second % 5) - 2; // Random increase/decrease
          _viewerCount = _viewerCount.clamp(0, 10000); // Keep between 0-10k
        });
      }
    });
  }

  void _toggleStreaming() {
    setState(() {
      _isStreaming = !_isStreaming;
    });

    if (_isStreaming) {
      // Start streaming logic would go here
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('🎥 Live stream started!')));
    } else {
      // Stop streaming logic would go here
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('⏹️ Live stream ended')));
    }
  }

  void _sendComment() {
    if (_commentController.text.trim().isNotEmpty) {
      setState(() {
        _comments.add(_commentController.text.trim());
        _commentCount++;
      });
      _commentController.clear();
    }
  }

  void _likeStream() {
    setState(() {
      _likeCount++;
    });
    // Show heart animation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❤️'),
        duration: Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          if (_isInitialized && _cameraController != null)
            Transform.scale(
              scale:
                  _cameraController!.value.aspectRatio /
                  MediaQuery.of(context).size.aspectRatio,
              child: Center(child: CameraPreview(_cameraController!)),
            )
          else
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // Live Stream Overlay
          if (_isStreaming) ...[
            // Top Bar - Stream Info
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.visibility,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _viewerCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Bar - Comments and Actions
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Comments List
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        reverse: true,
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment =
                              _comments[_comments.length - 1 - index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Text(
                                  '${user?.username ?? 'You'}: ',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    comment,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Comment Input
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: _commentController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Say something...',
                                hintStyle: TextStyle(color: Colors.white70),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _sendComment(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _sendComment,
                          icon: const Icon(Icons.send, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Right Side Actions
            Positioned(
              right: 16,
              bottom: 200,
              child: Column(
                children: [
                  _buildActionButton(
                    icon: Icons.favorite_border,
                    label: _likeCount.toString(),
                    onTap: _likeStream,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    icon: Icons.comment,
                    label: _commentCount.toString(),
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    icon: Icons.share,
                    label: 'Share',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    icon: Icons.more_vert,
                    label: '',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ] else ...[
            // Pre-stream UI
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: IconButton(
                      onPressed: _toggleStreaming,
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Go Live',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Share your moment with followers',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.flip_camera_ios,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.flash_off,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Top Bar - Cancel Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.5),
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: color, size: 24),
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
