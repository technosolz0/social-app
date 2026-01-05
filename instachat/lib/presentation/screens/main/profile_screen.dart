import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:instachat/data/models/user_model.dart';
import '../../../core/constants/theme_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTabIndex = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authNotifierProvider);

        if (authState.user == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = authState.user!;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(context, user),

                // Stats
                _buildStats(context, user),

                // Action Buttons
                _buildActionButtons(context),

                // Posts Grid
                _buildPostsGrid(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        children: [
          // Avatar
          Stack(
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
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          // Name and Username
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

          if (user.website != null && user.website!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.paddingSmall),
            GestureDetector(
              onTap: () {
                // In a real app we would use url_launcher
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening ${user.website}...')),
                );
              },
              child: Text(
                user.website!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(context, 'Posts', user.postsCount.toString(), null),
          _buildStatItem(context, 'Followers', user.followersCount.toString(), () {
            context.push('/profile/${user.id}/followers');
          }),
          _buildStatItem(context, 'Following', user.followingCount.toString(), () {
            context.push('/profile/${user.id}/following');
          }),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: onTap != null ? Colors.blue : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: onTap != null ? Colors.blue : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => context.push('/edit-profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.borderRadiusMedium,
                  ),
                ),
              ),
              child: const Text('Edit Profile'),
            ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
            ),
            child: IconButton(
              onPressed: () => _showMoreOptions(context),
              icon: const Icon(Icons.more_horiz),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              context.push('/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Your Activity'),
            onTap: () {
              Navigator.pop(context);
              context.push('/activity');
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('QR Code'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              // Call logout
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPostsGrid() {
    // Mock posts data
    final posts = List.generate(12, (index) => 'Post ${index + 1}');

    return Column(
      children: [
        // Tab Bar
        Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.grid_on),
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.video_collection_outlined),
                  color: Colors.grey,
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_border),
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        // Posts Grid
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
                'https://picsum.photos/200/200?random=$index',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
