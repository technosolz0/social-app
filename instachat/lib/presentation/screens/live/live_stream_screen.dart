import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme_constants.dart';

class LiveStreamScreen extends ConsumerStatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  ConsumerState<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends ConsumerState<LiveStreamScreen> {
  CameraController? _cameraController;
  bool _isLive = false;
  final TextEditingController _commentController = TextEditingController();
  final List<String> _comments = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // Use front camera by default for streaming
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _toggleLive() {
    setState(() {
      _isLive = !_isLive;
      if (_isLive) {
        _comments.add('System: You are now LIVE!');
      } else {
        _comments.add('System: Stream ended.');
      }
    });
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
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Center(child: CameraPreview(_cameraController!)),

          // Top Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isLive ? Colors.red : Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _isLive ? 'LIVE' : 'READY',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls & Chat
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Comments area (simplified)
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            _comments[index],
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (!_isLive)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: _toggleLive,
                      child: const Text('GO LIVE', style: TextStyle(fontSize: 18)),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Say something...',
                              hintStyle: const TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _sendComment,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.stop_circle, color: Colors.red, size: 32),
                          onPressed: _toggleLive,
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
