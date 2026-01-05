import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/local_storage_service.dart';
import 'activity_tracker_provider.dart';

part 'auth_provider.g.dart';

// 📌 STATE: What data we're managing
class AuthState {
  final UserModel? user; // Current logged-in user
  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// 📌 NOTIFIER: Logic that changes the state
// Think of this as the "brain" that controls auth
@riverpod
class AuthNotifier extends _$AuthNotifier {
  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  // Initial state when app starts
  @override
  AuthState build() {
    // Check auth status on startup
    // We use microtask to perform side effect after build
    Future.microtask(() => checkAuthStatus());
    return const AuthState(isLoading: true);
  }

  // Check auth status - call this explicitly when needed
  Future<void> checkAuthStatus() async {
    await _checkAuthStatus();
  }

  // 🔐 LOGIN METHOD
  // Called when user taps login button
  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    // 1. Show loading indicator
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 2. Call API to login
      await _authRepository.login(identifier, password);

      // 3. Get user data
      final user = await _authRepository.getCurrentUser();

      // 4. Update state with user data
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );

      // 5. Track activity
      ref.read(activityTrackerProvider.notifier).trackLogin();
    } catch (e) {
      // Handle error
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // 📝 REGISTER METHOD
  Future<void> register({
    required String identifier,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Call API to register
      await _authRepository.register(
        identifier: identifier,
        password: password,
      );

      // Get user data
      final user = await _authRepository.getCurrentUser();

      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // 🚪 LOGOUT METHOD
  Future<void> logout() async {
    try {
      await _authRepository.logout();
      state = const AuthState();
    } catch (e) {
      // Even if logout fails, clear local state
      state = const AuthState();
    }
  }

  // 👤 UPDATE PROFILE METHOD
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updatedUser = await _authRepository.updateProfile(profileData);
      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  // Private helper methods
  Future<void> _checkAuthStatus() async {
    try {
      // First check if we have stored tokens
      final storedToken = await _authRepository.getAccessToken();
      if (storedToken != null && storedToken.isNotEmpty) {
        // Try to validate the stored token
        final hasValidToken = await _authRepository.hasValidToken();
        if (hasValidToken) {
          final user = await _authRepository.getCurrentUser();
          state = state.copyWith(
            user: user,
            isAuthenticated: true,
            isLoading: false,
          );
          return;
        }
      }

      // Token validation failed, try automatic login with stored credentials
      final credentials = await _authRepository.localStorage.getUserCredentials();
      final identifier = credentials['identifier'];
      final password = credentials['password'];

      if (identifier != null && password != null && identifier.isNotEmpty && password.isNotEmpty) {
        try {
          // Attempt automatic login
          await login(identifier: identifier, password: password);
          return; // Login successful, state already updated
        } catch (e) {
          // Automatic login failed, clear stored credentials
          await _authRepository.localStorage.clearSecureData();
        }
      }

      // No valid token and no credentials, user needs to login manually
      state = state.copyWith(isLoading: false, isAuthenticated: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, isAuthenticated: false);
    }
  }
}
