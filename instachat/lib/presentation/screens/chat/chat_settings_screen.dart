import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../data/models/conversation_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/conversations_provider.dart';

class ChatSettingsScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatSettingsScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends ConsumerState<ChatSettingsScreen> {
  ConversationModel? _conversation;
  List<UserModel> _participants = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isMuted = false;
  Duration? _disappearingMessages;

  @override
  void initState() {
    super.initState();
    _loadConversationDetails();
  }

  Future<void> _loadConversationDetails() async {
    try {
      setState(() => _isLoading = true);

      final apiService = ApiService();
      final conversationData = await apiService.getConversationById(widget.conversationId);

      // Convert to ConversationModel if needed
      // For now, we'll work with the raw data
      _conversation = ConversationModel.fromJson(conversationData);

      // Load participants
      if (_conversation!.participants.isNotEmpty) {
        // In a real implementation, you'd fetch participant details
        // For now, we'll use the participants from the conversation
        _participants = _conversation!.participants;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Details'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Details'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Failed to load chat details',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadConversationDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final conversation = _conversation!;
    final currentUser = ref.read(authNotifierProvider).user;
    final isGroupChat = conversation.conversationType == 'group';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Details'),
        actions: [
          if (isGroupChat)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push('/edit-group/${widget.conversationId}'),
            ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),

          // Chat Avatar
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[300],
              child: isGroupChat
                  ? const Icon(Icons.group, size: 40, color: Colors.white)
                  : const Icon(Icons.person, size: 40, color: Colors.white),
            ),
          ),

          const SizedBox(height: 16),

          // Chat Name
          Center(
            child: Text(
              isGroupChat
                  ? (conversation.name ?? 'Group Chat')
                  : (_participants.isNotEmpty ? _participants[0].username : 'Chat'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // Group description would go here if available

          const SizedBox(height: 8),

          // Participant count for groups
          if (isGroupChat)
            Center(
              child: Text(
                '${_participants.length} members',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),

          const SizedBox(height: 32),

          // Settings Section
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
            trailing: Switch(
              value: _isMuted,
              onChanged: (value) {
                setState(() => _isMuted = value);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isMuted ? 'Chat muted' : 'Chat unmuted'),
                  ),
                );
              },
            ),
          ),

          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text('Disappearing Messages'),
            subtitle: const Text('Messages will disappear after being read'),
            trailing: Text(
              _disappearingMessages != null
                  ? '${_disappearingMessages!.inHours}h'
                  : 'Off',
              style: TextStyle(color: Colors.grey[600]),
            ),
            onTap: () => _showDisappearingOptions(context),
          ),

          const Divider(),

