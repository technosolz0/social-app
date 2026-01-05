import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/theme_constants.dart';

class ChatSettingsScreen extends ConsumerWidget {
  final String conversationId;

  const ChatSettingsScreen({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 40,
            child: Icon(Icons.group, size: 40),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Chat Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
            child: Text(
              'Settings',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Mute Messages'),
            trailing: Switch(value: false, onChanged: (v) {}),
          ),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text('Disappearing Messages'),
            trailing: const Text('Off', style: TextStyle(color: Colors.grey)),
            onTap: () {},
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium, vertical: 8),
            child: Text(
              'Members',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          // In a real app we would list participants here
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('You'),
            trailing: const Text('Admin', style: TextStyle(color: Colors.grey)),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.report_problem_outlined, color: Colors.red),
            title: const Text('Report', style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.block, color: Colors.red),
            title: const Text('Block', style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Leave Chat', style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
