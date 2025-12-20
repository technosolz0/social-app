import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/constants/theme_constants.dart';

class ChatsListScreen extends ConsumerStatefulWidget {
  const ChatsListScreen({super.key});

  @override
  ConsumerState<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends ConsumerState<ChatsListScreen> {
  // Mock conversations data
  final List<Map<String, dynamic>> _conversations = [
    {
      'id': '1',
      'type': 'direct',
      'name': null,
      'participants': [
        {'username': 'john_doe', 'avatar': null, 'isOnline': true}
      ],
      'lastMessage': {
        'content': 'Hey, how are you doing?',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
        'senderId': 'john_doe',
      },
      'unreadCount': 2,
    },
    {
      'id': '2',
      'type': 'direct',
      'name': null,
      'participants': [
        {'username': 'jane_smith', 'avatar': null, 'isOnline': false}
      ],
      'lastMessage': {
        'content': 'Thanks for the help! 👍',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'senderId': 'current_user',
      },
      'unreadCount': 0,
    },
    {
      'id': '3',
      'type': 'group',
      'name': 'Flutter Devs',
      'participants': [
        {'username': 'alice', 'avatar': null, 'isOnline': true},
        {'username': 'bob', 'avatar': null, 'isOnline': false},
        {'username': 'charlie', 'avatar': null, 'isOnline': true},
      ],
      'lastMessage': {
        'content': 'Anyone up for a meetup?',
        'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
        'senderId': 'alice',
      },
      'unreadCount': 1,
    },
    {
      'id': '4',
      'type': 'direct',
      'name': null,
      'participants': [
        {'username': 'mike_johnson', 'avatar': null, 'isOnline': true}
      ],
      'lastMessage': {
        'content': 'Check out this new feature!',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'senderId': 'mike_johnson',
      },
      'unreadCount': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Create new message
            },
          ),
        ],
      ),
      body: _conversations.isEmpty
          ? _buildEmptyState()
          : _buildConversationsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Start new conversation
        },
        child: const Icon(Icons.message),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
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
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Start new conversation
            },
            icon: const Icon(Icons.add),
            label: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList() {
    return ListView.builder(
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return _buildConversationItem(conversation);
      },
    );
  }

  Widget _buildConversationItem(Map<String, dynamic> conversation) {
    final participants = conversation['participants'] as List<dynamic>;
    final lastMessage = conversation['lastMessage'] as Map<String, dynamic>;
    final unreadCount = conversation['unreadCount'] as int;

    // For direct messages, show the other participant
    // For group chats, show group name
    String displayName;
    String? avatar;
    bool isOnline = false;

    if (conversation['type'] == 'group') {
      displayName = conversation['name'] ?? 'Group Chat';
      avatar = null; // Group avatar
    } else {
      final participant = participants[0] as Map<String, dynamic>;
      displayName = participant['username'];
      avatar = participant['avatar'];
      isOnline = participant['isOnline'] ?? false;
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
          if (conversation['type'] == 'direct' && isOnline)
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
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timeago.format(lastMessage['timestamp']),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                lastMessage['content'],
                style: TextStyle(
                  fontSize: 14,
                  color: unreadCount > 0 ? Colors.black : Colors.grey[600],
                  fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount.toString(),
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
        context.go('/chat/${conversation['id']}');
      },
      onLongPress: () {
        _showConversationOptions(context, conversation);
      },
    );
  }

  void _showConversationOptions(BuildContext context, Map<String, dynamic> conversation) {
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
              // TODO: Mute conversation
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
              // TODO: Block user
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> conversation) {
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
            onPressed: () {
              Navigator.pop(context);
              // TODO: Delete conversation
              setState(() {
                _conversations.remove(conversation);
              });
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
