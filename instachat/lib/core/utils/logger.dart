// ============================================
// lib/core/utils/logger.dart
// 🖨️ DEBUG LOGGING UTILITY
// ============================================

import 'package:flutter/foundation.dart';

/// Debug logging utility for development
/// Only prints in debug mode, completely removed in production builds
class Logger {
  /// Print debug message only in debug mode
  static void d(String message) {
    if (kDebugMode) {
      print('[DEBUG] $message');
    }
  }

  /// Print error message only in debug mode
  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[ERROR] $message');
      if (error != null) {
        print('[ERROR] Exception: $error');
      }
      if (stackTrace != null) {
        print('[ERROR] StackTrace: $stackTrace');
      }
    }
  }

  /// Print warning message only in debug mode
  static void w(String message) {
    if (kDebugMode) {
      print('[WARNING] $message');
    }
  }

  /// Print info message only in debug mode
  static void i(String message) {
    if (kDebugMode) {
      print('[INFO] $message');
    }
  }

  /// Print verbose message only in debug mode
  static void v(String message) {
    if (kDebugMode) {
      print('[VERBOSE] $message');
    }
  }
}

/// Legacy alias for backward compatibility
/// @deprecated Use Logger.d() instead
void dPrint(String message) {
  Logger.d(message);
}
