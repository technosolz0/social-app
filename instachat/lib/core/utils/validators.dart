// ============================================
// lib/core/utils/validators.dart
// ✅ INPUT VALIDATION UTILITIES
// ============================================

class Validators {
  static const Validators _instance = Validators._internal();
  const Validators._internal();
  factory Validators() => _instance;

  // ===========================================================================
  // EMAIL VALIDATION
  // ===========================================================================

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    if (value.length > 254) {
      return 'Email is too long';
    }

    if (!_emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null; // Valid
  }

  /// Check if email is valid (returns bool)
  static bool isValidEmail(String email) {
    return validateEmail(email) == null;
  }

  // ===========================================================================
  // PASSWORD VALIDATION
  // ===========================================================================

  /// Validate password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (value.length > 128) {
      return 'Password is too long';
    }

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    return null; // Valid
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null; // Valid
  }

  /// Check password strength (returns score 0-4)
  static int getPasswordStrength(String password) {
    int score = 0;

    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    return score.clamp(0, 4);
  }

  /// Get password strength description
  static String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return 'Unknown';
    }
  }

  // ===========================================================================
  // USERNAME VALIDATION
  // ===========================================================================

  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,30}$');

  /// Validate username
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }

    if (value.length > 30) {
      return 'Username must be less than 30 characters';
    }

    if (!_usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    // Check for reserved words
    final reservedWords = ['admin', 'root', 'system', 'null', 'undefined'];
    if (reservedWords.contains(value.toLowerCase())) {
      return 'This username is not allowed';
    }

    return null; // Valid
  }

  /// Check if username is valid (returns bool)
  static bool isValidUsername(String username) {
    return validateUsername(username) == null;
  }

  // ===========================================================================
  // NAME VALIDATION
  // ===========================================================================

  static final RegExp _nameRegex = RegExp(r"^[a-zA-Z\s\-']{2,50}$");

  /// Validate name (first name, last name, display name)
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < 2) {
      return '$fieldName must be at least 2 characters long';
    }

    if (value.length > 50) {
      return '$fieldName must be less than 50 characters';
    }

    if (!_nameRegex.hasMatch(value)) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null; // Valid
  }

  /// Validate full name
  static String? validateFullName(String? firstName, String? lastName) {
    final firstNameError = validateName(firstName, fieldName: 'First name');
    if (firstNameError != null) return firstNameError;

    final lastNameError = validateName(lastName, fieldName: 'Last name');
    if (lastNameError != null) return lastNameError;

    return null; // Valid
  }

  // ===========================================================================
  // PHONE NUMBER VALIDATION
  // ===========================================================================

  static final RegExp _phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');

  /// Validate phone number (E.164 format)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters except +
    final cleanNumber = value.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleanNumber.length < 10) {
      return 'Phone number is too short';
    }

    if (cleanNumber.length > 15) {
      return 'Phone number is too long';
    }

    if (!_phoneRegex.hasMatch(cleanNumber)) {
      return 'Please enter a valid phone number';
    }

    return null; // Valid
  }

  /// Check if phone number is valid (returns bool)
  static bool isValidPhoneNumber(String phoneNumber) {
    return validatePhoneNumber(phoneNumber) == null;
  }

  // ===========================================================================
  // URL VALIDATION
  // ===========================================================================

  static final RegExp _urlRegex = RegExp(
    r'^https?://(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  /// Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URLs are often optional
    }

    if (value.length > 2048) {
      return 'URL is too long';
    }

    if (!_urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null; // Valid
  }

  /// Check if URL is valid (returns bool)
  static bool isValidUrl(String url) {
    return validateUrl(url) == null;
  }

  // ===========================================================================
  // BIO/DESCRIPTION VALIDATION
  // ===========================================================================

  /// Validate bio or description text
  static String? validateBio(String? value, {int maxLength = 150}) {
    if (value == null || value.isEmpty) {
      return null; // Bio is often optional
    }

    if (value.length > maxLength) {
      return 'Bio must be less than $maxLength characters';
    }

    // Check for excessive special characters (simplified)
    final specialCharCount = RegExp(r'[!@#$%^&*]').allMatches(value).length;
    if (specialCharCount > value.length * 0.3) {
      return 'Bio contains too many special characters';
    }

    return null; // Valid
  }

  // ===========================================================================
  // POST/CONTENT VALIDATION
  // ===========================================================================

  /// Validate post caption
  static String? validatePostCaption(String? value, {int maxLength = 2200}) {
    if (value == null || value.isEmpty) {
      return null; // Caption is optional
    }

    if (value.length > maxLength) {
      return 'Caption must be less than $maxLength characters';
    }

    return null; // Valid
  }

  /// Validate comment text
  static String? validateComment(String? value, {int maxLength = 1000}) {
    if (value == null || value.isEmpty) {
      return 'Comment cannot be empty';
    }

    if (value.trim().isEmpty) {
      return 'Comment cannot be only whitespace';
    }

    if (value.length > maxLength) {
      return 'Comment must be less than $maxLength characters';
    }

    return null; // Valid
  }

  // ===========================================================================
  // SEARCH VALIDATION
  // ===========================================================================

  /// Validate search query
  static String? validateSearchQuery(String? value) {
    if (value == null || value.isEmpty) {
      return 'Search query cannot be empty';
    }

    if (value.trim().isEmpty) {
      return 'Search query cannot be only whitespace';
    }

    if (value.length < 2) {
      return 'Search query must be at least 2 characters';
    }

    if (value.length > 100) {
      return 'Search query is too long';
    }

    return null; // Valid
  }

  // ===========================================================================
  // FILE/IMAGE VALIDATION
  // ===========================================================================

  static const List<String> _allowedImageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> _allowedVideoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'webm'];
  static const int _maxFileSizeBytes = 50 * 1024 * 1024; // 50MB

  /// Validate image file
  static String? validateImageFile(String fileName, int fileSize) {
    final extension = fileName.split('.').last.toLowerCase();

    if (!_allowedImageExtensions.contains(extension)) {
      return 'Invalid image format. Allowed: ${_allowedImageExtensions.join(', ')}';
    }

    if (fileSize > _maxFileSizeBytes) {
      return 'Image file is too large. Maximum size: 50MB';
    }

    return null; // Valid
  }

  /// Validate video file
  static String? validateVideoFile(String fileName, int fileSize) {
    final extension = fileName.split('.').last.toLowerCase();

    if (!_allowedVideoExtensions.contains(extension)) {
      return 'Invalid video format. Allowed: ${_allowedVideoExtensions.join(', ')}';
    }

    if (fileSize > _maxFileSizeBytes) {
      return 'Video file is too large. Maximum size: 50MB';
    }

    return null; // Valid
  }

  /// Validate file size
  static String? validateFileSize(int fileSize, {int maxSizeBytes = _maxFileSizeBytes}) {
    if (fileSize > maxSizeBytes) {
      final maxSizeMB = (maxSizeBytes / (1024 * 1024)).round();
      return 'File is too large. Maximum size: ${maxSizeMB}MB';
    }

    return null; // Valid
  }

  // ===========================================================================
  // GENERAL UTILITIES
  // ===========================================================================

  /// Check if string is not null and not empty
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Check if string length is within range
  static bool isLengthValid(String? value, {int min = 0, int? max}) {
    if (value == null) return min == 0;

    if (value.length < min) return false;
    if (max != null && value.length > max) return false;

    return true;
  }

  /// Sanitize input (remove potentially harmful characters)
  static String sanitizeInput(String input) {
    // Remove null bytes and other control characters
    return input.replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
  }

  /// Check if input contains only allowed characters
  static bool containsOnlyAllowedChars(String input, RegExp allowedPattern) {
    return allowedPattern.hasMatch(input);
  }
}
