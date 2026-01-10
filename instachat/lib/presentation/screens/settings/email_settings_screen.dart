import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../data/services/api_service.dart';
import '../../providers/auth_provider.dart';

class EmailSettingsScreen extends ConsumerStatefulWidget {
  const EmailSettingsScreen({super.key});

  @override
  ConsumerState<EmailSettingsScreen> createState() => _EmailSettingsScreenState();
}

class _EmailSettingsScreenState extends ConsumerState<EmailSettingsScreen> {
  final _newEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isUpdatingEmail = false;

  @override
  void dispose() {
    _newEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateEmail() async {
    if (_newEmailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a new email address')),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_newEmailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() => _isUpdatingEmail = true);

    try {
      final apiService = ApiService();
      await apiService.customRequest(
        method: 'POST',
        path: '/users/update-email/',
        data: {
          'new_email': _newEmailController.text,
          'password': _passwordController.text,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email update request sent. Please check both email addresses for verification.')),
      );

      _newEmailController.clear();
      _passwordController.clear();

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update email: $e')),
      );
    } finally {
      setState(() => _isUpdatingEmail = false);
    }
  }

  void _showUpdateEmailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Email Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'New Email Address',
                hintText: 'Enter new email address',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                hintText: 'Enter your password to confirm',
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
            onPressed: _isUpdatingEmail ? null : _updateEmail,
            child: _isUpdatingEmail
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Update Email'),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Email Settings'),
      ),
      body: ListView(
        children: [
          // Current Email Section
          _buildSectionHeader('Current Email'),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Primary Email'),
            subtitle: Text(authState.user?.email ?? 'Not set'),
            trailing: const Icon(Icons.verified, color: Colors.green),
          ),

          const Divider(),

          // Email Management Section
          _buildSectionHeader('Email Management'),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Change Email Address'),
            subtitle: const Text('Update your email address'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showUpdateEmailDialog,
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add Recovery Email'),
            subtitle: const Text('Add a backup email for account recovery'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recovery email feature coming soon')),
              );
            },
          ),

          const Divider(),

          // Email Preferences Section
          _buildSectionHeader('Email Preferences'),
          SwitchListTile(
            title: const Text('Account Notifications'),
            subtitle: const Text('Security alerts and account updates'),
            value: true, // This would come from user preferences
            onChanged: (value) {
              // Update email preference
            },
          ),
          SwitchListTile(
            title: const Text('Marketing Emails'),
            subtitle: const Text('Product updates and promotions'),
            value: false, // This would come from user preferences
            onChanged: (value) {
              // Update marketing email preference
            },
          ),
          SwitchListTile(
            title: const Text('Weekly Digest'),
            subtitle: const Text('Summary of your activity'),
            value: true, // This would come from user preferences
            onChanged: (value) {
              // Update digest preference
            },
          ),

          const Divider(),

          // Email Verification Section
          _buildSectionHeader('Email Verification'),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('Verify Email Address'),
            subtitle: const Text('Confirm your email is valid'),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email is already verified')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Resend Verification Email'),
            subtitle: const Text('Send another verification email'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verification email sent')),
              );
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
}