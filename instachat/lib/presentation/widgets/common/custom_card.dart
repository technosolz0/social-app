import 'package:flutter/material.dart';

// ============================================
// lib/presentation/widgets/common/custom_card.dart
// 🎨 REUSABLE CARD WIDGETS
// ============================================

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final double borderRadius;
  final BorderRadiusGeometry? customBorderRadius;
  final BoxShadow? shadow;
  final Border? border;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius = 12,
    this.customBorderRadius,
    this.shadow,
    this.border,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.cardColor;
    final borderRadiusGeometry = customBorderRadius ?? BorderRadius.circular(borderRadius);

    final cardWidget = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: borderRadiusGeometry,
        border: border,
        boxShadow: shadow != null ? [shadow!] : (elevation != null && elevation! > 0)
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.1),
                  blurRadius: elevation! * 2,
                  offset: Offset(0, elevation!),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadiusGeometry,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadiusGeometry is BorderRadius ? borderRadiusGeometry : null,
            child: Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );

    return cardWidget;
  }
}

// ============================================
// COMMON CARD VARIANTS
// ============================================

class PostCard extends CustomCard {
  const PostCard({
    super.key,
    required super.child,
    super.onTap,
    super.width,
    super.height,
  }) : super(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          borderRadius: 8,
          elevation: 1,
        );
}

class ProfileCard extends CustomCard {
  ProfileCard({
    super.key,
    required Widget child,
    super.onTap,
  }) : super(
          child: child,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(8),
          borderRadius: 16,
          elevation: 2,
        );
}

class SettingsCard extends CustomCard {
  SettingsCard({
    super.key,
    required Widget child,
    super.onTap,
  }) : super(
          child: child,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
          borderRadius: 8,
          color: Colors.grey[50],
        );
}
