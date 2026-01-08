import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../data/services/api_service.dart';

class AdvancedNotificationSettingsScreen extends ConsumerStatefulWidget {
  const AdvancedNotificationSettingsScreen({super.key});

  @override
  ConsumerState<AdvancedNotificationSettingsScreen> createState() => _AdvancedNotificationSettingsScreenState();
}

class _AdvancedNotificationSettingsScreenState extends ConsumerState<AdvancedNotificationSettingsScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _preferences = {};

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ApiService();
      final preferences = await apiService.getNotificationPreferences();
      setState(() {
        _preferences = preferences;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load preferences: $e')),
        );
      }
    }
  }

  Future<void> _updatePreference(String key, bool value) async {
    final oldValue = _preferences[key];
    setState(() {
      _preferences[key] = value;
    });

    try {
      final apiService = ApiService();
      await apiService.updateNotificationPreferences({key: value});
    } catch (e) {
      // Revert on error
      setState(() {
        _preferences[key] = oldValue;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update preference: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Notification Settings'),
      ),
      body: ListView(
        children: [
          // Granular Control Section
          _buildSectionHeader('Granular Notification Control'),
          _buildPreferenceTile(
            'Likes on Posts',
            'Get notified when someone likes your posts',
            'push_likes',
          ),
          _buildPreferenceTile(
            'Likes on Comments',
            'Get notified when someone likes your comments',
            'push_comment_likes',
          ),
          _buildPreferenceTile(
            'Comments on Posts',
            'Get notified when someone comments on your posts',
            'push_comments',
          ),
          _buildPreferenceTile(
            'Replies to Comments',
            'Get notified when someone replies to your comments',
            'push_replies',
          ),
          _buildPreferenceTile(
            'Mentions',
            'Get notified when someone mentions you',
            'push_mentions',
          ),

          const Divider(),

          // Social Interactions Section
          _buildSectionHeader('Social Interactions'),
          _buildPreferenceTile(
            'New Followers',
            'Get notified when someone follows you',
            'push_follows',
          ),
          _buildPreferenceTile(
            'Follow Requests',
            'Get notified of follow requests (if account is private)',
            'push_follow_requests',
          ),
          _buildPreferenceTile(
            'Story Views',
            'Get notified when someone views your story',
            'push_story_views',
          ),
          _buildPreferenceTile(
            'Story Replies',
            'Get notified when someone replies to your story',
            'push_story_replies',
          ),

          const Divider(),

          // Content Interactions Section
          _buildSectionHeader('Content Interactions'),
          _buildPreferenceTile(
            'Shares',
            'Get notified when someone shares your content',
            'push_shares',
          ),
          _buildPreferenceTile(
            'Tags',
            'Get notified when someone tags you in a post',
            'push_tags',
          ),
          _buildPreferenceTile(
            'Live Streams',
            'Get notified about live streams from people you follow',
            'push_live',
          ),
          _buildPreferenceTile(
            'Reels',
            'Get notified about new reels from people you follow',
            'push_reels',
          ),

          const Divider(),

          // Gamification Section
          _buildSectionHeader('Gamification'),
          _buildPreferenceTile(
            'Badges Earned',
            'Get notified when you earn new badges',
            'push_badges',
          ),
          _buildPreferenceTile(
            'Level Up',
            'Get notified when you level up',
            'push_level_up',
          ),
          _buildPreferenceTile(
            'Points Milestones',
            'Get notified when you reach point milestones',
            'push_points',
          ),
          _buildPreferenceTile(
            'Quest Completion',
            'Get notified when you complete quests',
            'push_quests',
          ),

          const Divider(),

          // System & Admin Section
          _buildSectionHeader('System & Administrative'),
          _buildPreferenceTile(
            'Account Security',
            'Security alerts and login notifications',
            'push_security',
          ),
          _buildPreferenceTile(
            'System Updates',
            'Important system announcements',
            'push_system',
          ),
          _buildPreferenceTile(
            'Feature Updates',
            'New features and app updates',
            'push_features',
          ),
          _buildPreferenceTile(
            'Marketing',
            'Promotional content and offers',
            'push_marketing',
          ),

          const Divider(),

          // Advanced Options Section
          _buildSectionHeader('Advanced Options'),
          ListTile(
            leading: const Icon(Icons.notifications_off),
            title: const Text('Do Not Disturb Mode'),
            subtitle: const Text('Override all notifications during DND'),
            trailing: Switch(
              value: _preferences['dnd_override'] ?? false,
              onChanged: (value) => _updatePreference('dnd_override', value),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.vibration),
            title: const Text('Vibration'),
            subtitle: const Text('Vibrate device for notifications'),
            trailing: Switch(
              value: _preferences['vibration_enabled'] ?? true,
              onChanged: (value) => _updatePreference('vibration_enabled', value),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.volume_up),
            title: const Text('Sound'),
            subtitle: const Text('Play sound for notifications'),
            trailing: Switch(
              value: _preferences['sound_enabled'] ?? true,
              onChanged: (value) => _updatePreference('sound_enabled', value),
            ),
          ),

          const Divider(),

          // Reset Section
          _buildSectionHeader('Reset Settings'),
          ListTile(
            leading: const Icon(Icons.restore, color: Colors.orange),
            title: const Text('Reset to Defaults'),
            subtitle: const Text('Restore all notification settings to default'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showResetDialog(),
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

  Widget _buildPreferenceTile(String title, String subtitle, String preferenceKey) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: _preferences[preferenceKey] ?? true,
      onChanged: (value) => _updatePreference(preferenceKey, value),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Notification Settings'),
        content: const Text(
          'Are you sure you want to reset all notification settings to their default values? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                final apiService = ApiService();
                await apiService.customRequest(
                  method: 'POST',
                  path: '/notifications/reset-preferences/',
                );

                await _loadPreferences(); // Reload preferences

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification settings reset to defaults')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to reset settings: $e')),
                  );
                }
              }
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}