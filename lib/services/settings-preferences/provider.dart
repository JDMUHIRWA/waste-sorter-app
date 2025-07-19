// lib/services/preferences/provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_settings.dart';
import 'settings_services.dart';

class AppSettingsNotifier extends AsyncNotifier<AppSettings> {
  late final SettingsService _service;

  @override
  Future<AppSettings> build() async {
    _service = SettingsService();
    await _service.init();
    return AppSettings(
      notificationsEnabled: _service.notificationsEnabled,
      soundEnabled: _service.soundEnabled,
      darkMode: _service.darkModeEnabled,
      language: _service.language,
    );
  }

  Future<void> updateDarkMode(bool enabled) async {
    await _service.setDarkModeEnabled(enabled);
    state = AsyncData(state.value!.copyWith(darkMode: enabled));
  }

  Future<void> updateNotifications(bool enabled) async {
    await _service.setNotificationsEnabled(enabled);
    state = AsyncData(state.value!.copyWith(notificationsEnabled: enabled));
  }

  Future<void> updateSound(bool enabled) async {
    await _service.setSoundEnabled(enabled);
    state = AsyncData(state.value!.copyWith(soundEnabled: enabled));
  }

  Future<void> updateLanguage(String lang) async {
    await _service.setLanguage(lang);
    state = AsyncData(state.value!.copyWith(language: lang));
  }
}

// ✅ Export the real usable provider
final settingsNotifierProvider =
    AsyncNotifierProvider<AppSettingsNotifier, AppSettings>(() {
  return AppSettingsNotifier();
});
