// ============================================
// lib/core/extensions/string_extension.dart
// 🔤 STRING EXTENSIONS FOR TEXT MANIPULATION
// ============================================

import 'dart:convert';

extension StringExtension on String {
  // ===========================================================================
  // CASE CONVERSIONS
  // ===========================================================================

  /// Convert to title case (first letter of each word capitalized)
  String get toTitleCase {
    if (isEmpty) return this;

    return split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : word)
        .join(' ');
  }

  /// Convert to sentence case (first letter capitalized, rest lowercase)
  String get toSentenceCase {
    if (isEmpty) return this;

    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Convert to camel case
  String get toCamelCase {
    if (isEmpty) return this;

    final words = split(RegExp(r'[_\s]+'));
    if (words.isEmpty) return this;

    return words[0].toLowerCase() +
        words.skip(1).map((word) => word.toTitleCaseWord).join('');
  }

  /// Convert to pascal case
  String get toPascalCase {
    if (isEmpty) return this;

    return split(RegExp(r'[_\s]+'))
        .map((word) => word.toTitleCaseWord)
        .join('');
  }

  /// Convert to snake case
  String get toSnakeCase {
    if (isEmpty) return this;

    return replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)}_${match.group(2)}',
    ).toLowerCase();
  }

  /// Convert to kebab case
  String get toKebabCase {
    if (isEmpty) return this;

    return replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)}-${match.group(2)}',
    ).toLowerCase();
  }

  /// Helper for title case word
  String get toTitleCaseWord {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  // ===========================================================================
  // VALIDATION CHECKS
  // ===========================================================================

  /// Check if string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(this);
  }

  /// Check if string is a valid URL
  bool get isValidUrl {
    final urlRegex = RegExp(
      r'^https?://(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    return urlRegex.hasMatch(this);
  }

  /// Check if string is a valid phone number
  bool get isValidPhoneNumber {
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(replaceAll(RegExp(r'[^\d+]'), ''));
  }

  /// Check if string contains only digits
  bool get isNumeric => RegExp(r'^\d+$').hasMatch(this);

  /// Check if string contains only letters
  bool get isAlphabetic => RegExp(r'^[a-zA-Z]+$').hasMatch(this);

  /// Check if string contains only letters and numbers
  bool get isAlphanumeric => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);

  /// Check if string is a valid username
  bool get isValidUsername => RegExp(r'^[a-zA-Z0-9_]{3,30}$').hasMatch(this) &&
                              !['admin', 'root', 'system', 'null', 'undefined']
                                  .contains(toLowerCase());

  // ===========================================================================
  // TEXT MANIPULATION
  // ===========================================================================

  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize first letter of each word
  String get capitalizeWords => toTitleCase;

  /// Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Remove extra whitespace (multiple spaces become single space)
  String get normalizeWhitespace => replaceAll(RegExp(r'\s+'), ' ').trim();

  /// Reverse the string
  String get reverse {
    final runes = this.runes.toList().reversed;
    return String.fromCharCodes(runes);
  }

  /// Extract numbers from string
  String get extractNumbers => replaceAll(RegExp(r'[^0-9]'), '');

  /// Extract letters from string
  String get extractLetters => replaceAll(RegExp(r'[^a-zA-Z]'), '');

  /// Remove special characters
  String get removeSpecialChars => replaceAll(RegExp(r'[^\w\s]'), '');

  /// Remove emojis
  String get removeEmojis => replaceAll(
        RegExp(r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]'),
        '',
      );

  // ===========================================================================
  // FORMATTING
  // ===========================================================================

  /// Add ellipsis if longer than maxLength
  String ellipsis(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Format as phone number
  String get formatAsPhoneNumber {
    final digits = extractNumbers;
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (digits.length == 11 && digits.startsWith('1')) {
      final clean = digits.substring(1);
      return '(${clean.substring(0, 3)}) ${clean.substring(3, 6)}-${clean.substring(6)}';
    }
    return this;
  }

  /// Format as credit card number
  String get formatAsCreditCard {
    final digits = extractNumbers;
    if (digits.length == 16) {
      return '${digits.substring(0, 4)} ${digits.substring(4, 8)} ${digits.substring(8, 12)} ${digits.substring(12)}';
    }
    return this;
  }

  /// Format file size (bytes to human readable)
  String get formatFileSize {
    final bytes = int.tryParse(this);
    if (bytes == null) return this;

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = bytes.toDouble();
    var suffixIndex = 0;

    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }

    return '${size.toStringAsFixed(size < 10 ? 1 : 0)} ${suffixes[suffixIndex]}';
  }

  // ===========================================================================
  // PARSING
  // ===========================================================================

  /// Parse to int safely
  int? get toIntSafe => int.tryParse(this);

  /// Parse to double safely
  double? get toDoubleSafe => double.tryParse(this);

  /// Parse to bool safely
  bool? get toBoolSafe {
    final lower = toLowerCase();
    if (lower == 'true' || lower == '1' || lower == 'yes') return true;
    if (lower == 'false' || lower == '0' || lower == 'no') return false;
    return null;
  }

  /// Parse JSON safely
  dynamic get parseJsonSafe {
    try {
      return jsonDecode(this);
    } catch (e) {
      return null;
    }
  }

  // ===========================================================================
  // ENCODING/DECODING
  // ===========================================================================

  /// URL encode
  String get urlEncode => Uri.encodeComponent(this);

  /// URL decode
  String get urlDecode => Uri.decodeComponent(this);

  /// Base64 encode
  String get toBase64 => base64Encode(utf8.encode(this));

  /// Base64 decode
  String get fromBase64 {
    try {
      return utf8.decode(base64Decode(this));
    } catch (e) {
      return this;
    }
  }

  // ===========================================================================
  // SEARCH AND REPLACE
  // ===========================================================================

  /// Replace first occurrence (case insensitive)
  String replaceFirstIgnoreCase(String from, String to) {
    final lowerThis = toLowerCase();
    final lowerFrom = from.toLowerCase();
    final index = lowerThis.indexOf(lowerFrom);

    if (index == -1) return this;

    return substring(0, index) + to + substring(index + from.length);
  }

  /// Replace all occurrences (case insensitive)
  String replaceAllIgnoreCase(String from, String to) {
    final lowerThis = toLowerCase();
    final lowerFrom = from.toLowerCase();
    final buffer = StringBuffer();
    var start = 0;

    for (var i = 0; i < lowerThis.length; i++) {
      if (lowerThis.startsWith(lowerFrom, i)) {
        buffer.write(substring(start, i));
        buffer.write(to);
        start = i + from.length;
        i = start - 1;
      }
    }

    buffer.write(substring(start));
    return buffer.toString();
  }

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Check if string is null or empty
  bool get isNullOrEmpty => this == null || isEmpty;

  /// Check if string is null or whitespace
  bool get isNullOrWhiteSpace => this == null || trim().isEmpty;

  /// Get word count
  int get wordCount => trim().isEmpty ? 0 : split(RegExp(r'\s+')).length;

  /// Get character count (excluding whitespace)
  int get charCount => replaceAll(RegExp(r'\s+'), '').length;

  /// Get line count
  int get lineCount => split('\n').length;

  /// Check if string starts with any of the given prefixes
  bool startsWithAny(List<String> prefixes) {
    return prefixes.any((prefix) => startsWith(prefix));
  }

  /// Check if string ends with any of the given suffixes
  bool endsWithAny(List<String> suffixes) {
    return suffixes.any((suffix) => endsWith(suffix));
  }

  /// Check if string contains any of the given substrings
  bool containsAny(List<String> substrings) {
    return substrings.any((substring) => contains(substring));
  }

  /// Split by length
  List<String> splitByLength(int length) {
    final chunks = <String>[];
    for (var i = 0; i < length; i += length) {
      final end = (i + length < this.length) ? i + length : this.length;
      chunks.add(substring(i, end));
    }
    return chunks;
  }

  /// Get initials from name
  String get initials {
    final words = trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';

    final firstInitial = words[0].isNotEmpty ? words[0][0].toUpperCase() : '';
    final lastInitial = words.length > 1 && words[1].isNotEmpty
        ? words[1][0].toUpperCase()
        : '';

    return '$firstInitial$lastInitial';
  }

  /// Mask sensitive information
  String mask({int visibleStart = 0, int visibleEnd = 0, String maskChar = '*'}) {
    if (length <= visibleStart + visibleEnd) return this;

    final start = substring(0, visibleStart);
    final end = substring(length - visibleEnd);
    final maskLength = length - visibleStart - visibleEnd;
    final mask = maskChar * maskLength;

    return '$start$mask$end';
  }

  /// Check if string is a palindrome
  bool get isPalindrome {
    final clean = toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return clean == clean.reverse;
  }
}

// ===========================================================================
// IMPORTS (Add these at the top of the file)
// ===========================================================================

// import 'dart:convert';
// import 'dart:convert' show base64Decode, base64Encode, jsonDecode, utf8;
