import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme_constants.dart';

// ============================================
// lib/presentation/widgets/common/custom_app_bar.dart
// 🎨 REUSABLE APP BAR WIDGET
// ============================================

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? iconColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBackgroundColor = backgroundColor ?? theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor;
    final defaultTitleColor = titleColor ?? theme.appBarTheme.titleTextStyle?.color ?? theme.textTheme.titleLarge?.color;
    final defaultIconColor = iconColor ?? theme.appBarTheme.iconTheme?.color ?? theme.iconTheme.color;

    return AppBar(
      backgroundColor: defaultBackgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      title: Text(
        title,
        style: TextStyle(
          color: defaultTitleColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: leading ?? (showBackButton ? _buildBackButton(context, defaultIconColor!) : null),
      actions: actions,
      iconTheme: IconThemeData(color: defaultIconColor ?? Colors.black),
    );
  }

  Widget _buildBackButton(BuildContext context, Color iconColor) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: iconColor),
      onPressed: onBackPressed ?? () => context.pop(),
      tooltip: 'Back',
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ============================================
// COMMON APP BAR VARIANTS
// ============================================

class SocialAppBar extends CustomAppBar {
  const SocialAppBar({
    super.key,
    required super.title,
    super.actions,
    super.showBackButton,
    super.onBackPressed,
    super.leading,
    super.centerTitle,
    super.elevation,
  }) : super(
          backgroundColor: Colors.transparent,
          titleColor: Colors.white,
          iconColor: Colors.white,
        );
}

class SettingsAppBar extends CustomAppBar {
  const SettingsAppBar({
    super.key,
    required super.title,
    super.actions,
  }) : super(
          showBackButton: true,
          centerTitle: true,
          elevation: 0,
        );
}
