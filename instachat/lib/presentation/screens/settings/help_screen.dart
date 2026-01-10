import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/theme_constants.dart';
import '../../widgets/common/custom_app_bar.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: SettingsAppBar(title: 'Help & Support'),
      body: ListView(
        children: [
          // Getting Started Section
          _buildSectionHeader('Getting Started'),
          ListTile(
            leading: const Icon(Icons.play_circle_outline),
            title: const Text('How to use the app'),
            subtitle: const Text('Learn the basics of our social platform'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showTutorialDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.create),
            title: const Text('Creating your first post'),
            subtitle: const Text('Step-by-step guide to posting'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showPostTutorialDialog(context);
            },
          ),

          const Divider(),

          // Account & Profile Section
          _buildSectionHeader('Account & Profile'),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Managing your profile'),
            subtitle: const Text('Edit profile, privacy settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showProfileHelpDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Account security'),
            subtitle: const Text('Password, 2FA, login issues'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showSecurityHelpDialog(context);
            },
          ),

          const Divider(),

          // Features Section
          _buildSectionHeader('Features'),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Messaging'),
            subtitle: const Text('How to send and receive messages'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showMessagingHelpDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Likes & Comments'),
            subtitle: const Text('Interacting with posts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showInteractionHelpDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text('Gamification'),
            subtitle: const Text('Badges, points, and rewards'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showGamificationHelpDialog(context);
            },
          ),

          const Divider(),

          // Troubleshooting Section
          _buildSectionHeader('Troubleshooting'),
          ListTile(
            leading: const Icon(Icons.wifi_off),
            title: const Text('Connection issues'),
            subtitle: const Text('Problems with internet or app loading'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showConnectionHelpDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Report a bug'),
            subtitle: const Text('Found something not working?'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showBugReportDialog(context);
            },
          ),

          const Divider(),

          // Contact & Support Section
          _buildSectionHeader('Contact & Support'),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Contact Support'),
            subtitle: const Text('Get help from our support team'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _launchEmailSupport(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.forum),
            title: const Text('Community Forum'),
            subtitle: const Text('Ask questions and get help from users'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _launchCommunityForum(context);
            },
          ),

          const Divider(),

          // Legal & Policies Section
          _buildSectionHeader('Legal & Policies'),
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _launchPrivacyPolicy(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _launchTermsOfService(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shield),
            title: const Text('Community Guidelines'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _launchCommunityGuidelines(context);
            },
          ),

          const Divider(),

          // App Information Section
          _buildSectionHeader('App Information'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.system_update),
            title: const Text('Check for Updates'),
            subtitle: const Text('See if there\'s a new version available'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _checkForUpdates(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSizes.paddingMedium, AppSizes.paddingLarge, AppSizes.paddingMedium, AppSizes.paddingSmall),
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

  void _showTutorialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Getting Started'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome to our social platform! Here\'s how to get started:\n\n'
                '1. Complete your profile in Settings\n'
                '2. Find friends by searching usernames\n'
                '3. Create your first post using the + button\n'
                '4. Like and comment on posts you enjoy\n'
                '5. Send messages to connect with others\n\n'
                'Explore all features from the bottom navigation bar!',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showPostTutorialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Creating Posts'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How to create and share posts:\n\n'
                '1. Tap the + button in the bottom navigation\n'
                '2. Choose photo/video from camera or gallery\n'
                '3. Add a caption to tell your story\n'
                '4. Add hashtags to reach more people\n'
                '5. Tap Share to post to your feed!\n\n'
                'Your posts will appear in your followers\' feeds.',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showProfileHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Managing Your Profile'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Customize your profile:\n\n'
                '• Edit Profile: Change photo, bio, website\n'
                '• Privacy Settings: Control who sees your content\n'
                '• Account Settings: Manage security and data\n'
                '• Notification Settings: Control what you\'re notified about\n\n'
                'Your profile is how others see you on the platform.',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showSecurityHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Security'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Keep your account secure:\n\n'
                '• Use a strong, unique password\n'
                '• Enable two-factor authentication\n'
                '• Review login activity regularly\n'
                '• Don\'t share your password\n'
                '• Log out of shared devices\n\n'
                'Contact support if you suspect unauthorized access.',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showMessagingHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Messaging'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Connect with others:\n\n'
                '• Tap the message icon to start chatting\n'
                '• Search for users by username\n'
                '• Send text, photos, and more\n'
                '• Your messages are private and secure\n'
                '• Respect others\' boundaries\n\n'
                'Happy chatting!',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showInteractionHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Likes & Comments'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Engage with content:\n\n'
                '• Double-tap posts to like them\n'
                '• Tap the heart icon to like/unlike\n'
                '• Tap the comment icon to leave a comment\n'
                '• Reply to comments in threads\n'
                '• Be kind and constructive in comments\n\n'
                'Your interactions help build community!',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showGamificationHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gamification'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Earn rewards while using the app:\n\n'
                '• Complete daily quests for points\n'
                '• Unlock badges for achievements\n'
                '• Climb the leaderboard\n'
                '• Get special rewards and recognition\n'
                '• Participate in community challenges\n\n'
                'Have fun and stay engaged!',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showConnectionHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection Issues'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Having trouble connecting?\n\n'
                '• Check your internet connection\n'
                '• Try restarting the app\n'
                '• Clear app cache if needed\n'
                '• Make sure you have the latest version\n'
                '• Contact support if problems persist\n\n'
                'We\'re here to help!',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Found a bug? Help us fix it!\n\n'
                'Please include:\n'
                '• What you were doing when it happened\n'
                '• What you expected to happen\n'
                '• What actually happened\n'
                '• Your device and app version\n\n'
                'Your reports help make the app better for everyone.',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchEmailSupport(context);
            },
            child: const Text('Report Bug'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Social App',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Social App. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'A modern social platform for connecting with friends, sharing moments, and building communities.',
        ),
      ],
    );
  }

  void _checkForUpdates(BuildContext context) {
    // Simulate checking for updates
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You\'re running the latest version!')),
    );
  }

  Future<void> _launchEmailSupport(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@socialapp.com',
      queryParameters: {
        'subject': 'Support Request',
        'body': 'Please describe your issue or question...',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      // Fallback - could show a dialog with email address
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email: support@socialapp.com')),
      );
    }
  }

  Future<void> _launchCommunityForum(BuildContext context) async {
    const url = 'https://forum.socialapp.com';
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Forum: $url')),
      );
    }
  }

  Future<void> _launchPrivacyPolicy(BuildContext context) async {
    const url = 'https://socialapp.com/privacy';
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Privacy Policy: $url')),
      );
    }
  }

  Future<void> _launchTermsOfService(BuildContext context) async {
    const url = 'https://socialapp.com/terms';
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terms of Service: $url')),
      );
    }
  }

  Future<void> _launchCommunityGuidelines(BuildContext context) async {
    const url = 'https://socialapp.com/guidelines';
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Community Guidelines: $url')),
      );
    }
  }
}
