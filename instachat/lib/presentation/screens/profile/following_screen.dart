import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for following (mock data for now)
final followingProvider = StateProvider<List<Map<String, dynamic>>>((ref) {
  return List.generate(
    12,
    (index) => {
      'id': 'following_$index',
      'username': 'following_$index',
      'avatar': 'https://picsum.photos/100/100?random=${index + 50}',
      'isVerified': index % 4 == 0, // Some are verified
    },
  );
});

class FollowingScreen extends ConsumerWidget {
  final String userId;

  const FollowingScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final following = ref.watch(followingProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Following'),
      ),
      body: ListView.builder(
        itemCount: following.length,
        itemBuilder: (context, index) {
          final user = following[index];
          return _buildFollowingItem(context, user, ref);
        },
      ),
    );
  }

  Widget _buildFollowingItem(
    BuildContext context,
    Map<String, dynamic> user,
    WidgetRef ref,
  ) {
    return FollowingItem(
      user: user,
      onUnfollow: () {
        // Unfollow logic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unfollowed ${user['username']}')),
        );
      },
      onTap: () {
        // Navigate to user profile
        // context.push('/profile/${user['id']}');
      },
    );
  }
}

// ============================================
// FOLLOWING ITEM WIDGET WITH ANIMATIONS
// ============================================

class FollowingItem extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onUnfollow;
  final VoidCallback onTap;

  const FollowingItem({
    super.key,
    required this.user,
    required this.onUnfollow,
    required this.onTap,
  });

  @override
  State<FollowingItem> createState() => _FollowingItemState();
}

class _FollowingItemState extends State<FollowingItem>
    with TickerProviderStateMixin {
  late AnimationController _unfollowAnimationController;
  late AnimationController _pointsAnimationController;
  bool _showBreakAnimation = false;
  bool _showPointsAnimation = false;

  @override
  void initState() {
    super.initState();
    _unfollowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pointsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _unfollowAnimationController.dispose();
    _pointsAnimationController.dispose();
    super.dispose();
  }

  void _handleUnfollow() {
    widget.onUnfollow();

    // Show break animation (broken heart)
    setState(() => _showBreakAnimation = true);
    _unfollowAnimationController.forward(from: 0).then((_) {
      setState(() => _showBreakAnimation = false);
    });

    // Show points animation (negative points for unfollowing)
    setState(() => _showPointsAnimation = true);
    _pointsAnimationController.forward(from: 0).then((_) {
      setState(() => _showPointsAnimation = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(widget.user['avatar']),
            radius: 24,
          ),
          title: Row(
            children: [
              Text(
                widget.user['username'],
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (widget.user['isVerified'])
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.verified, color: Colors.blue, size: 16),
                ),
            ],
          ),
          trailing: ElevatedButton(
            onPressed: _handleUnfollow,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
            ),
            child: const Text('Following'),
          ),
          onTap: widget.onTap,
        ),

        // Broken heart animation overlay
        if (_showBreakAnimation)
          Positioned(
            right: 80,
            top: 10,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.2).animate(
                CurvedAnimation(
                  parent: _unfollowAnimationController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                child: const Icon(
                  Icons.heart_broken,
                  color: Colors.grey,
                  size: 24,
                ),
              ),
            ),
          ),

        // Points notification (negative for unfollowing)
        if (_showPointsAnimation)
          Positioned(
            right: 120,
            top: 10,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0),
                    end: const Offset(0, -1.5),
                  ).animate(
                    CurvedAnimation(
                      parent: _pointsAnimationController,
                      curve: Curves.easeOut,
                    ),
                  ),
              child: FadeTransition(
                opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                  CurvedAnimation(
                    parent: _pointsAnimationController,
                    curve: const Interval(0.5, 1.0),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF757575), Color(0xFF9E9E9E)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.remove, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '-1 Point',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
