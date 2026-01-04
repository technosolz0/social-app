import 'package:flutter/material.dart';

// ============================================
// lib/core/extensions/context_extension.dart
// 🎨 CONTEXT EXTENSIONS FOR FLUTTER WIDGETS
// ============================================

extension ContextExtension on BuildContext {
  // ===========================================================================
  // THEME ACCESS
  // ===========================================================================

  /// Get the current theme
  ThemeData get theme => Theme.of(this);

  /// Get the text theme
  TextTheme get textTheme => theme.textTheme;

  /// Get the color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Check if dark mode is enabled
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Check if light mode is enabled
  bool get isLightMode => theme.brightness == Brightness.light;

  // ===========================================================================
  // MEDIA QUERY SHORTCUTS
  // ===========================================================================

  /// Get the media query data
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get the screen size
  Size get screenSize => mediaQuery.size;

  /// Get the screen width
  double get screenWidth => screenSize.width;

  /// Get the screen height
  double get screenHeight => screenSize.height;

  /// Get the device pixel ratio
  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  /// Get the status bar height
  double get statusBarHeight => mediaQuery.padding.top;

  /// Get the bottom safe area height
  double get bottomSafeArea => mediaQuery.padding.bottom;

  /// Get the top safe area height
  double get topSafeArea => mediaQuery.padding.top;

  /// Get the keyboard height
  double get keyboardHeight => mediaQuery.viewInsets.bottom;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => keyboardHeight > 0;

  // ===========================================================================
  // NAVIGATION SHORTCUTS
  // ===========================================================================

  /// Navigate to a new route
  Future<T?> push<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  /// Navigate to a new route and remove all previous routes
  Future<T?> pushAndRemoveUntil<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Replace current route
  Future<T?> pushReplacement<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Go back
  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  /// Check if can go back
  bool get canPop => Navigator.of(this).canPop();

  // ===========================================================================
  // SNACKBAR SHORTCUTS
  // ===========================================================================

  /// Show a snackbar
  void showSnackBar(String message, {
    Duration duration = const Duration(seconds: 4),
    Color? backgroundColor,
    Color? textColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }

  /// Show a success snackbar
  void showSuccessSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  /// Show an error snackbar
  void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  /// Show a warning snackbar
  void showWarningSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }

  // ===========================================================================
  // DIALOG SHORTCUTS
  // ===========================================================================

  /// Show a loading dialog
  void showLoadingDialog({
    String message = 'Loading...',
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// Hide loading dialog
  void hideLoadingDialog() {
    Navigator.of(this).pop();
  }

  /// Show a confirmation dialog
  Future<bool?> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: confirmColor != null
                ? TextButton.styleFrom(foregroundColor: confirmColor)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // RESPONSIVE DESIGN HELPERS
  // ===========================================================================

  /// Check if device is mobile
  bool get isMobile => screenWidth < 600;

  /// Check if device is tablet
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;

  /// Check if device is desktop
  bool get isDesktop => screenWidth >= 1200;

  /// Get responsive width based on screen size
  double responsiveWidth(double mobile, double tablet, double desktop) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }

  /// Get responsive height based on screen size
  double responsiveHeight(double mobile, double tablet, double desktop) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }

  /// Get responsive font size
  double responsiveFontSize(double baseSize) {
    if (isMobile) return baseSize;
    if (isTablet) return baseSize * 1.2;
    return baseSize * 1.4;
  }

  // ===========================================================================
  // FOCUS MANAGEMENT
  // ===========================================================================

  /// Unfocus all focus nodes
  void unfocus() {
    FocusScope.of(this).unfocus();
  }

  /// Request focus for a specific node
  void requestFocus(FocusNode node) {
    FocusScope.of(this).requestFocus(node);
  }

  // ===========================================================================
  // ORIENTATION HELPERS
  // ===========================================================================

  /// Check if device is in portrait mode
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;

  /// Check if device is in landscape mode
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;

  // ===========================================================================
  // LOCALIZATION HELPERS
  // ===========================================================================

  /// Get localized strings (requires AppLocalizations setup)
  // AppLocalizations get loc => AppLocalizations.of(this)!;

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Get the primary color
  Color get primaryColor => theme.primaryColor;

  /// Get the scaffold background color
  Color get backgroundColor => theme.scaffoldBackgroundColor;

  /// Get the card color
  Color get cardColor => theme.cardColor;

  /// Get the divider color
  Color get dividerColor => theme.dividerColor;

  /// Get the shadow color
  Color get shadowColor => theme.shadowColor;
}
