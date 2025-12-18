import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

// ============================================
// lib/presentation/widgets/post/post_media.dart
// 🎨 REUSABLE MEDIA WIDGET (Image/Video)
// ============================================

class PostMedia extends StatefulWidget {
  final String mediaUrl;
  final String postType;
  final VoidCallback onView;

  const PostMedia({
    super.key,
    required this.mediaUrl,
    required this.postType,
    required this.onView,
  });

  @override
  State<PostMedia> createState() => _PostMediaState();
}

class _PostMediaState extends State<PostMedia> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    widget.onView(); // Track view

    if (widget.postType == 'video' || widget.postType == 'reel') {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.network(widget.mediaUrl);
    await _videoController!.initialize();
    setState(() => _isVideoInitialized = true);
    _videoController!.setLooping(true);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.postType == 'photo') {
      return CachedNetworkImage(
        imageUrl: widget.mediaUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (context, url) => Container(
          height: 400,
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          height: 400,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      );
    } else {
      // Video
      if (!_isVideoInitialized) {
        return Container(
          height: 400,
          color: Colors.black,
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      return GestureDetector(
        onTap: () {
          setState(() {
            if (_videoController!.value.isPlaying) {
              _videoController!.pause();
            } else {
              _videoController!.play();
            }
          });
        },
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_videoController!),
              if (!_videoController!.value.isPlaying)
                const Icon(
                  Icons.play_circle_outline,
                  size: 64,
                  color: Colors.white,
                ),
            ],
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }
}
