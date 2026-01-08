import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../data/services/api_service.dart';

class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key});

  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  List<Map<String, dynamic>> _devices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    try {
      final apiService = ApiService();
      final response = await apiService.customRequest(
        method: 'GET',
        path: '/users/devices/',
      );

      setState(() {
        _devices = List<Map<String, dynamic>>.from(response.data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load devices: $e')),
      );
    }
  }

  Future<void> _revokeDeviceAccess(String deviceId) async {
    try {
      final apiService = ApiService();
      await apiService.customRequest(
        method: 'POST',
        path: '/users/revoke-device/',
        data: {'device_id': deviceId},
      );

      setState(() {
        _devices.removeWhere((device) => device['id'] == deviceId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device access revoked')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to revoke device access: $e')),
      );
    }
  }

  void _showRevokeDialog(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Device Access'),
        content: Text(
          'Are you sure you want to revoke access for "${device['device_name'] ?? device['device_type']}"? '
          'You will need to sign in again on that device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _revokeDeviceAccess(device['id']);
            },
            child: const Text(
              'Revoke',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _getDeviceIcon(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'ios':
        return '📱';
      case 'android':
        return '🤖';
      case 'web':
        return '💻';
      default:
        return '📱';
    }
  }

  String _formatLastActive(DateTime? lastActive) {
    if (lastActive == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Devices'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _devices.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.devices, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No devices found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    final isCurrentDevice = device['is_current'] ?? false;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingMedium,
                        vertical: AppSizes.paddingSmall,
                      ),
                      child: ListTile(
                        leading: Text(
                          _getDeviceIcon(device['device_type'] ?? 'unknown'),
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          device['device_name'] ?? '${device['device_type']} Device',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last active: ${_formatLastActive(device['last_active'] != null ? DateTime.parse(device['last_active']) : null)}',
                            ),
                            if (device['location'] != null)
                              Text(
                                'Location: ${device['location']}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: isCurrentDevice
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: const Text(
                                  'Current',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : IconButton(
                                onPressed: () => _showRevokeDialog(device),
                                icon: const Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                ),
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}