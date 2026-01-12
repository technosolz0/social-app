import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/conversations_provider.dart';
import '../../widgets/gamification/points_notification_widget.dart';
import '../../widgets/common/report_bottom_sheet.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  int? _gainedPoints;

  void _showPoints(int points) {
    if (mounted) {
      setState(() {
        _gainedPoints = points;
      });
    }
  }

  void _hidePoints() {
    if (mounted) {
      setState(() {
        _gainedPoints = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider(widget.userId));
    final currentUserId = ref.read(authNotifierProvider).user?.id;

    if (currentUserId == widget.userId) {
      // Logic to redirect or show own profile could go here
    }

    return Scaffold(
      appBar: AppBar(
        title: userAsync.when(
          data: (user) => Text(
            user.username,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Profile'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              ReportBottomSheet.show(context, 'user', widget.userId);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          userAsync.when(
            data: (user) => SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(user),
                  _buildStats(user),
                  _buildActionButtons(context, ref, user),
                  _buildPostsGrid(user),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          ),

          if (_gainedPoints != null)
            PointsNotificationWidget(
              points: _gainedPoints!,
              onFinished: _hidePoints,
            ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage: user.avatar != null
                ? NetworkImage(user.avatar!)
                : null,
            child: user.avatar == null
                ? const Icon(Icons.person, size: 50, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Text(
            user.username,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStats(dynamic user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Posts', user.postsCount.toString()),
          _buildStatItem('Followers', user.followersCount.toString()),
          _buildStatItem('Following', user.followingCount.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
  ) {
    final isFollowing = user.isFollowing ?? false;
    final isLoading = ref.watch(userProvider(widget.userId)).isLoading;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (isFollowing) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Unfollow ${user.username}?'),
                            content: const Text(
                              'Are you sure you want to unfollow this user?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Unfollow'),
                              ),
                            ],
                          ),
                        );
                        if (confirm != true) return;
                      }

                      await ref
                          .read(userProvider(widget.userId).notifier)
                          .toggleFollow();
                      if (!isFollowing) {
                        _showPoints(10); // Award 10 points for following
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? Colors.grey[300] : Colors.blue,
                foregroundColor: isFollowing ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.borderRadiusMedium,
                  ),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isFollowing ? 'Following' : 'Follow'),
            ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: OutlinedButton(
              onPressed: () async {
                final convId = await ref
                    .read(conversationsProvider.notifier)
                    .createConversation(user.id);
                if (convId != null && context.mounted) {
                  context.push('/chat/$convId');
                }
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.borderRadiusMedium,
                  ),
                ),
              ),
              child: const Text('Message'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsGrid(dynamic user) {
    return Column(
      children: [
        const Divider(),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.image, color: Colors.grey),
            );
          },
        ),
      ],
    );
  }
}
