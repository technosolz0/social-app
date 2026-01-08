import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../data/services/api_service.dart';
import '../../providers/auth_provider.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isChangingPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => _isChangingPassword = true);

    try {
      final apiService = ApiService();
      await apiService.customRequest(
        method: 'POST',
        path: '/users/change-password/',
        data: {
          'current_password': _currentPasswordController.text,
          'new_password': _newPasswordController.text,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to change password: $e')),
      );
    } finally {
      setState(() => _isChangingPassword = false);
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                hintText: 'Enter current password',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                hintText: 'Enter new password',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                hintText: 'Confirm new password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _isChangingPassword ? null : _changePassword,
            child: _isChangingPassword
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
      ),
      body: ListView(
        children: [
          // Account Information Section
          _buildSectionHeader('Account Information'),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Username'),
            subtitle: Text(authState.user?.username ?? 'Not set'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to edit profile
              context.go('/edit-profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(authState.user?.email ?? 'Not set'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/email-settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Phone Number'),
            subtitle: const Text('Not set'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/phone-settings');
            },
          ),

          const Divider(),

          // Security Section
          _buildSectionHeader('Security'),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showChangePasswordDialog,
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Two-Factor Authentication'),
            subtitle: const Text('Not enabled'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/two-factor-auth');
            },
          ),
          ListTile(
            leading: const Icon(Icons.devices),
            title: const Text('Login Devices'),
            subtitle: const Text('Manage your active sessions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/devices');
            },
          ),

          const Divider(),

          // Data & Privacy Section
          _buildSectionHeader('Data & Privacy'),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Download Your Data'),
            subtitle: const Text('Get a copy of your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showDataDownloadDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete Account'),
            subtitle: const Text('Permanently delete your account'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showDeleteAccountDialog();
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

  void _showDataDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Your Data'),
        content: const Text(
          'We will prepare a download of all your data including posts, messages, and account information. '
          'This may take up to 24 hours. You will receive a notification when your data is ready.',
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
                  path: '/users/request-data-download/',
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data download request submitted. You will be notified when ready.')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to request data download: $e')),
                );
              }
            },
            child: const Text('Request Download'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.\n\n'
          'This includes:\n'
          '• All your posts and stories\n'
          '• All messages and conversations\n'
          '• Your profile and account information\n'
          '• All points and badges earned',
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
                  method: 'DELETE',
                  path: '/users/delete-account/',
                );

                // Logout user
                ref.read(authNotifierProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete account: $e')),
                );
              }
            },
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
