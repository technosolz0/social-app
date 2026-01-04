import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/theme_constants.dart';

class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Mock reels data
  final List<Map<String, dynamic>> _reels = List.generate(
    10,
    (index) => {
      'id': index,
      'videoUrl': 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      'user': {
        'username': 'user_$index',
        'avatar': null,
        'isVerified': index % 3 == 0,
      },
      'caption': 'This is reel number ${index + 1}. Amazing content! #reels #flutter',
      'likes': (index + 1) * 1000,
      'comments': (index + 1) * 50,
      'shares': (index + 1) * 20,
      'isLiked': false,
      'music': 'Original Audio - Artist ${index + 1}',
    },
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Reels',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Open camera for creating reel
            },
            icon: const Icon(
              Icons.camera_alt,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _reels.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          return _buildReelItem(_reels[index]);
        },
      ),
    );
  }

  Widget _buildReelItem(Map<String, dynamic> reel) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Background
        Container(
          color: Colors.black,
          child: const Center(
            child: Icon(
              Icons.play_circle_outline,
              size: 80,
              color: Colors.white,
            ),
          ),
        ),

        // Video Overlay (mock)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
              ],
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
                    backgroundImage: reel['user']['avatar'] != null
                        ? NetworkImage(reel['user']['avatar'])
                        : null,
                    child: reel['user']['avatar'] == null
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Text(
                    reel['user']['username'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (reel['user']['isVerified']) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified,
                      color: Colors.blue,
                      size: 16,
                    ),
                  ],
                  const SizedBox(width: AppSizes.paddingMedium),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Follow user
                    },
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
              Text(
                reel['caption'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSizes.paddingSmall),

              // Music Info
              Row(
                children: [
                  const Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    reel['music'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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
                icon: reel['isLiked'] ? Icons.favorite : Icons.favorite_border,
                label: _formatCount(reel['likes']),
                onTap: () {
                  setState(() {
                    reel['isLiked'] = !reel['isLiked'];
                    reel['likes'] = reel['isLiked']
                        ? reel['likes'] + 1
                        : reel['likes'] - 1;
                  });
                },
                color: reel['isLiked'] ? Colors.red : Colors.white,
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              _buildActionButton(
                icon: Icons.comment,
                label: _formatCount(reel['comments']),
                onTap: () {
                  // TODO: Show comments
                },
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              _buildActionButton(
                icon: Icons.send,
                label: _formatCount(reel['shares']),
                onTap: () {
                  // TODO: Share reel
                },
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              _buildActionButton(
                icon: Icons.more_vert,
                label: '',
                onTap: () {
                  _showReelOptions(reel);
                },
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
            value: (_currentPage + 1) / _reels.length,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
          icon: Icon(
            icon,
            color: color,
            size: 28,
          ),
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

  void _showReelOptions(Map<String, dynamic> reel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Report reel
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copy Link'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Copy reel link
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Save Video'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Download reel
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Share reel
              },
            ),
          ],
        ),
      ),
    );
  }
}
