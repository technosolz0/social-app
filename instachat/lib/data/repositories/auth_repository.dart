import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/firebase_service.dart';

class AuthRepository {
  final ApiService _apiService;
  final LocalStorageService _localStorage;

  AuthRepository({ApiService? apiService, LocalStorageService? localStorage})
    : _apiService = apiService ?? ApiService(),
      _localStorage = localStorage ?? LocalStorageService();

  // Public getter for local storage (needed for auth provider)
  LocalStorageService get localStorage => _localStorage;

  // ===========================================================================
  // AUTHENTICATION METHODS
  // ===========================================================================

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      // Get FCM token if available
      String? deviceToken;
      try {
        // Import FirebaseService dynamically to avoid initialization issues
        final firebaseService = await _getFirebaseService();
        deviceToken = await firebaseService?.getToken();
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Could not get FCM token for login: $e');
        }
      }

      final loginData = {
        'identifier': identifier,
        'password': password,
        if (deviceToken != null) 'device_token': deviceToken,
        if (deviceToken != null) 'device_type': 'android',
        if (deviceToken != null) 'device_id': deviceToken.substring(0, deviceToken.length > 50 ? 50 : deviceToken.length),
      };

      final response = await _apiService.customRequest(
        method: 'POST',
        path: '/users/login/',
        data: loginData,
      );

      // Extract tokens
      final accessToken = response.data['access'] as String?;
      final refreshToken = response.data['refresh'] as String?;

      if (accessToken != null) {
        // Save tokens securely
        await _localStorage.saveAuthToken(accessToken);
        if (refreshToken != null) {
          await _localStorage.saveRefreshToken(refreshToken);
        }

        // Save user credentials for automatic re-login
        await _localStorage.saveUserCredentials(identifier, password);

        // Set token in API service
        _apiService.setAuthToken(accessToken);
      }

      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Login failed: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String identifier,
    required String password,
  }) async {
    try {
      // Get FCM token if available
      String? deviceToken;
      try {
        final firebaseService = _getFirebaseService();
        deviceToken = await firebaseService?.getToken();
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Could not get FCM token for registration: $e');
        }
      }

      final registerData = {
        'identifier': identifier,
        'password': password,
        if (deviceToken != null) 'device_token': deviceToken,
        if (deviceToken != null) 'device_type': 'android',
        if (deviceToken != null) 'device_id': deviceToken.substring(0, deviceToken.length > 50 ? 50 : deviceToken.length),
      };

      final response = await _apiService.customRequest(
        method: 'POST',
        path: '/users/',
        data: registerData,
      );

      // Extract tokens
      final accessToken = response.data['access'] as String?;
      final refreshToken = response.data['refresh'] as String?;

      if (accessToken != null) {
        // Save tokens securely
        await _localStorage.saveAuthToken(accessToken);
        if (refreshToken != null) {
          await _localStorage.saveRefreshToken(refreshToken);
        }

        // Set token in API service
        _apiService.setAuthToken(accessToken);

        // Save user credentials for automatic re-login
        await _localStorage.saveUserCredentials(identifier, password);
      }

      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Registration failed: $e');
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // Call logout endpoint (optional)
      try {
        await _apiService.customRequest(method: 'POST', path: '/auth/logout/');
      } catch (e) {
        // Ignore logout endpoint errors
      }

      // Clear local tokens
      await _localStorage.clearSecureData();
      _apiService.clearAuthToken();

      if (kDebugMode) {
        print('✅ Logged out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Logout failed: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _apiService.refreshToken(refreshToken);

      final newAccessToken = response['access'] as String?;
      if (newAccessToken != null) {
        await _localStorage.saveAuthToken(newAccessToken);
        _apiService.setAuthToken(newAccessToken);
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Token refresh failed: $e');
      }
      rethrow;
    }
  }

  // ===========================================================================
  // USER PROFILE METHODS
  // ===========================================================================

  Future<UserModel> getCurrentUser() async {
    try {
      return await _apiService.getCurrentUser();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get current user: $e');
      }
      rethrow;
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> profileData) async {
    try {
      // Try PATCH first (for partial updates)
      try {
        if (kDebugMode) {
          print('🔄 Trying PATCH method for profile update');
        }
        final response = await _apiService.customRequest(
          method: 'PATCH',
          path: '/users/me/',
          data: profileData,
        );
        if (kDebugMode) {
          print('✅ PATCH method successful');
        }
        return UserModel.fromJson(response.data);
      } catch (e) {
        // If PATCH fails with 405 (Method Not Allowed), try PUT
        if (e.toString().contains('405') || e.toString().contains('Method Not Allowed')) {
          if (kDebugMode) {
            print('🔄 PATCH not allowed, trying PUT method');
          }
          final response = await _apiService.customRequest(
            method: 'PUT',
            path: '/users/me/',
            data: profileData,
          );
          if (kDebugMode) {
            print('✅ PUT method successful');
          }
          return UserModel.fromJson(response.data);
        } else {
          // Re-throw if it's not a 405 error
          rethrow;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to update profile: $e');
      }
      rethrow;
    }
  }

  // ===========================================================================
  // TOKEN MANAGEMENT
  // ===========================================================================

  Future<String?> getAccessToken() async {
    return await _localStorage.getAuthToken();
  }

  Future<String?> getRefreshToken() async {
    return await _localStorage.getRefreshToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> hasValidToken() async {
    try {
      final token = await getAccessToken();
      if (token == null) return false;

      // Set token and try to get current user to validate
      _apiService.setAuthToken(token);
      await getCurrentUser();
      return true;
    } catch (e) {
      // Token is invalid, try refresh
      try {
        final refreshTokenValue = await getRefreshToken();
        if (refreshTokenValue != null) {
          final refreshResponse = await this.refreshToken(refreshTokenValue);
          final newToken = refreshResponse['access'] as String?;
          if (newToken != null) {
            _apiService.setAuthToken(newToken);
            return true;
          }
        }
      } catch (e) {
        // Refresh also failed
      }
      return false;
    }
  }

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  void initializeWithToken(String token) {
    _apiService.setAuthToken(token);
  }

  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      return await _apiService.requestPasswordReset(email);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Password reset request failed: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> confirmPasswordReset(
    String uid,
    String token,
    String newPassword,
  ) async {
    try {
      return await _apiService.confirmPasswordReset(uid, token, newPassword);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Password reset confirmation failed: $e');
      }
      rethrow;
    }
  }

  Future<void> clearStoredTokens() async {
    await _localStorage.clearSecureData();
    _apiService.clearAuthToken();
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  FirebaseService? _getFirebaseService() {
    try {
      return FirebaseService();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Could not get FirebaseService: $e');
      }
      return null;
    }
  }
}
