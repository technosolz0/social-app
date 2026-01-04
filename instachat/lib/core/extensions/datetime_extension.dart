import '../utils/date_formatter.dart';

// ============================================
// lib/core/extensions/datetime_extension.dart
// 📅 DATETIME EXTENSIONS FOR EASY FORMATTING
// ============================================

extension DateTimeExtension on DateTime {
  // ===========================================================================
  // FORMATTING SHORTCUTS
  // ===========================================================================

  /// Format to full datetime string
  String get toFullDateTime => DateFormatter.formatFullDateTime(this);

  /// Format to date only string
  String get toDateOnly => DateFormatter.formatDateOnly(this);

  /// Format to time only string
  String get toTimeOnly => DateFormatter.formatTimeOnly(this);

  /// Format to display date
  String get toDisplayDate => DateFormatter.formatDisplayDate(this);

  /// Format to display time
  String get toDisplayTime => DateFormatter.formatDisplayTime(this);

  /// Format to display datetime
  String get toDisplayDateTime => DateFormatter.formatDisplayDateTime(this);

  /// Format to relative time (e.g., "2 hours ago")
  String get toRelativeTime => DateFormatter.formatRelativeTime(this);

  /// Format to time ago (e.g., "2h", "3d")
  String get toTimeAgo => DateFormatter.formatTimeAgo(this);

  /// Format for chat messages
  String get toChatTime => DateFormatter.formatChatTime(this);

  /// Format for post timestamps
  String get toPostTime => DateFormatter.formatPostTime(this);

  /// Format for API requests
  String get toApiFormat => DateFormatter.formatForApi(this);

  /// Format for file names
  String get toFileName => DateFormatter.formatForFileName(this);

  /// Format for logs
  String get toLogFormat => DateFormatter.formatForLogs(this);

  // ===========================================================================
  // DATE CHECKS
  // ===========================================================================

  /// Check if date is today
  bool get isToday => DateFormatter.isToday(this);

  /// Check if date is yesterday
  bool get isYesterday => DateFormatter.isYesterday(this);

  /// Check if date is this week
  bool get isThisWeek => DateFormatter.isThisWeek(this);

  /// Check if date is this month
  bool get isThisMonth => DateFormatter.isThisMonth(this);

  /// Check if date is this year
  bool get isThisYear => DateFormatter.isThisYear(this);

  // ===========================================================================
  // DATE MANIPULATION
  // ===========================================================================

  /// Get start of day
  DateTime get startOfDay => DateFormatter.startOfDay(this);

  /// Get end of day
  DateTime get endOfDay => DateFormatter.endOfDay(this);

  /// Get start of week (Monday)
  DateTime get startOfWeek => DateFormatter.startOfWeek(this);

  /// Get start of month
  DateTime get startOfMonth => DateFormatter.startOfMonth(this);

  /// Get start of year
  DateTime get startOfYear => DateFormatter.startOfYear(this);

  /// Add days
  DateTime addDays(int days) => add(Duration(days: days));

  /// Subtract days
  DateTime subtractDays(int days) => subtract(Duration(days: days));

  /// Add weeks
  DateTime addWeeks(int weeks) => add(Duration(days: weeks * 7));

  /// Subtract weeks
  DateTime subtractWeeks(int weeks) => subtract(Duration(days: weeks * 7));

  /// Add months (approximate)
  DateTime addMonths(int months) {
    final newMonth = month + months;
    final newYear = year + (newMonth - 1) ~/ 12;
    final adjustedMonth = (newMonth - 1) % 12 + 1;

    // Handle last day of month
    final lastDayOfNewMonth = DateTime(newYear, adjustedMonth + 1, 0).day;
    final newDay = day > lastDayOfNewMonth ? lastDayOfNewMonth : day;

    return DateTime(newYear, adjustedMonth, newDay, hour, minute, second, millisecond, microsecond);
  }

  /// Subtract months (approximate)
  DateTime subtractMonths(int months) => addMonths(-months);

  /// Add years
  DateTime addYears(int years) => DateTime(
        year + years,
        month,
        day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      );

  /// Subtract years
  DateTime subtractYears(int years) => addYears(-years);

  // ===========================================================================
  // COMPARISON HELPERS
  // ===========================================================================

  /// Check if date is before another date
  bool isBeforeDate(DateTime other) => isBefore(other);

  /// Check if date is after another date
  bool isAfterDate(DateTime other) => isAfter(other);

  /// Check if date is same day as another date
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Check if date is same week as another date
  bool isSameWeek(DateTime other) {
    final startOfThisWeek = startOfWeek;
    final startOfOtherWeek = other.startOfWeek;
    return startOfThisWeek.isSameDay(startOfOtherWeek);
  }

  /// Check if date is same month as another date
  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  /// Check if date is same year as another date
  bool isSameYear(DateTime other) {
    return year == other.year;
  }

  /// Get difference in days
  int get daysDifference {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }

  /// Get difference in hours
  int get hoursDifference {
    final now = DateTime.now();
    return now.difference(this).inHours;
  }

  /// Get difference in minutes
  int get minutesDifference {
    final now = DateTime.now();
    return now.difference(this).inMinutes;
  }

  /// Get difference in seconds
  int get secondsDifference {
    final now = DateTime.now();
    return now.difference(this).inSeconds;
  }

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Get weekday name
  String get weekdayName {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[weekday - 1];
  }

  /// Get month name
  String get monthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  /// Get short month name
  String get shortMonthName {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  /// Check if it's a weekend
  bool get isWeekend => weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Check if it's a weekday
  bool get isWeekday => !isWeekend;

  /// Get age from birth date
  int get age {
    final now = DateTime.now();
    int age = now.year - year;

    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }

    return age;
  }

  /// Convert to timestamp (milliseconds since epoch)
  int get timestamp => millisecondsSinceEpoch;

  /// Create from timestamp
  static DateTime fromTimestamp(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Get copy with specific time
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }

  /// Get next occurrence of specific weekday
  DateTime nextWeekday(int weekday) {
    final daysUntil = (weekday - this.weekday + 7) % 7;
    return daysUntil == 0 ? addDays(7) : addDays(daysUntil);
  }

  /// Get previous occurrence of specific weekday
  DateTime previousWeekday(int weekday) {
    final daysSince = (this.weekday - weekday + 7) % 7;
    return daysSince == 0 ? subtractDays(7) : subtractDays(daysSince);
  }
}
