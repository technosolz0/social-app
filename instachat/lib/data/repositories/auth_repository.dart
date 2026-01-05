import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class AuthRepository {
  final ApiService _apiService;
  final LocalStorageService _localStorage;

  AuthRepository({
    ApiService? apiService,
    LocalStorageService? localStorage,
  }) :
    _apiService = apiService ?? ApiService(),
    _localStorage = localStorage ?? LocalStorageService();

  // Public getter for local storage (needed for auth provider)
  LocalStorageService get localStorage => _localStorage;

  // ===========================================================================
  // AUTHENTICATION METHODS
  // ===========================================================================

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await _apiService.login(identifier, password);

      // Extract tokens
      final accessToken = response['access'] as String?;
      final refreshToken = response['refresh'] as String?;

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

      return response;
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
      final response = await _apiService.register(
        identifier: identifier,
        password: password,
      );

      // Extract tokens
      final accessToken = response['access'] as String?;
      final refreshToken = response['refresh'] as String?;

      if (accessToken != null) {
        // Save tokens securely
        await _localStorage.saveAuthToken(accessToken);
        if (refreshToken != null) {
          await _localStorage.saveRefreshToken(refreshToken);
        }

        // Set token in API service
        _apiService.setAuthToken(accessToken);
      }

      return response;
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
        await _apiService.customRequest(
          method: 'POST',
          path: '/auth/logout/',
        );
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
      final response = await _apiService.customRequest(
        method: 'PATCH',
        path: '/users/me/profile/',
        data: profileData,
      );
      return UserModel.fromJson(response.data);
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

  Future<void> clearStoredTokens() async {
    await _localStorage.clearSecureData();
    _apiService.clearAuthToken();
  }
}
