import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/conversations_provider.dart';

class UserProfileScreen extends ConsumerWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider(userId));
    final currentUserId = ref.read(authNotifierProvider).user?.id;

    if (currentUserId == userId) {
      // If it's the current user, we should probably redirect or show ProfileScreen
      // For now just show the profile
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
              // Show more options for this user (report, block, etc.)
            },
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) => SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(user),

              // Stats
              _buildStats(user),

              // Action Buttons
              _buildActionButtons(context, ref, user),

              // Posts Grid
              _buildPostsGrid(),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage: user.avatar != null
                ? NetworkImage(user.avatar!)
                : null,
            child: user.avatar == null
                ? const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey,
                  )
                : null,
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          // Name and Username
          Text(
            user.username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
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
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, dynamic user) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Toggle follow
                // This logic would be in userProvider
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
                ),
              ),
              child: const Text('Follow'),
            ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: OutlinedButton(
              onPressed: () async {
                // Start chat
                final convId = await ref.read(conversationsProvider.notifier).createConversation(user.id);
                if (convId != null && context.mounted) {
                  context.push('/chat/$convId');
                }
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
                ),
              ),
              child: const Text('Message'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsGrid() {
    // Mock posts data
    final posts = List.generate(9, (index) => 'Post ${index + 1}');

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
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return Container(
              color: Colors.grey[300],
              child: Image.network(
                'https://picsum.photos/200/200?random=${index + 100}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image, color: Colors.grey);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
