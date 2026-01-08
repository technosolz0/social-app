import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account Section
          _buildSectionHeader('Account'),
          _buildListTile(
            context,
            icon: Icons.person,
            title: 'Edit Profile',
            onTap: () => context.push('/edit-profile'),
          ),
          _buildListTile(
            context,
            icon: Icons.lock,
            title: 'Privacy',
            onTap: () => context.push('/privacy-settings'),
          ),
          _buildListTile(
            context,
            icon: Icons.security,
            title: 'Security',
            onTap: () => context.push('/security-settings'),
          ),

          const Divider(),

          // Content & Activity Section
          _buildSectionHeader('Content & Activity'),
          _buildListTile(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () => context.push('/notification-settings'),
          ),
          _buildListTile(
            context,
            icon: Icons.history,
            title: 'Your Activity',
            onTap: () => context.push('/activity'),
          ),
          _buildListTile(
            context,
            icon: Icons.bookmark,
            title: 'Saved',
            onTap: () => _showSavedPosts(context),
          ),

          const Divider(),

          // Support & About Section
          _buildSectionHeader('Support & About'),
          _buildListTile(
            context,
            icon: Icons.help,
            title: 'Help Center',
            onTap: () => context.push('/help'),
          ),
          _buildListTile(
            context,
            icon: Icons.info,
            title: 'About',
            onTap: () => _showAboutDialog(context),
          ),
          _buildListTile(
            context,
            icon: Icons.feedback,
            title: 'Send Feedback',
            onTap: () => _showFeedbackDialog(context),
          ),

          const Divider(),

          // Content & Display Section
          _buildSectionHeader('Content & Display'),
          _buildSwitchTile(
            context,
            icon: Icons.play_circle_outline,
            title: 'Auto-scroll Reels',
            subtitle: 'Automatically play next reel when current one ends',
            value: ref.watch(settingsProvider).autoScrollReels,
            onChanged: (value) => ref.read(settingsProvider.notifier).setAutoScrollReels(value),
          ),
          _buildListTile(
            context,
            icon: Icons.live_tv,
            title: 'Live Streaming',
            subtitle: 'Go live and stream to your followers',
            onTap: () => context.push('/live-streaming'),
          ),

          const Divider(),

          // Preferences Section
          _buildSectionHeader('Preferences'),
          _buildSwitchTile(
            context,
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            value: ref.watch(settingsProvider).isDarkMode,
            onChanged: (value) => ref.read(settingsProvider.notifier).setDarkMode(value),
          ),
          _buildListTile(
            context,
            icon: Icons.language,
            title: 'Language',
            subtitle: ref.watch(settingsProvider).language == 'en' ? 'English' : 'Other',
            onTap: () => _showLanguageDialog(context),
          ),
          _buildListTile(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () => context.push('/notification-settings'),
          ),
          _buildListTile(
            context,
            icon: Icons.privacy_tip,
            title: 'Privacy & Safety',
            onTap: () => context.push('/privacy-settings'),
          ),

          const Divider(),

          // Account Actions Section
          _buildSectionHeader('Account'),
          _buildListTile(
            context,
            icon: Icons.logout,
            title: 'Logout',
            textColor: Colors.red,
            onTap: () => _showLogoutDialog(context, ref),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: onChanged,
    );
  }

  void _showSavedPosts(BuildContext context) {
    // Navigate to saved posts screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved posts feature coming soon!')),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Social App'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('A modern social media platform'),
            SizedBox(height: 8),
            Text('Built with Flutter & Django'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: const TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Tell us what you think...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: const Icon(Icons.check, color: Colors.blue),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Spanish'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('French'),
              onTap: () => Navigator.pop(context),
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
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
