// lib/providers/settings_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier() : super(Settings()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsString = prefs.getString('settings');
    if (settingsString != null) {
      final Map<String, dynamic> settingsMap = json.decode(settingsString);
      state = Settings.fromMap(settingsMap);
    }
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings', json.encode(state.toMap()));
  }

  void toggleDarkMode(bool isDark) {
    state.isDarkMode = isDark;
    saveSettings();
    state = Settings(isDarkMode: isDark);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  return SettingsNotifier();
});