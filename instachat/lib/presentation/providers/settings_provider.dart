import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/local_storage_service.dart';

// Settings Provider for app-wide preferences
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class AppSettings {
  final bool isDarkMode;
  final bool autoScrollReels;
  final String language;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool disappearingMessagesEnabled;
  final Duration disappearingMessageDuration;

  const AppSettings({
    this.isDarkMode = false,
    this.autoScrollReels = false,
    this.language = 'en',
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.disappearingMessagesEnabled = false,
    this.disappearingMessageDuration = const Duration(hours: 24),
  });

  AppSettings copyWith({
    bool? isDarkMode,
    bool? autoScrollReels,
    String? language,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? disappearingMessagesEnabled,
    Duration? disappearingMessageDuration,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      autoScrollReels: autoScrollReels ?? this.autoScrollReels,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      disappearingMessagesEnabled: disappearingMessagesEnabled ?? this.disappearingMessagesEnabled,
      disappearingMessageDuration: disappearingMessageDuration ?? this.disappearingMessageDuration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'autoScrollReels': autoScrollReels,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'disappearingMessagesEnabled': disappearingMessagesEnabled,
      'disappearingMessageDuration': disappearingMessageDuration.inHours,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isDarkMode: json['isDarkMode'] ?? false,
      autoScrollReels: json['autoScrollReels'] ?? false,
      language: json['language'] ?? 'en',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      disappearingMessagesEnabled: json['disappearingMessagesEnabled'] ?? false,
      disappearingMessageDuration: Duration(hours: json['disappearingMessageDuration'] ?? 24),
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  final LocalStorageService _storage = LocalStorageService();

  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settingsJson = await _storage.getSettings();
      if (settingsJson != null) {
        state = AppSettings.fromJson(settingsJson);
      }
    } catch (e) {
      // Use default settings if loading fails
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _storage.saveSettings(state.toJson());
    } catch (e) {
      // Handle save error
    }
  }

  Future<void> setDarkMode(bool enabled) async {
    state = state.copyWith(isDarkMode: enabled);
    await _saveSettings();
  }

  Future<void> setAutoScrollReels(bool enabled) async {
    state = state.copyWith(autoScrollReels: enabled);
    await _saveSettings();
  }

  Future<void> setLanguage(String language) async {
    state = state.copyWith(language: language);
    await _saveSettings();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _saveSettings();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _saveSettings();
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    state = state.copyWith(vibrationEnabled: enabled);
    await _saveSettings();
  }

  Future<void> setDisappearingMessagesEnabled(bool enabled) async {
    state = state.copyWith(disappearingMessagesEnabled: enabled);
    await _saveSettings();
  }

  Future<void> setDisappearingMessageDuration(Duration duration) async {
    state = state.copyWith(disappearingMessageDuration: duration);
    await _saveSettings();
  }

  Future<void> resetToDefaults() async {
    state = const AppSettings();
    await _saveSettings();
  }
}