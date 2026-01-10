import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../data/models/post_model.dart';
import '../../providers/reels_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/post/comment_bottom_sheet.dart';

class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _disposeAllControllers();
    super.dispose();
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
      _updateVideoPlayback();
    }
  }

  void _updateVideoPlayback() {
    // Pause all videos
    _videoControllers.forEach((_, controller) {
      controller.pause();
    });

    // Play current video
    final reelsAsync = ref.read(reelsProvider);
    reelsAsync.whenData((reels) {
      if (_currentPage < reels.length) {
        final currentReel = reels[_currentPage];
        final controller = _videoControllers[currentReel.id];
        if (controller != null) {
          controller.play();
          controller.setLooping(true);
        }
      }
    });
  }

  Future<void> _initializeVideoController(PostModel reel) async {
    if (_videoControllers.containsKey(reel.id)) return;

    final controller = VideoPlayerController.network(reel.mediaUrl);
    _videoControllers[reel.id] = controller;

    try {
      await controller.initialize();

      // Add listener for video completion to enable auto-scroll
      controller.addListener(() {
        final settings = ref.read(settingsProvider);
        if (controller.value.position >= controller.value.duration &&
            settings.autoScrollReels &&
            mounted) {
          _autoScrollToNextReel();
        }
      });

      final reels = ref.read(reelsProvider).value ?? [];
      if (_currentPage == reels.indexOf(reel)) {
        controller.play();
        controller.setLooping(true);
      }
      setState(() {});
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  void _autoScrollToNextReel() {
    final reelsAsync = ref.read(reelsProvider);
    reelsAsync.whenData((reels) {
      if (_currentPage < reels.length - 1) {
        // Scroll to next reel
        _pageController.animateToPage(
          _currentPage + 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // Loop back to first reel
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _disposeAllControllers() {
    _videoControllers.forEach((_, controller) {
      controller.dispose();
    });
    _videoControllers.clear();
  }

  @override
  Widget build(BuildContext context) {
    final reelsAsync = ref.watch(reelsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Reels',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/camera'),
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            tooltip: 'Create Reel',
          ),
        ],
      ),
      body: reelsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'Failed to load reels',
                style: TextStyle(color: Colors.white),
              ),
              ElevatedButton(
                onPressed: () => ref.invalidate(reelsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (reels) {
          if (reels.isEmpty) {
            return const Center(
              child: Text(
                'No reels available',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: reels.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              _updateVideoPlayback();
            },
            itemBuilder: (context, index) {
              final reel = reels[index];
              _initializeVideoController(reel);
              return _buildReelItem(reel, reels.length);
            },
          );
        },
      ),
    );
  }

  Widget _buildReelItem(PostModel reel, int totalReels) {
    final controller = _videoControllers[reel.id];
    final isLiked = reel.isLiked;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player
        if (controller != null && controller.value.isInitialized)
          VideoPlayer(controller)
        else
          Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),

        // Video Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
            ),
          ),
        ),

        // Content Overlay
        Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    backgroundImage: reel.user.avatar != null
                        ? NetworkImage(reel.user.avatar!)
                        : null,
                    child: reel.user.avatar == null
                        ? Text(
                            reel.user.username.isNotEmpty == true
                                ? reel.user.username[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Text(
                    reel.user.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (reel.user.isVerified == true) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: Colors.blue, size: 16),
                  ],
                  const SizedBox(width: AppSizes.paddingMedium),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(reelsProvider.notifier)
                        .followUser(reel.user.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Follow'),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingMedium),

              // Caption
              if (reel.caption != null && reel.caption!.isNotEmpty)
                Text(
                  reel.caption!,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: AppSizes.paddingSmall),

              // Dynamic Audio/Music Info
              Row(
                children: [
                  Icon(
                    reel.postType == 'reel'
                        ? Icons.music_note
                        : reel.postType == 'video'
                        ? Icons.videocam
                        : Icons.photo,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _getAudioInfo(reel),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingLarge),
            ],
          ),
        ),

        // Action Buttons
        Positioned(
          right: AppSizes.paddingMedium,
          bottom: 100,
          child: Column(
            children: [
              _buildActionButton(
                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                label: _formatCount(reel.likesCount),
                onTap: () => ref.read(reelsProvider.notifier).likeReel(reel.id),
                color: isLiked ? Colors.red : Colors.white,
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              _buildActionButton(
                icon: Icons.comment,
                label: _formatCount(reel.commentsCount),
                onTap: () => CommentBottomSheet.show(context, reel),
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              _buildActionButton(
                icon: Icons.send,
                label: 'Share',
                onTap: () => _shareReel(reel),
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              _buildActionButton(
                icon: Icons.more_vert,
                label: '',
                onTap: () => _showReelOptions(reel),
              ),
            ],
          ),
        ),

        // Progress Indicator
        Positioned(
          top: MediaQuery.of(context).padding.top + kToolbarHeight + 10,
          left: AppSizes.paddingMedium,
          right: AppSizes.paddingMedium,
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / totalReels,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),

        // Play/Pause Overlay
        if (controller != null && !controller.value.isPlaying)
          Center(
            child: IconButton(
              onPressed: () {
                controller.play();
                setState(() {});
              },
              icon: const Icon(
                Icons.play_circle_outline,
                size: 80,
                color: Colors.white,
              ),
            ),
          ),
      ],
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
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: color, size: 28),
        ),
        if (label.isNotEmpty)
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  String _getAudioInfo(PostModel reel) {
    // Dynamic audio/music information based on post type and available data
    switch (reel.postType) {
      case 'reel':
        // For reels, show original audio or first hashtag as music
        if (reel.hashtags.isNotEmpty) {
          return '♪ ${reel.hashtags.first}';
        }
        return '♪ Original Audio';

      case 'video':
        // For videos, show video info
        return '🎬 ${reel.user.username} • Video';

      case 'photo':
        // For photos, show photo info
        return '📸 ${reel.user.username} • Photo';

      default:
        // Fallback based on available data
        if (reel.hashtags.isNotEmpty) {
          return '♪ ${reel.hashtags.first}';
        }
        return '♪ Original Audio';
    }
  }

  void _shareReel(PostModel reel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Share Reel',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.send),
              title: const Text('Send to Friends'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to share screen with friends list
                context.push('/share-friends', extra: reel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copy Link'),
              onTap: () async {
                Navigator.pop(context);
                // Copy reel link to clipboard
                final link = '${ApiConstants.baseUrl}/reel/${reel.id}';
                // In a real app, you'd use Clipboard.setData
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Link copied: $link')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Share via Message'),
              onTap: () {
                Navigator.pop(context);
                // Open message composer with reel
                context.push(
                  '/compose-message',
                  extra: {'type': 'reel', 'data': reel},
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('More Options'),
              onTap: () {
                Navigator.pop(context);
                // Open system share dialog
                // In a real app, you'd use Share.share()
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('System share dialog opened')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReelOptions(PostModel reel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(context, reel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copy Link'),
              onTap: () async {
                Navigator.pop(context);
                final link = '${ApiConstants.baseUrl}/reel/${reel.id}';
                // In a real app, you'd use Clipboard.setData
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Link copied: $link')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Save Video'),
              onTap: () {
                Navigator.pop(context);
                _saveVideo(reel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _shareReel(reel);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context, PostModel reel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Reel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Why are you reporting this reel?'),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text('Spam'),
              value: 'spam',
              groupValue: null,
              onChanged: (value) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted for spam')),
                );
              },
            ),
            RadioListTile<String>(
              title: const Text('Inappropriate content'),
              value: 'inappropriate',
              groupValue: null,
              onChanged: (value) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report submitted for inappropriate content'),
                  ),
                );
              },
            ),
            RadioListTile<String>(
              title: const Text('Harassment'),
              value: 'harassment',
              groupValue: null,
              onChanged: (value) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report submitted for harassment'),
                  ),
                );
              },
            ),
            RadioListTile<String>(
              title: const Text('Other'),
              value: 'other',
              groupValue: null,
              onChanged: (value) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _saveVideo(PostModel reel) {
    // In a real app, this would download and save the video
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Video download started')));
  }
}
