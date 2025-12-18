import 'package:flutter/material.dart';

// ============================================
// lib/presentation/widgets/common/error_widget.dart
// 🎨 ERROR STATE WIDGET
// ============================================

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryText;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.subtitle,
    this.icon = Icons.error_outline,
    this.onRetry,
    this.retryText = 'Retry',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(retryText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
