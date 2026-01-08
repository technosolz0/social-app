import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme_constants.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        children: [
          // Push Notifications Section
          _buildSectionHeader('Push Notifications'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive push notifications'),
            value: true, // This would come from user settings
            onChanged: (value) {
              // Update push notification setting
            },
          ),

          const Divider(),

          // Posts & Stories Section
          _buildSectionHeader('Posts & Stories'),
          SwitchListTile(
            title: const Text('Likes'),
            subtitle: const Text('Get notified when someone likes your posts'),
            value: true, // This would come from user settings
            onChanged: (value) {
              // Update likes notification setting
            },
          ),
          SwitchListTile(
            title: const Text('Comments'),
            subtitle: const Text('Get notified when someone comments on your posts'),
            value: true, // This would come from user settings
            onChanged: (value) {
              // Update comments notification setting
            },
          ),
          SwitchListTile(
            title: const Text('New Followers'),
            subtitle: const Text('Get notified when someone follows you'),
            value: true, // This would come from user settings
            onChanged: (value) {
              // Update followers notification setting
            },
          ),
          SwitchListTile(
            title: const Text('Story Views'),
            subtitle: const Text('Get notified when someone views your story'),
            value: false, // This would come from user settings
            onChanged: (value) {
              // Update story views notification setting
            },
          ),

          const Divider(),

          // Messages Section
          _buildSectionHeader('Messages'),
          SwitchListTile(
            title: const Text('Direct Messages'),
            subtitle: const Text('Get notified for new messages'),
            value: true, // This would come from user settings
            onChanged: (value) {
              // Update DM notification setting
            },
          ),
          SwitchListTile(
            title: const Text('Message Requests'),
            subtitle: const Text('Get notified for message requests'),
            value: true, // This would come from user settings
            onChanged: (value) {
              // Update message requests notification setting
            },
          ),

          const Divider(),

          // Live & Reels Section
          _buildSectionHeader('Live & Reels'),
          SwitchListTile(
            title: const Text('Live Videos'),
            subtitle: const Text('Get notified about live videos from people you follow'),
            value: true, // This would come from user settings
            onChanged: (value) {
              // Update live notification setting
            },
          ),
          SwitchListTile(
            title: const Text('Reels'),
            subtitle: const Text('Get notified about new reels'),
            value: false, // This would come from user settings
            onChanged: (value) {
              // Update reels notification setting
            },
          ),

          const Divider(),

          // Email Notifications Section
          _buildSectionHeader('Email Notifications'),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive notifications via email'),
            value: false, // This would come from user settings
            onChanged: (value) {
              // Update email notification setting
            },
          ),
          ListTile(
            title: const Text('Email Frequency'),
            subtitle: const Text('How often to send email notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showEmailFrequencyDialog(context);
            },
          ),

          const Divider(),

          // Quiet Hours Section
          _buildSectionHeader('Quiet Hours'),
          SwitchListTile(
            title: const Text('Quiet Hours'),
            subtitle: const Text('Pause notifications during specified hours'),
            value: false, // This would come from user settings
            onChanged: (value) {
              // Update quiet hours setting
            },
          ),
          ListTile(
            title: const Text('Quiet Hours Schedule'),
            subtitle: const Text('Set start and end times'),
            trailing: const Icon(Icons.chevron_right),
            enabled: false, // Enable when quiet hours is on
            onTap: () {
              _showQuietHoursDialog(context);
            },
          ),

          const Divider(),

          // Advanced Section
          _buildSectionHeader('Advanced'),
          ListTile(
            leading: const Icon(Icons.notifications_paused),
            title: const Text('Pause All'),
            subtitle: const Text('Temporarily pause all notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showPauseNotificationsDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Manage Notification Types'),
            subtitle: const Text('Customize notification preferences'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/advanced-notification-settings');
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

  void _showEmailFrequencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Email Frequency'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email frequency set to: Immediately')),
              );
            },
            child: const Text('Immediately'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email frequency set to: Daily')),
              );
            },
            child: const Text('Daily'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email frequency set to: Weekly')),
              );
            },
            child: const Text('Weekly'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email frequency set to: Never')),
              );
            },
            child: const Text('Never'),
          ),
        ],
      ),
    );
  }

  void _showQuietHoursDialog(BuildContext context) {
    TimeOfDay startTime = const TimeOfDay(hour: 22, minute: 0); // 10:00 PM
    TimeOfDay endTime = const TimeOfDay(hour: 8, minute: 0);   // 8:00 AM

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Quiet Hours'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Start Time'),
                subtitle: Text(startTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: startTime,
                  );
                  if (picked != null) {
                    setState(() => startTime = picked);
                  }
                },
              ),
              ListTile(
                title: const Text('End Time'),
                subtitle: Text(endTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: endTime,
                  );
                  if (picked != null) {
                    setState(() => endTime = picked);
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
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Quiet hours set: ${startTime.format(context)} - ${endTime.format(context)}')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPauseNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Pause Notifications'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications paused for 1 hour')),
              );
            },
            child: const Text('For 1 hour'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications paused for 8 hours')),
              );
            },
            child: const Text('For 8 hours'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications paused for 24 hours')),
              );
            },
            child: const Text('For 24 hours'),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications paused until tomorrow')),
              );
            },
            child: const Text('Until tomorrow'),
          ),
        ],
      ),
    );
  }
}
