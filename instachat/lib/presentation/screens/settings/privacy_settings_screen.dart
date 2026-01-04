import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme_constants.dart';

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
      ),
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
                SnackBar(content: Text('Private account ${value ? 'enabled' : 'disabled'}')),
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
              // TODO: Navigate to restricted users
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Restricted users coming soon')),
              );
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
              // TODO: Open privacy policy
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy policy coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Open terms of service
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms of service coming soon')),
              );
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
                const SnackBar(content: Text('Story privacy set to: Followers')),
              );
            },
            child: const Text('Followers'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Story privacy set to: Close Friends')),
              );
            },
            child: const Text('Close Friends'),
          ),
        ],
      ),
    );
  }
}
