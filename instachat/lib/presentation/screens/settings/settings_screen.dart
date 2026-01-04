import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme_constants.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Account Section
          _buildSectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/edit-profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/account-settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(authState.user?.email ?? 'Not set'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/account-settings');
            },
          ),

          const Divider(),

          // Privacy & Security
          _buildSectionHeader('Privacy & Security'),
          ListTile(
            leading: const Icon(Icons.visibility_off),
            title: const Text('Private Account'),
            trailing: Switch(
              value: false, // This would come from user settings
              onChanged: (value) {
                // Update privacy setting
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Blocked Users'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/privacy-settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Privacy Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/privacy-settings');
            },
          ),

          const Divider(),

          // Notifications
          _buildSectionHeader('Notifications'),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Push Notifications'),
            trailing: Switch(
              value: true, // This would come from user settings
              onChanged: (value) {
                // Update notification setting
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email Notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/notification-settings');
            },
          ),

          const Divider(),

          // Content & Media
          _buildSectionHeader('Content & Media'),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: const Text('Save to Gallery'),
            trailing: Switch(
              value: true, // This would come from user settings
              onChanged: (value) {
                // Update save setting
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.wifi),
            title: const Text('Data Usage'),
            subtitle: const Text('Wi-Fi and mobile data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to data usage settings
            },
          ),

          const Divider(),

          // Features & Apps
          _buildSectionHeader('Features & Apps'),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Messages'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/chats'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Activity'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/activity'),
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text('Gamification'),
            subtitle: const Text('Badges, points, and quests'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Show gamification submenu
              _showGamificationMenu(context);
            },
          ),

          const Divider(),

          // Support & About
          _buildSectionHeader('Support & About'),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help Center'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/help');
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Send Feedback'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/help');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/help');
            },
          ),

          const Divider(),

          // Account Actions
          _buildSectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log Out', style: TextStyle(color: Colors.red)),
            onTap: () {
              _showLogoutDialog(context, ref);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingMedium,
        AppSizes.paddingLarge,
        AppSizes.paddingMedium,
        AppSizes.paddingSmall,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showGamificationMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Gamification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text('Badges'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to badges screen when implemented
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Badges screen coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard),
              title: const Text('Leaderboard'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to leaderboard screen when implemented
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Leaderboard screen coming soon!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.stars),
              title: const Text('Points'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to points screen when implemented
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Points screen coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Quests'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to quests screen when implemented
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quests screen coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
