import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/constants/theme_constants.dart';
import '../../../data/models/conversation_model.dart';
import '../../providers/conversations_provider.dart';
import '../../providers/auth_provider.dart';

class ChatsListScreen extends ConsumerStatefulWidget {
  const ChatsListScreen({super.key});

  @override
  ConsumerState<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends ConsumerState<ChatsListScreen> {
  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/create-group'),
          ),
        ],
      ),
      body: conversationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (conversations) {
          if (conversations.isEmpty) {
            return _buildEmptyState();
          }
          return _buildConversationsList(conversations);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-group'),
        child: const Icon(Icons.message),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: AppSizes.paddingLarge),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Text(
            'Start a conversation with someone',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          ElevatedButton.icon(
            onPressed: () => _showUserPicker(context),
            icon: const Icon(Icons.add),
            label: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList(List<ConversationModel> conversations) {
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return _buildConversationItem(conversation);
      },
    );
  }

  Widget _buildConversationItem(ConversationModel conversation) {
    final currentUser = ref.read(authNotifierProvider).user;
    final otherParticipants = conversation.participants
        .where((p) => p.id != currentUser?.id)
        .toList();

    // For direct messages, show the other participant
    // For group chats, show group name
    String displayName;
    String? avatar;
    bool isOnline = false;

    if (conversation.conversationType == 'group') {
      displayName = conversation.name ?? 'Group Chat';
      avatar = null; // Group avatar
    } else {
      final participant = otherParticipants.isNotEmpty
          ? otherParticipants[0]
          : conversation.participants[0];
      displayName = participant.username;
      avatar = participant.avatar;
      isOnline = true; // Mock online for demo
    }

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[300],
            backgroundImage: avatar != null ? NetworkImage(avatar) : null,
            child: avatar == null
                ? Text(
                    displayName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          if (conversation.conversationType == 'direct' && isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              displayName,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          if (conversation.lastMessage != null)
            Text(
              timeago.format(
                DateTime.parse(conversation.lastMessage!['created_at'] ?? ''),
              ),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                conversation.lastMessage?['content'] ?? 'No messages yet',
                style: TextStyle(
                  fontSize: 14,
                  color: (conversation.unreadCount ?? 0) > 0
                      ? Colors.black
                      : Colors.grey[600],
                  fontWeight: (conversation.unreadCount ?? 0) > 0
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if ((conversation.unreadCount ?? 0) > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  conversation.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      onTap: () {
        // Navigate to chat room
        context.go('/chat/${conversation.id}');
      },
      onLongPress: () {
        _showConversationOptions(context, conversation);
      },
    );
  }

  void _showConversationOptions(
    BuildContext context,
    ConversationModel conversation,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_off),
            title: const Text('Mute Conversation'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conversation muted')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Delete Conversation',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, conversation);
            },
          ),
          ListTile(
            leading: const Icon(Icons.block, color: Colors.red),
            title: const Text(
              'Block User',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('User blocked')));
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ConversationModel conversation,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text(
          'Are you sure you want to delete this conversation? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(conversationsProvider.notifier)
                  .deleteConversation(conversation.id);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Conversation deleted'
                          : 'Failed to delete conversation',
                    ),
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUserPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Start New Chat',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppSizes.borderRadiusMedium,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: (query) {
                  // TODO: Implement search functionality
                },
              ),
            ),

            // User list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: 10, // Mock data
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        'U${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text('User ${index + 1}'),
                    subtitle: Text('Last seen ${index + 1} hours ago'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to chat with selected user
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Starting chat with User ${index + 1}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
