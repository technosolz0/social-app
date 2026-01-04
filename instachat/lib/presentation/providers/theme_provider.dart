import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/local_storage_service.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final localStorage = LocalStorageService();
  return ThemeNotifier(localStorage);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final LocalStorageService _localStorage;

  ThemeNotifier(this._localStorage) : super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() {
    final savedTheme = _localStorage.getThemeMode();
    state = _getThemeModeFromString(savedTheme);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _localStorage.saveThemeMode(mode.name);
  }

  void toggleTheme() {
    if (state == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }

  ThemeMode _getThemeModeFromString(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
