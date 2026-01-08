import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../data/services/storage_service.dart';
import '../../providers/post_provider.dart';
import '../../providers/activity_tracker_provider.dart';

class ReelEditorScreen extends ConsumerStatefulWidget {
  final File videoFile;

  const ReelEditorScreen({super.key, required this.videoFile});

  @override
  ConsumerState<ReelEditorScreen> createState() => _ReelEditorScreenState();
}

class _ReelEditorScreenState extends ConsumerState<ReelEditorScreen> {
  late VideoPlayerController _videoController;
  final TextEditingController _captionController = TextEditingController();
  bool _initialized = false;
  bool _isUploading = false;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _videoController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.file(widget.videoFile);
    try {
      await _videoController.initialize();
      await _videoController.setLooping(true);
      await _videoController.play();
      setState(() => _initialized = true);
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  void _togglePlay() {
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

  Future<void> _shareReel() async {
    if (_isUploading) return;

    if (_captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a caption')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final storageService = ref.read(storageServiceProvider);
      final mediaUrl = await storageService.uploadVideo(widget.videoFile);
      
      if (mediaUrl == null) {
        throw Exception('Failed to upload video');
      }

      final postNotifier = ref.read(postFeedNotifierProvider.notifier);
      final newPost = await postNotifier.createPost(
        postType: 'reel',
        mediaUrl: mediaUrl,
        caption: _captionController.text.trim(),
        hashtags: [], // TODO: Parse hashtags
      );

      if (newPost != null) {
        ref.read(activityTrackerProvider.notifier).trackPostView(newPost.id); // Track creation as activity?
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reel shared successfully!')),
          );
          // Navigate to home or reels tab
          context.go('/home'); // Or /reels if that route exists
        }
      } else {
        throw Exception('Failed to create post');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing reel: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('New Reel', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Show caption sheet
              _showCaptionSheet();
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: Center(
              child: AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: VideoPlayer(_videoController),
              ),
            ),
          ),
          if (!_isPlaying)
            const Center(
              child: Icon(Icons.play_circle_outline, size: 80, color: Colors.white54),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCaptionSheet,
        label: const Text('Next'),
        icon: const Icon(Icons.arrow_forward),
      ),
    );
  }

  void _showCaptionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add Caption',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                hintText: 'Write a caption...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isUploading ? null : _shareReel,
              child: _isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Share Reel'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
