import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/post_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Social App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Activity/Notifications
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => context.push('/activity'),
            tooltip: 'Activity',
          ),
          // Messages/Chat
          IconButton(
            icon: const Icon(Icons.send_outlined),
            onPressed: () => context.push('/chats'),
            tooltip: 'Messages',
          ),
          // Settings
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: FeedScreen(),
    );
  }
}
