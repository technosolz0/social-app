import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/user_model.dart';
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

// 📌 NOTIFIER: Logic that changes the state
// Think of this as the "brain" that controls auth
@riverpod
class AuthNotifier extends _$AuthNotifier {
  LocalStorageService get _storage => ref.read(localStorageServiceProvider);

  // Initial state when app starts
  @override
  AuthState build() {
    // Check if user was logged in before
    _checkAuthStatus();
    return const AuthState();
  }

  // 🔐 LOGIN METHOD
  // Called when user taps login button
  Future<void> login(String email, String password) async {
    // 1. Show loading indicator
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 2. Call API to login
      // final authRepository = ref.read(authRepositoryProvider);
      // final user = await authRepository.login(email, password);

      // Mock user for now
      final user = UserModel(
        id: const Uuid().v4(),
        username: 'testuser',
        email: email,
      );

      // 3. Save token locally
      await _saveAuthToken('mock_token');

      // 4. Update state with user data
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );

      // 5. Track activity
      // ref.read(activityTrackerProvider).trackLogin();

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
      // final authRepository = ref.read(authRepositoryProvider);
      // final user = await authRepository.register(
      //   username: username,
      //   email: email,
      //   password: password,
      // );

      // Mock user
      final user = UserModel(
        id: const Uuid().v4(),
        username: username,
        email: email,
      );

      await _saveAuthToken('mock_token');

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
    await _clearAuthToken();
    state = const AuthState();
  }

  // Private helper methods
  Future<void> _checkAuthStatus() async {
    final token = await _getAuthToken();
    if (token != null) {
      // Auto-login if token exists
      // final user = await ref.read(authRepositoryProvider).getCurrentUser();
      // Mock user
      final user = UserModel(
        id: const Uuid().v4(),
        username: 'testuser',
        email: 'test@example.com',
      );
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
      );
    }
  }

  Future<void> _saveAuthToken(String token) async {
    await _storage.saveAuthToken(token);
  }

  Future<String?> _getAuthToken() async {
    return await _storage.getAuthToken();
  }

  Future<void> _clearAuthToken() async {
    await _storage.clearSecureData();
  }
}
