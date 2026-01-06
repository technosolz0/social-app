import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../data/models/conversation_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/api_service.dart';
import '../../providers/conversations_provider.dart';
import '../../providers/auth_provider.dart';

class EditGroupScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const EditGroupScreen({super.key, required this.conversationId});

  @override
  ConsumerState<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends ConsumerState<EditGroupScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  ConversationModel? _conversation;
  List<UserModel> _participants = [];
  List<UserModel> _availableUsers = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGroupDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadGroupDetails() async {
    try {
      setState(() => _isLoading = true);

      final apiService = ApiService();
      final conversationData = await apiService.getConversationById(widget.conversationId);
      _conversation = ConversationModel.fromJson(conversationData);

      // Load participants
      _participants = _conversation!.participants;

      // Load available users for adding to group
      final users = await apiService.searchUsers('', limit: 50);
      final currentUser = ref.read(authNotifierProvider).user;

      // Filter out current user and existing participants
      final participantIds = _participants.map((p) => p.id).toSet();
      _availableUsers = users.where((user) =>
        user.id != currentUser?.id && !participantIds.contains(user.id)
      ).toList();

      // Set initial values
      _nameController.text = _conversation!.name ?? '';
      // Description would be set if available in model

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

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group name cannot be empty')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // In a real implementation, you'd call an API to update the group
      // For now, we'll simulate the update
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group updated successfully')),
        );
        context.pop(); // Go back to chat settings
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update group: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _addParticipant(UserModel user) async {
    try {
      // In a real implementation, you'd call an API to add the user
      setState(() {
        _participants.add(user);
        _availableUsers.removeWhere((u) => u.id == user.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.username} added to group')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add user: $e')),
      );
    }
  }

  Future<void> _removeParticipant(UserModel user) async {
    final currentUser = ref.read(authNotifierProvider).user;
    if (user.id == currentUser?.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot remove yourself from the group')),
      );
      return;
    }

    try {
      // In a real implementation, you'd call an API to remove the user
      setState(() {
        _participants.removeWhere((p) => p.id == user.id);
        _availableUsers.add(user);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.username} removed from group')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove user: $e')),
      );
    }
  }

  void _showAddMembersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Members'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: _availableUsers.length,
            itemBuilder: (context, index) {
              final user = _availableUsers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  backgroundImage: user.avatar != null
                      ? NetworkImage(user.avatar!)
                      : null,
                  child: user.avatar == null
                      ? Text(
                          user.username.isNotEmpty
                              ? user.username[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                title: Text(user.username),
                subtitle: user.bio != null && user.bio!.isNotEmpty
                    ? Text(
                        user.bio!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  _addParticipant(user);
                },
              );
            },
          ),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Group')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Group')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Failed to load group details',
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
                onPressed: _loadGroupDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Group'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveChanges,
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        children: [
          // Group Avatar
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.group, size: 50, color: Colors.white),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      onPressed: () => _changeGroupAvatar(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.paddingLarge),

          // Group Name
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Group Name',
              hintText: 'Enter group name',
            ),
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          // Group Description
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Group Description (Optional)',
              hintText: 'Describe your group',
            ),
          ),

          const SizedBox(height: AppSizes.paddingLarge),

          // Members Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Members (${_participants.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _showAddMembersDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          // Members List
          ..._participants.map((participant) {
            final currentUser = ref.read(authNotifierProvider).user;
            final isCurrentUser = participant.id == currentUser?.id;
            final canRemove = !isCurrentUser; // Can't remove yourself

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
                  : canRemove
                      ? IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeParticipant(participant),
                        )
                      : null,
            );
          }),

          const SizedBox(height: AppSizes.paddingLarge),

          // Group Settings
          const Text(
            'Group Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          SwitchListTile(
            title: const Text('Allow members to edit group info'),
            value: true, // This would come from the group settings
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Group editing ${value ? 'enabled' : 'disabled'} for members')),
              );
            },
          ),

          SwitchListTile(
            title: const Text('Send message notifications'),
            value: true, // This would come from user preferences
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notifications ${value ? 'enabled' : 'disabled'}')),
              );
            },
          ),

          const SizedBox(height: AppSizes.paddingLarge),

          // Danger Zone
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Danger Zone',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Leave Group',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text('You will no longer receive messages from this group'),
                  onTap: () => _showLeaveGroupDialog(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _changeGroupAvatar() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Group Avatar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Camera opened')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gallery opened')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_emotions),
              title: const Text('Choose Emoji'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Emoji picker opened')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Reset to Default'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Avatar reset to default')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaveGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: const Text(
          'Are you sure you want to leave this group? You will no longer receive messages from this group.',
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
                      content: Text(success ? 'Left group successfully' : 'Failed to leave group'),
                    ),
                  );

                  if (success) {
                    // Navigate back to chats list
                    context.go('/chats');
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
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
