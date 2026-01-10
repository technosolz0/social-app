import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // appBar: SettingsAppBar(title: 'Settings'),
      body: ListView(
        children: [
          // Account Section
          _buildSectionHeader('Account'),
          SettingsCard(
            onTap: () => context.push('/edit-profile'),
            child: _buildListTileContent(
              icon: Icons.person,
              title: 'Edit Profile',
            ),
          ),
          SettingsCard(
            onTap: () => context.push('/privacy-settings'),
            child: _buildListTileContent(icon: Icons.lock, title: 'Privacy'),
          ),
          SettingsCard(
            onTap: () => _showSecurityDialog(context),
            child: _buildListTileContent(
              icon: Icons.security,
              title: 'Security',
            ),
          ),

          const SizedBox(height: 16),

          // Content & Activity Section
          _buildSectionHeader('Content & Activity'),
          SettingsCard(
            onTap: () => context.push('/notification-settings'),
            child: _buildListTileContent(
              icon: Icons.notifications,
              title: 'Notifications',
            ),
          ),
          SettingsCard(
            onTap: () => context.push('/activity'),
            child: _buildListTileContent(
              icon: Icons.history,
              title: 'Your Activity',
            ),
          ),
          SettingsCard(
            onTap: () => _showSavedPosts(context),
            child: _buildListTileContent(icon: Icons.bookmark, title: 'Saved'),
          ),

          const SizedBox(height: 16),

          // Support & About Section
          _buildSectionHeader('Support & About'),
          SettingsCard(
            onTap: () => context.push('/help'),
            child: _buildListTileContent(
              icon: Icons.help,
              title: 'Help Center',
            ),
          ),
          SettingsCard(
            onTap: () => _showAboutDialog(context),
            child: _buildListTileContent(icon: Icons.info, title: 'About'),
          ),
          SettingsCard(
            onTap: () => _showFeedbackDialog(context),
            child: _buildListTileContent(
              icon: Icons.feedback,
              title: 'Send Feedback',
            ),
          ),

          const SizedBox(height: 16),

          // Content & Display Section
          _buildSectionHeader('Content & Display'),
          SettingsCard(
            child: _buildSwitchTileContent(
              context,
              icon: Icons.play_circle_outline,
              title: 'Auto-scroll Reels',
              subtitle: 'Automatically play next reel when current one ends',
              value: ref.watch(settingsProvider).autoScrollReels,
              onChanged: (value) =>
                  ref.read(settingsProvider.notifier).setAutoScrollReels(value),
            ),
          ),
          SettingsCard(
            onTap: () => context.push('/live-streaming'),
            child: _buildListTileContent(
              icon: Icons.live_tv,
              title: 'Live Streaming',
              subtitle: 'Go live and stream to your followers',
            ),
          ),

          const SizedBox(height: 16),

          // Preferences Section
          _buildSectionHeader('Preferences'),
          SettingsCard(
            onTap: () => _showThemeDialog(context, ref),
            child: _buildThemeModeTileContent(context, ref),
          ),
          SettingsCard(
            onTap: () => _showLanguageDialog(context),
            child: _buildListTileContent(
              icon: Icons.language,
              title: 'Language',
              subtitle: ref.watch(settingsProvider).language == 'en'
                  ? 'English'
                  : 'Other',
            ),
          ),

          const SizedBox(height: 16),

          // Account Actions Section
          _buildSectionHeader('Account'),
          SettingsCard(
            onTap: () => _showLogoutDialog(context, ref),
            child: _buildListTileContent(
              icon: Icons.logout,
              title: 'Logout',
              textColor: Colors.red,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildListTileContent({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: textColor ?? Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: Colors.grey[400]),
      ],
    );
  }

  Widget _buildSwitchTileContent(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildThemeModeTileContent(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeNotifierProvider);
    final brightness = MediaQuery.of(context).platformBrightness;

    String getModeText() {
      switch (currentMode) {
        case AppThemeMode.light:
          return 'Light';
        case AppThemeMode.dark:
          return 'Dark';
        case AppThemeMode.system:
          return brightness == Brightness.dark
              ? 'System (Dark)'
              : 'System (Light)';
      }
    }

    return Row(
      children: [
        Icon(Icons.dark_mode, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Theme',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                getModeText(),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: Colors.grey[400]),
      ],
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
      title: Text(title, style: TextStyle(color: textColor)),
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

  Widget _buildThemeModeTile(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeNotifierProvider);
    final brightness = MediaQuery.of(context).platformBrightness;

    String getModeText() {
      switch (currentMode) {
        case AppThemeMode.light:
          return 'Light';
        case AppThemeMode.dark:
          return 'Dark';
        case AppThemeMode.system:
          return brightness == Brightness.dark
              ? 'System (Dark)'
              : 'System (Light)';
      }
    }

    return ListTile(
      leading: const Icon(Icons.dark_mode),
      title: const Text('Theme'),
      subtitle: Text(getModeText()),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeDialog(context, ref),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentMode = ref.read(themeNotifierProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<AppThemeMode>(
              title: const Text('Light'),
              value: AppThemeMode.light,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeNotifierProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<AppThemeMode>(
              title: const Text('Dark'),
              value: AppThemeMode.dark,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeNotifierProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<AppThemeMode>(
              title: const Text('System'),
              subtitle: const Text('Follow system setting'),
              value: AppThemeMode.system,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeNotifierProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
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

  void _showSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Settings'),
        content: const Text('Security settings will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
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
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
