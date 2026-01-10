import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme_constants.dart';
import '../../widgets/common/custom_app_bar.dart';

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: SettingsAppBar(title: 'Privacy Settings'),
      body: ListView(
        children: [
          // Account Privacy Section
          _buildSectionHeader('Account Privacy'),
          SwitchListTile(
            title: const Text('Private Account'),
            subtitle: const Text('Only approved followers can see your posts'),
            value: false, // This would come from user settings
            onChanged: (value) {
              // Update privacy setting
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Private account ${value ? 'enabled' : 'disabled'}',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.visibility_off),
            title: const Text('Story Privacy'),
            subtitle: const Text('Who can see your stories'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showStoryPrivacyDialog(context);
            },
          ),

          const Divider(),

          // Interactions Section
          _buildSectionHeader('Interactions'),
          SwitchListTile(
            title: const Text('Allow Messages'),
            subtitle: const Text('Let others send you direct messages'),
            value: true, // This would come from user settings
            onChanged: (value) {
              // Update message setting
            },
          ),
          SwitchListTile(
            title: const Text('Allow Comments'),
            subtitle: const Text('Let others comment on your posts'),
            value: true, // This would come from user settings
            onChanged: (value) {
              // Update comment setting
            },
          ),
          SwitchListTile(
            title: const Text('Allow Tags'),
            subtitle: const Text('Let others tag you in posts'),
            value: true, // This would come from user settings
            onChanged: (value) {
              // Update tag setting
            },
          ),

          const Divider(),

          // Blocked & Restricted Section
          _buildSectionHeader('Blocked & Restricted'),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Blocked Users'),
            subtitle: const Text('Manage users you\'ve blocked'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/blocked-users');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_remove),
            title: const Text('Restricted Accounts'),
            subtitle: const Text('Accounts with limited interactions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showRestrictedUsersScreen(context);
            },
          ),

          const Divider(),

          // Data Sharing Section
          _buildSectionHeader('Data Sharing'),
          SwitchListTile(
            title: const Text('Share Activity Status'),
            subtitle: const Text('Let others see when you\'re active'),
            value: true, // This would come from user settings
            onChanged: (value) {
              // Update activity status setting
            },
          ),
          SwitchListTile(
            title: const Text('Share Read Receipts'),
            subtitle: const Text('Let others see when you read messages'),
            value: false, // This would come from user settings
            onChanged: (value) {
              // Update read receipts setting
            },
          ),

          const Divider(),

          // Location & Media Section
          _buildSectionHeader('Location & Media'),
          SwitchListTile(
            title: const Text('Location Services'),
            subtitle: const Text('Share your location in posts'),
            value: false, // This would come from user settings
            onChanged: (value) {
              // Update location setting
            },
          ),
          SwitchListTile(
            title: const Text('Save Photos'),
            subtitle: const Text('Automatically save photos you view'),
            value: true, // This would come from user settings
            onChanged: (value) {
              // Update save photos setting
            },
          ),

          const Divider(),

          // Legal Section
          _buildSectionHeader('Legal'),
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showPrivacyPolicy(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showTermsOfService(context);
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

  void _showStoryPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Story Privacy'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Story privacy set to: Everyone')),
              );
            },
            child: const Text('Everyone'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Story privacy set to: Followers'),
                ),
              );
            },
            child: const Text('Followers'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Story privacy set to: Close Friends'),
                ),
              );
            },
            child: const Text('Close Friends'),
          ),
        ],
      ),
    );
  }

  void _showRestrictedUsersScreen(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restricted Accounts'),
        content: const Text(
          'Restricted accounts can still see your posts, but their comments and messages will be hidden from you. '
          'They won\'t know they\'ve been restricted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Restricted users management coming soon'),
                ),
              );
            },
            child: const Text('Manage'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy Policy\n\n'
            'We collect information you provide directly to us, such as when you create an account, '
            'post content, or contact us for support. We also collect information about your use of our services, '
            'including your interactions with content and other users.\n\n'
            'We use this information to provide, maintain, and improve our services, communicate with you, '
            'and protect our users.\n\n'
            'We may share your information with third-party service providers who assist us in operating our platform, '
            'or when required by law.\n\n'
            'You have the right to access, update, or delete your personal information. '
            'Contact us at privacy@socialapp.com for any privacy-related inquiries.',
          ),
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

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Terms of Service\n\n'
            'By using our social media platform, you agree to these terms.\n\n'
            '1. You must be at least 13 years old to use our services.\n\n'
            '2. You are responsible for maintaining the confidentiality of your account credentials.\n\n'
            '3. You agree not to post harmful, offensive, or illegal content.\n\n'
            '4. We reserve the right to remove content that violates our community guidelines.\n\n'
            '5. We may suspend or terminate accounts that violate these terms.\n\n'
            '6. Our services are provided "as is" without warranties.\n\n'
            '7. We are not liable for any damages arising from your use of our services.\n\n'
            'These terms may be updated periodically. Continued use of our services constitutes acceptance of updated terms.',
          ),
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
}
