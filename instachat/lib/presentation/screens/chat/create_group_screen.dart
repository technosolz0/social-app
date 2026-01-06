import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/api_service.dart';
import '../../providers/conversations_provider.dart';
import '../../providers/auth_provider.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _nameController = TextEditingController();
  final List<String> _selectedUserIds = [];
  bool _isLoading = false;
  List<UserModel> _users = [];
  bool _isLoadingUsers = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() => _isLoadingUsers = true);
      final apiService = ApiService();
      // Get users that the current user can add to groups
      // Using search with empty query to get all users
      final users = await apiService.searchUsers('', limit: 50);
      final currentUser = ref.read(authNotifierProvider).user;

      // Filter out current user
      _users = users.where((user) => user.id != currentUser?.id).toList();

      setState(() {
        _isLoadingUsers = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _createGroup() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one user')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final convId = await ref.read(conversationsProvider.notifier).createGroupConversation(
        _selectedUserIds,
        _nameController.text.trim(),
      );

      if (convId != null && mounted) {
        context.pushReplacement('/chat/$convId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating group: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createGroup,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Create', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'Enter group name',
              ),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Participants',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: _isLoadingUsers
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 48, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load users',
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
                              onPressed: _loadUsers,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _users.isEmpty
                        ? const Center(
                            child: Text('No users available to add'),
                          )
                        : ListView.builder(
                            itemCount: _users.length,
                            itemBuilder: (context, index) {
                              final user = _users[index];
                              final isSelected = _selectedUserIds.contains(user.id);

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
                                title: Text(
                                  user.username,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: user.bio != null && user.bio!.isNotEmpty
                                    ? Text(
                                        user.bio!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : null,
                                trailing: Checkbox(
                                  value: isSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedUserIds.add(user.id);
                                      } else {
                                        _selectedUserIds.remove(user.id);
                                      }
                                    });
                                  },
                                ),
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedUserIds.remove(user.id);
                                    } else {
                                      _selectedUserIds.add(user.id);
                                    }
                                  });
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
