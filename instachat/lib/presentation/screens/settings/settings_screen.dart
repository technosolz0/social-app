import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0A0E27), const Color(0xFF1A1F3A)]
                : [const Color(0xFFF8F9FA), const Color(0xFFE9ECEF)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: ShaderMask(
                    shaderCallback: (bounds) =>
                        AppTheme.primaryGradient.createShader(bounds),
                    child: const Text(
                      'Settings',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Theme Section
                      _buildModernCard(
                        context,
                        gradient: AppTheme.primaryGradient,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Appearance', Icons.palette),
                            const SizedBox(height: 12),
                            _buildThemeSelector(context, ref),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Account Section
                      _buildModernCard(
                        context,
                        gradient: AppTheme.secondaryGradient,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Account', Icons.person),
                            const SizedBox(height: 8),
                            _buildModernListTile(
                              context,
                              icon: Icons.edit,
                              title: 'Edit Profile',
                              onTap: () => context.go('/edit-profile'),
                            ),
                            _buildModernListTile(
                              context,
                              icon: Icons.lock,
                              title: 'Change Password',
                              onTap: () => context.go('/account-settings'),
                            ),
                            _buildModernListTile(
                              context,
                              icon: Icons.email,
                              title: 'Email',
                              subtitle: authState.user?.email ?? 'Not set',
                              onTap: () => context.go('/account-settings'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Privacy & Security
                      _buildModernCard(
                        context,
                        gradient: AppTheme.accentGradient,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              'Privacy & Security',
                              Icons.security,
                            ),
                            const SizedBox(height: 8),
                            _buildModernListTile(
                              context,
                              icon: Icons.block,
                              title: 'Blocked Users',
                              onTap: () => context.go('/privacy-settings'),
                            ),
                            _buildModernListTile(
                              context,
                              icon: Icons.visibility_off,
                              title: 'Privacy Settings',
                              onTap: () => context.go('/privacy-settings'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Notifications
                      _buildModernCard(
                        context,
                        gradient: AppTheme.sunsetGradient,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              'Notifications',
                              Icons.notifications,
                            ),
                            const SizedBox(height: 8),
                            _buildModernListTile(
                              context,
                              icon: Icons.notifications_active,
                              title: 'Notification Settings',
                              onTap: () => context.go('/notification-settings'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Features & Apps
                      _buildModernCard(
                        context,
                        gradient: AppTheme.oceanGradient,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Features', Icons.apps),
                            const SizedBox(height: 8),
                            _buildModernListTile(
                              context,
                              icon: Icons.chat,
                              title: 'Messages',
                              onTap: () => context.go('/chats'),
                            ),
                            _buildModernListTile(
                              context,
                              icon: Icons.emoji_events,
                              title: 'Gamification',
                              subtitle: 'Badges, points, and quests',
                              onTap: () => _showGamificationMenu(context),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Support
                      _buildModernCard(
                        context,
                        gradient: LinearGradient(
                          colors: [Colors.grey[700]!, Colors.grey[600]!],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Support', Icons.help),
                            const SizedBox(height: 8),
                            _buildModernListTile(
                              context,
                              icon: Icons.help_center,
                              title: 'Help Center',
                              onTap: () => context.go('/help'),
                            ),
                            _buildModernListTile(
                              context,
                              icon: Icons.info,
                              title: 'About',
                              subtitle: 'Version 1.0.0',
                              onTap: () => context.go('/help'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Logout Button
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showLogoutDialog(context, ref),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.logout, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text(
                                    'Log Out',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard(
    BuildContext context, {
    required Widget child,
    required Gradient gradient,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A1F3A), const Color(0xFF252B49)]
              : [Colors.white, Colors.white.withValues(alpha: 0.9)],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildModernListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.getSubtitleColor(context),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppTheme.getSubtitleColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);

    return Row(
      children: [
        Expanded(
          child: _buildThemeOption(
            context,
            ref,
            AppThemeMode.light,
            Icons.light_mode,
            'Light',
            currentTheme == AppThemeMode.light,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildThemeOption(
            context,
            ref,
            AppThemeMode.dark,
            Icons.dark_mode,
            'Dark',
            currentTheme == AppThemeMode.dark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildThemeOption(
            context,
            ref,
            AppThemeMode.system,
            Icons.brightness_auto,
            'Auto',
            currentTheme == AppThemeMode.system,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode mode,
    IconData icon,
    String label,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => ref.read(themeNotifierProvider.notifier).setThemeMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected
              ? null
              : AppTheme.getSubtitleColor(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppTheme.getSubtitleColor(context).withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : AppTheme.getSubtitleColor(context),
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : AppTheme.getSubtitleColor(context),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGamificationMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [const Color(0xFF1A1F3A), const Color(0xFF252B49)]
                : [Colors.white, Colors.grey[50]!],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.primaryGradient.createShader(bounds),
              child: const Text(
                'Gamification',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildGamificationOption(
              context,
              Icons.emoji_events,
              'Badges',
              AppTheme.warningColor,
              '/badges',
            ),
            _buildGamificationOption(
              context,
              Icons.leaderboard,
              'Leaderboard',
              AppTheme.primaryColor,
              '/leaderboard',
            ),
            _buildGamificationOption(
              context,
              Icons.stars,
              'Points',
              AppTheme.successColor,
              '/points',
            ),
            _buildGamificationOption(
              context,
              Icons.assignment,
              'Quests',
              AppTheme.secondaryColor,
              '/quests',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamificationOption(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    String route,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.pop(context); // Close the bottom sheet
          context.push(route);
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
