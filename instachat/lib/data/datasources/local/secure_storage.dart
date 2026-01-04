import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ============================================
// lib/data/datasources/local/secure_storage.dart
// 🔐 SECURE STORAGE FOR SENSITIVE DATA
// ============================================

class SecureStorage {
  static const SecureStorage _instance = SecureStorage._internal();
  const SecureStorage._internal();
  factory SecureStorage() => _instance;

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // ===========================================================================
  // AUTHENTICATION KEYS
  // ===========================================================================

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _isLoggedInKey = 'is_logged_in';

  // ===========================================================================
  // AUTHENTICATION METHODS
  // ===========================================================================

  /// Save access token securely
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Save refresh token securely
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Save user email
  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
  }

  /// Get user email
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  /// Set login status
  Future<void> setLoggedIn(bool isLoggedIn) async {
    await _storage.write(key: _isLoggedInKey, value: isLoggedIn.toString());
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final value = await _storage.read(key: _isLoggedInKey);
    return value == 'true';
  }

  /// Save complete auth data
  Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String userEmail,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
      saveUserId(userId),
      saveUserEmail(userEmail),
      setLoggedIn(true),
    ]);
  }

  // ===========================================================================
  // DEVICE & APP DATA
  // ===========================================================================

  static const String _deviceIdKey = 'device_id';
  static const String _fcmTokenKey = 'fcm_token';
  static const String _appVersionKey = 'app_version';
  static const String _firstLaunchKey = 'first_launch';

  /// Save device ID
  Future<void> saveDeviceId(String deviceId) async {
    await _storage.write(key: _deviceIdKey, value: deviceId);
  }

  /// Get device ID
  Future<String?> getDeviceId() async {
    return await _storage.read(key: _deviceIdKey);
  }

  /// Save FCM token for push notifications
  Future<void> saveFcmToken(String token) async {
    await _storage.write(key: _fcmTokenKey, value: token);
  }

  /// Get FCM token
  Future<String?> getFcmToken() async {
    return await _storage.read(key: _fcmTokenKey);
  }

  /// Save app version
  Future<void> saveAppVersion(String version) async {
    await _storage.write(key: _appVersionKey, value: version);
  }

  /// Get app version
  Future<String?> getAppVersion() async {
    return await _storage.read(key: _appVersionKey);
  }

  /// Check if it's first launch
  Future<bool> isFirstLaunch() async {
    final value = await _storage.read(key: _firstLaunchKey);
    return value == null;
  }

  /// Mark first launch as complete
  Future<void> completeFirstLaunch() async {
    await _storage.write(key: _firstLaunchKey, value: 'false');
  }

  // ===========================================================================
  // USER PREFERENCES
  // ===========================================================================

  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _biometricEnabledKey = 'biometric_enabled';

  /// Save theme preference
  Future<void> saveThemeMode(String themeMode) async {
    await _storage.write(key: _themeKey, value: themeMode);
  }

  /// Get theme preference
  Future<String?> getThemeMode() async {
    return await _storage.read(key: _themeKey);
  }

  /// Save language preference
  Future<void> saveLanguage(String language) async {
    await _storage.write(key: _languageKey, value: language);
  }

  /// Get language preference
  Future<String?> getLanguage() async {
    return await _storage.read(key: _languageKey);
  }

  /// Save notification preference
  Future<void> saveNotificationsEnabled(bool enabled) async {
    await _storage.write(key: _notificationsEnabledKey, value: enabled.toString());
  }

  /// Get notification preference
  Future<bool> getNotificationsEnabled() async {
    final value = await _storage.read(key: _notificationsEnabledKey);
    return value != 'false'; // Default to true
  }

  /// Save biometric authentication preference
  Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  /// Get biometric authentication preference
  Future<bool> getBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  // ===========================================================================
  // SENSITIVE USER DATA
  // ===========================================================================

  static const String _savedPaymentMethodsKey = 'saved_payment_methods';
  static const String _apiKeysKey = 'api_keys';

  /// Save encrypted payment methods (should be encrypted before calling)
  Future<void> savePaymentMethods(String encryptedData) async {
    await _storage.write(key: _savedPaymentMethodsKey, value: encryptedData);
  }

  /// Get encrypted payment methods
  Future<String?> getPaymentMethods() async {
    return await _storage.read(key: _savedPaymentMethodsKey);
  }

  /// Save API keys (should be encrypted)
  Future<void> saveApiKeys(String encryptedKeys) async {
    await _storage.write(key: _apiKeysKey, value: encryptedKeys);
  }

  /// Get API keys
  Future<String?> getApiKeys() async {
    return await _storage.read(key: _apiKeysKey);
  }

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Clear all stored data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Clear authentication data only
  Future<void> clearAuthData() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _userEmailKey),
      _storage.delete(key: _isLoggedInKey),
    ]);
  }

  /// Delete specific key
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  /// Get all keys (for debugging)
  Future<Map<String, String>> getAllKeys() async {
    final allData = await _storage.readAll();
    return Map<String, String>.from(allData);
  }
}
