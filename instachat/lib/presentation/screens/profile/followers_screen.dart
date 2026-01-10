import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/theme_constants.dart';

// Provider for followers (mock data for now)
final followersProvider = StateProvider<List<Map<String, dynamic>>>((ref) {
  return List.generate(
    15,
    (index) => {
      'id': 'follower_$index',
      'username': 'follower_$index',
      'avatar': 'https://picsum.photos/100/100?random=$index',
      'isFollowing': index % 3 == 0, // Some are following back
    },
  );
});

class FollowersScreen extends ConsumerWidget {
  final String userId;

  const FollowersScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followers = ref.watch(followersProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Followers'),
      ),
      body: ListView.builder(
        itemCount: followers.length,
        itemBuilder: (context, index) {
          final follower = followers[index];
          return _buildFollowerItem(context, follower, ref);
        },
      ),
    );
  }

  Widget _buildFollowerItem(
    BuildContext context,
    Map<String, dynamic> follower,
    WidgetRef ref,
  ) {
    return FollowerItem(
      follower: follower,
      onFollow: () {
        // Follow back logic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Followed ${follower['username']}!')),
        );
      },
      onRemove: () {
        // Remove follower logic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed ${follower['username']} from followers'),
          ),
        );
      },
      onTap: () {
        // Navigate to user profile
        // context.push('/profile/${follower['id']}');
      },
    );
  }
}

// ============================================
// FOLLOWER ITEM WIDGET WITH ANIMATIONS
// ============================================

class FollowerItem extends StatefulWidget {
  final Map<String, dynamic> follower;
  final VoidCallback onFollow;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const FollowerItem({
    super.key,
    required this.follower,
    required this.onFollow,
    required this.onRemove,
    required this.onTap,
  });

  @override
  State<FollowerItem> createState() => _FollowerItemState();
}

class _FollowerItemState extends State<FollowerItem>
    with TickerProviderStateMixin {
  late AnimationController _followAnimationController;
  late AnimationController _pointsAnimationController;
  bool _showHeartAnimation = false;
  bool _showPointsAnimation = false;

  @override
  void initState() {
    super.initState();
    _followAnimationController = AnimationController(
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
    _followAnimationController.dispose();
    _pointsAnimationController.dispose();
    super.dispose();
  }

  void _handleFollow() {
    widget.onFollow();

    // Show heart animation
    setState(() => _showHeartAnimation = true);
    _followAnimationController.forward(from: 0).then((_) {
      setState(() => _showHeartAnimation = false);
    });

    // Show points animation
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
            backgroundImage: NetworkImage(widget.follower['avatar']),
            radius: 24,
          ),
          title: Text(
            widget.follower['username'],
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: widget.follower['isFollowing']
              ? const Text('Follows you', style: TextStyle(color: Colors.blue))
              : null,
          trailing: widget.follower['isFollowing']
              ? OutlinedButton(
                  onPressed: _handleFollow,
                  child: const Text('Follow'),
                )
              : ElevatedButton(
                  onPressed: widget.onRemove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Remove'),
                ),
          onTap: widget.onTap,
        ),

        // Heart animation overlay
        if (_showHeartAnimation)
          Positioned(
            right: 80,
            top: 10,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.2).animate(
                CurvedAnimation(
                  parent: _followAnimationController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                child: const Icon(Icons.favorite, color: Colors.red, size: 24),
              ),
            ),
          ),

        // Points notification
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
                      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '+2 Points',
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
