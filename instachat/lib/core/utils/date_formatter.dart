import 'package:intl/intl.dart';

// ============================================
// lib/core/utils/date_formatter.dart
// 📅 DATE FORMATTING UTILITIES
// ============================================

class DateFormatter {
  static const DateFormatter _instance = DateFormatter._internal();
  const DateFormatter._internal();
  factory DateFormatter() => _instance;

  // ===========================================================================
  // DATE FORMAT PATTERNS
  // ===========================================================================

  static const String _fullDateTimePattern = 'yyyy-MM-dd HH:mm:ss';
  static const String _dateOnlyPattern = 'yyyy-MM-dd';
  static const String _timeOnlyPattern = 'HH:mm:ss';
  static const String _displayDatePattern = 'MMM dd, yyyy';
  static const String _displayTimePattern = 'hh:mm a';
  static const String _displayDateTimePattern = 'MMM dd, yyyy \'at\' hh:mm a';

  // ===========================================================================
  // FORMATTERS
  // ===========================================================================

  static final DateFormat _fullDateTimeFormatter = DateFormat(_fullDateTimePattern);
  static final DateFormat _dateOnlyFormatter = DateFormat(_dateOnlyPattern);
  static final DateFormat _timeOnlyFormatter = DateFormat(_timeOnlyPattern);
  static final DateFormat _displayDateFormatter = DateFormat(_displayDatePattern);
  static final DateFormat _displayTimeFormatter = DateFormat(_displayTimePattern);
  static final DateFormat _displayDateTimeFormatter = DateFormat(_displayDateTimePattern);

  // ===========================================================================
  // FORMATTING METHODS
  // ===========================================================================

  /// Format date to full datetime string (yyyy-MM-dd HH:mm:ss)
  static String formatFullDateTime(DateTime dateTime) {
    return _fullDateTimeFormatter.format(dateTime);
  }

  /// Format date to date only string (yyyy-MM-dd)
  static String formatDateOnly(DateTime dateTime) {
    return _dateOnlyFormatter.format(dateTime);
  }

  /// Format time only string (HH:mm:ss)
  static String formatTimeOnly(DateTime dateTime) {
    return _timeOnlyFormatter.format(dateTime);
  }

  /// Format date for display (MMM dd, yyyy)
  static String formatDisplayDate(DateTime dateTime) {
    return _displayDateFormatter.format(dateTime);
  }

  /// Format time for display (hh:mm a)
  static String formatDisplayTime(DateTime dateTime) {
    return _displayTimeFormatter.format(dateTime);
  }

  /// Format datetime for display (MMM dd, yyyy 'at' hh:mm a)
  static String formatDisplayDateTime(DateTime dateTime) {
    return _displayDateTimeFormatter.format(dateTime);
  }

  /// Format relative time (e.g., "2 hours ago", "yesterday", etc.)
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks week${weeks == 1 ? '' : 's'} ago';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'just now';
    }
  }

  /// Format time ago for social media style (e.g., "2h", "3d", "1w")
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo';
    } else if (difference.inDays > 6) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  /// Format date for chat messages
  static String formatChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Today - show time only
      return formatDisplayTime(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      // This week - show day name
      return DateFormat('EEEE').format(dateTime);
    } else {
      // Older - show date
      return formatDisplayDate(dateTime);
    }
  }

  /// Format date for post timestamps
  static String formatPostTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time
      return formatDisplayTime(dateTime);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday at ${formatDisplayTime(dateTime)}';
    } else if (difference.inDays < 7) {
      // This week - show day and time
      return '${DateFormat('EEEE').format(dateTime)} at ${formatDisplayTime(dateTime)}';
    } else {
      // Older - show full date and time
      return formatDisplayDateTime(dateTime);
    }
  }

  // ===========================================================================
  // PARSING METHODS
  // ===========================================================================

  /// Parse string to DateTime
  static DateTime? parseDateTime(String dateString) {
    try {
      return _fullDateTimeFormatter.parse(dateString);
    } catch (e) {
      try {
        return _dateOnlyFormatter.parse(dateString);
      } catch (e) {
        try {
          return DateTime.parse(dateString);
        } catch (e) {
          return null;
        }
      }
    }
  }

  /// Parse ISO 8601 string
  static DateTime? parseIsoString(String isoString) {
    try {
      return DateTime.parse(isoString);
    } catch (e) {
      return null;
    }
  }

  /// Parse timestamp (milliseconds since epoch)
  static DateTime? parseTimestamp(int timestamp) {
    try {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      return null;
    }
  }

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Check if date is today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
           dateTime.month == now.month &&
           dateTime.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
           dateTime.month == yesterday.month &&
           dateTime.day == yesterday.day;
  }

  /// Check if date is this week
  static bool isThisWeek(DateTime dateTime) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return dateTime.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           dateTime.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if date is this month
  static bool isThisMonth(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year && dateTime.month == now.month;
  }

  /// Check if date is this year
  static bool isThisYear(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year;
  }

  /// Get start of day
  static DateTime startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);
  }

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime dateTime) {
    final daysToSubtract = dateTime.weekday - 1;
    return dateTime.subtract(Duration(days: daysToSubtract));
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, 1);
  }

  /// Get start of year
  static DateTime startOfYear(DateTime dateTime) {
    return DateTime(dateTime.year, 1, 1);
  }

  // ===========================================================================
  // CUSTOM FORMATS
  // ===========================================================================

  /// Format date for API requests
  static String formatForApi(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Format date for file names
  static String formatForFileName(DateTime dateTime) {
    return DateFormat('yyyyMMdd_HHmmss').format(dateTime);
  }

  /// Format date for logs
  static String formatForLogs(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(dateTime);
  }

  /// Format duration
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h ${duration.inMinutes % 60}m';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m ${duration.inSeconds % 60}s';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}