          // Members Section
          if (isGroupChat) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium, vertical: 8),
              child: Text(
                'Members',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),

            // List participants
            ..._participants.map((participant) {
              final isCurrentUser = participant.id == currentUser?.id;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  backgroundImage: participant.avatar != null
                      ? NetworkImage(participant.avatar!)
                      : null,
                  child: participant.avatar == null
                      ? Text(
                          participant.username.isNotEmpty
                              ? participant.username[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                title: Text(participant.username),
                subtitle: participant.bio != null && participant.bio!.isNotEmpty
                    ? Text(
                        participant.bio!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                trailing: isCurrentUser
                    ? const Text('You', style: TextStyle(color: Colors.grey))
                    : null,
                onTap: () {
                  // Navigate to user profile
                  // context.push('/profile/${participant.id}');
                },
              );
            }),

            const Divider(),
          ],

          // Action buttons
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search in Chat'),
            onTap: () => _showSearchDialog(context),
          ),

          ListTile(
            leading: const Icon(Icons.wallpaper),
            title: const Text('Change Wallpaper'),
            onTap: () => _showWallpaperOptions(context),
          ),

          const Divider(),

          // Danger zone
          ListTile(
            leading: const Icon(Icons.report_problem_outlined, color: Colors.red),
            title: const Text('Report', style: TextStyle(color: Colors.red)),
            onTap: () => _showReportDialog(context),
          ),

          if (!isGroupChat)
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Block', style: TextStyle(color: Colors.red)),
              onTap: () => _showBlockDialog(context),
            ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              isGroupChat ? 'Leave Group' : 'Delete Chat',
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () => _showLeaveDialog(context, isGroupChat),
          ),
        ],
      ),
    );
  }

  void _showDisappearingOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disappearing Messages'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Duration?>(
              title: const Text('Off'),
              value: null,
              groupValue: _disappearingMessages,
              onChanged: (value) {
                setState(() => _disappearingMessages = value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<Duration?>(
              title: const Text('24 hours'),
              value: const Duration(hours: 24),
              groupValue: _disappearingMessages,
              onChanged: (value) {
                setState(() => _disappearingMessages = value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<Duration?>(
              title: const Text('7 days'),
              value: const Duration(days: 7),
              groupValue: _disappearingMessages,
              onChanged: (value) {
                setState(() => _disappearingMessages = value);
                Navigator.pop(context);
              },
            ),
            RadioListTile<Duration?>(
              title: const Text('90 days'),
              value: const Duration(days: 90),
              groupValue: _disappearingMessages,
              onChanged: (value) {
                setState(() => _disappearingMessages = value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Chat'),
        content: const Text('Are you sure you want to report this chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat reported')),
              );
            },
            child: const Text('Report', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: const Text('Are you sure you want to block this user? You won\'t receive messages from them.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User blocked')),
              );
            },
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search in Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search messages...',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (query) async {
                Navigator.pop(context);
                if (query.trim().isNotEmpty) {
                  await _performSearch(context, query.trim());
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Search through messages, media, and links in this chat.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final query = searchController.text.trim();
              Navigator.pop(context);
              if (query.isNotEmpty) {
                await _performSearch(context, query);
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Future<void> _performSearch(BuildContext context, String query) async {
    try {
      final apiService = ApiService();
      final searchResults = await apiService.searchConversationMessages(
        widget.conversationId,
        query,
      );

      if (mounted) {
        if (searchResults.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No messages found for "$query"')),
          );
        } else {
          // Navigate to search results screen with the results
          if (mounted) {
            context.push('/chat-search-results', extra: {
              'conversationId': widget.conversationId,
              'query': query,
              'results': searchResults,
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  void _showWallpaperOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chat Wallpaper',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickWallpaperFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Choose Color'),
              onTap: () {
                Navigator.pop(context);
                _showColorPicker();
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Reset to Default'),
              onTap: () {
                Navigator.pop(context);
                _resetWallpaper();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pickWallpaperFromGallery() {
    // In a real app, this would open the image picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery picker would open here')),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Wallpaper Color'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a color for your chat wallpaper:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Colors.blue,
                Colors.green,
                Colors.red,
                Colors.purple,
                Colors.orange,
                Colors.pink,
                Colors.teal,
                Colors.indigo,
              ].map((color) => GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Wallpaper color changed to ${color.toString()}')),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
              )).toList(),
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

  void _resetWallpaper() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wallpaper reset to default')),
    );
  }

  void _showLeaveDialog(BuildContext context, bool isGroupChat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isGroupChat ? 'Leave Group' : 'Delete Chat'),
        content: Text(
          isGroupChat
              ? 'Are you sure you want to leave this group?'
              : 'Are you sure you want to delete this chat? This action cannot be undone.',
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
                final success = await ref
                    .read(conversationsProvider.notifier)
                    .deleteConversation(widget.conversationId);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? (isGroupChat ? 'Left group' : 'Chat deleted')
                          : 'Failed to ${isGroupChat ? 'leave group' : 'delete chat'}'),
                    ),
                  );

                  if (success) {
                    // Navigate back
                    Navigator.of(context).pop();
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: Text(
              isGroupChat ? 'Leave' : 'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
