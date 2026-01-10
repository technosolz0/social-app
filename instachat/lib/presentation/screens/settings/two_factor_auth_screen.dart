import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../data/services/api_service.dart';

class TwoFactorAuthScreen extends ConsumerStatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  ConsumerState<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends ConsumerState<TwoFactorAuthScreen> {
  bool _is2FAEnabled = false;
  bool _isLoading = false;
  String? _secretKey;
  String? _qrCodeUrl;
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _check2FAStatus();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _check2FAStatus() async {
    try {
      final apiService = ApiService();
      final response = await apiService.customRequest(
        method: 'GET',
        path: '/users/2fa-status/',
      );

      setState(() {
        _is2FAEnabled = response.data['is_enabled'] ?? false;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _enable2FA() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.customRequest(
        method: 'POST',
        path: '/users/enable-2fa/',
      );

      setState(() {
        _secretKey = response.data['secret_key'];
        _qrCodeUrl = response.data['qr_code_url'];
      });

      _showSetupDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to enable 2FA: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyAndEnable2FA() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      await apiService.customRequest(
        method: 'POST',
        path: '/users/verify-2fa/',
        data: {
          'otp': _otpController.text,
          'secret_key': _secretKey,
        },
      );

      setState(() {
        _is2FAEnabled = true;
        _secretKey = null;
        _qrCodeUrl = null;
      });

      _otpController.clear();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Two-factor authentication enabled successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify 2FA code: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _disable2FA() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      await apiService.customRequest(
        method: 'POST',
        path: '/users/disable-2fa/',
      );

      setState(() {
        _is2FAEnabled = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Two-factor authentication disabled')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to disable 2FA: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Up Two-Factor Authentication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '1. Install an authenticator app (Google Authenticator, Authy, etc.)',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '2. Scan the QR code below with your authenticator app:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_qrCodeUrl != null)
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.network(
                  _qrCodeUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text('QR Code not available'),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              '3. Enter the 6-digit code from your authenticator app:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: '000000',
                border: OutlineInputBorder(),
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
            onPressed: _isLoading ? null : _verifyAndEnable2FA,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enable 2FA'),
          ),
        ],
      ),
    );
  }

  void _showDisableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable Two-Factor Authentication'),
        content: const Text(
          'Are you sure you want to disable two-factor authentication? '
          'This will make your account less secure.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _disable2FA();
            },
            child: const Text(
              'Disable',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Two-Factor Authentication'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        children: [
          // Status Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                children: [
                  Icon(
                    _is2FAEnabled ? Icons.security : Icons.security_outlined,
                    size: 48,
                    color: _is2FAEnabled ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _is2FAEnabled ? 'Two-Factor Authentication is Enabled' : 'Two-Factor Authentication is Disabled',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _is2FAEnabled
                        ? 'Your account is protected with an additional layer of security.'
                        : 'Add an extra layer of security to your account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action Button
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : (_is2FAEnabled ? _showDisableDialog : _enable2FA),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: _is2FAEnabled ? Colors.red : Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(_is2FAEnabled ? 'Disable 2FA' : 'Enable 2FA'),
          ),

          const SizedBox(height: 32),

          // Information Section
          _buildSectionHeader('How It Works'),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Two-factor authentication adds an extra layer of security to your account.',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 12),
                  Text('• Install an authenticator app on your phone'),
                  Text('• Scan the QR code to link your account'),
                  Text('• Enter the 6-digit code when signing in'),
                  SizedBox(height: 12),
                  Text(
                    'Recommended authenticator apps:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text('• Google Authenticator'),
                  Text('• Authy'),
                  Text('• Microsoft Authenticator'),
                  Text('• 1Password'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Backup Codes Section
          if (_is2FAEnabled) ...[
            _buildSectionHeader('Backup Codes'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Backup codes can be used to access your account if you lose your phone.',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Backup codes feature coming soon')),
                        );
                      },
                      child: const Text('Generate Backup Codes'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}