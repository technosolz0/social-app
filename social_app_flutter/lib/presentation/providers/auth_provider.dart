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
  final UserModel? user;           // Current logged-in user
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
    // Check if user was logged in before
    _checkAuthStatus();
    return const AuthState();
  }

  // 🔐 LOGIN METHOD
  // Called when user taps login button
  Future<void> login({
    required String email,
    required String password,
  }) async {
    // 1. Show loading indicator
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 2. Call API to login
      await _authRepository.login(email, password);

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
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // 📝 REGISTER METHOD
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Call API to register
      await _authRepository.register(
        username: username,
        email: email,
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
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
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

  // Private helper methods
  Future<void> _checkAuthStatus() async {
    try {
      final hasValidToken = await _authRepository.hasValidToken();
      if (hasValidToken) {
        // Get current user data
        final user = await _authRepository.getCurrentUser();
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
        );
      }
    } catch (e) {
      // Token is invalid, stay in unauthenticated state
      state = const AuthState();
    }
  }
}
