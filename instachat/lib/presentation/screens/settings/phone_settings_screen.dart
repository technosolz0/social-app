import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../data/services/api_service.dart';

class PhoneSettingsScreen extends ConsumerStatefulWidget {
  const PhoneSettingsScreen({super.key});

  @override
  ConsumerState<PhoneSettingsScreen> createState() => _PhoneSettingsScreenState();
}

class _PhoneSettingsScreenState extends ConsumerState<PhoneSettingsScreen> {
  final _newPhoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isUpdatingPhone = false;
  bool _isVerifyingOtp = false;
  bool _showOtpField = false;

  @override
  void dispose() {
    _newPhoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_newPhoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    // Basic phone number validation
    if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(_newPhoneController.text.replaceAll(RegExp(r'\s+'), ''))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    setState(() => _isUpdatingPhone = true);

    try {
      final apiService = ApiService();
      await apiService.customRequest(
        method: 'POST',
        path: '/users/send-phone-otp/',
        data: {
          'phone_number': _newPhoneController.text,
          'password': _passwordController.text,
        },
      );

      setState(() => _showOtpField = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent to your phone number')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP: $e')),
      );
    } finally {
      setState(() => _isUpdatingPhone = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP')),
      );
      return;
    }

    setState(() => _isVerifyingOtp = true);

    try {
      final apiService = ApiService();
      await apiService.customRequest(
        method: 'POST',
        path: '/users/verify-phone-otp/',
        data: {
          'phone_number': _newPhoneController.text,
          'otp': _otpController.text,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number updated successfully')),
      );

      _newPhoneController.clear();
      _otpController.clear();
      _passwordController.clear();
      setState(() => _showOtpField = false);

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify OTP: $e')),
      );
    } finally {
      setState(() => _isVerifyingOtp = false);
    }
  }

  void _showUpdatePhoneDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Phone Number'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'New Phone Number',
                  hintText: '+1234567890',
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
              if (_showOtpField) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                    hintText: 'Enter 6-digit OTP',
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _showOtpField
                  ? (_isVerifyingOtp ? null : _verifyOtp)
                  : (_isUpdatingPhone ? null : _sendOtp),
              child: _showOtpField
                  ? (_isVerifyingOtp
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify OTP'))
                  : (_isUpdatingPhone
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send OTP')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Settings'),
      ),
      body: ListView(
        children: [
          // Current Phone Section
          _buildSectionHeader('Current Phone'),
          const ListTile(
            leading: Icon(Icons.phone),
            title: Text('Primary Phone'),
            subtitle: Text('+1 (555) 123-4567'), // This would come from user data
            trailing: Icon(Icons.verified, color: Colors.green),
          ),

          const Divider(),

          // Phone Management Section
          _buildSectionHeader('Phone Management'),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Change Phone Number'),
            subtitle: const Text('Update your phone number'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showUpdatePhoneDialog,
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add Backup Phone'),
            subtitle: const Text('Add a secondary phone number'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup phone feature coming soon')),
              );
            },
          ),

          const Divider(),

          // Phone Preferences Section
          _buildSectionHeader('Phone Preferences'),
          SwitchListTile(
            title: const Text('SMS Notifications'),
            subtitle: const Text('Receive important alerts via SMS'),
            value: true, // This would come from user preferences
            onChanged: (value) {
              // Update SMS preference
            },
          ),
          SwitchListTile(
            title: const Text('WhatsApp Integration'),
            subtitle: const Text('Link with WhatsApp for better messaging'),
            value: false, // This would come from user preferences
            onChanged: (value) {
              // Update WhatsApp integration preference
            },
          ),

          const Divider(),

          // Phone Verification Section
          _buildSectionHeader('Phone Verification'),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('Verify Phone Number'),
            subtitle: const Text('Confirm your phone number is valid'),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Phone number is already verified')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Resend Verification SMS'),
            subtitle: const Text('Send another verification SMS'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verification SMS sent')),
              );
            },
          ),

          const Divider(),

          // Emergency Contacts Section
          _buildSectionHeader('Emergency Contacts'),
          ListTile(
            leading: const Icon(Icons.emergency),
            title: const Text('Emergency Contact'),
            subtitle: const Text('Add emergency contact for account recovery'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Emergency contact feature coming soon')),
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