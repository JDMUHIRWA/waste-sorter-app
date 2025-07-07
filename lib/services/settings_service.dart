import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local app settings using SharedPreferences
class SettingsService {
  static const String _notificationsKey = 'notifications_enabled';
  static const String _soundKey = 'sound_enabled';
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _languageKey = 'app_language';

  late SharedPreferences _prefs;

  /// Initialize the settings service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Notification Settings
  bool get notificationsEnabled => _prefs.getBool(_notificationsKey) ?? true;

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_notificationsKey, enabled);
  }

  // Sound Settings
  bool get soundEnabled => _prefs.getBool(_soundKey) ?? true;

  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(_soundKey, enabled);
  }

  // Dark Mode Settings
  bool get darkModeEnabled => _prefs.getBool(_darkModeKey) ?? false;

  Future<void> setDarkModeEnabled(bool enabled) async {
    await _prefs.setBool(_darkModeKey, enabled);
  }

  // Language Settings
  String get language => _prefs.getString(_languageKey) ?? 'en';

  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(_languageKey, languageCode);
  }

  /// Clear all settings (for testing or reset functionality)
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  /// Get all settings as a map (for debugging)
  Map<String, dynamic> getAllSettings() {
    return {
      'notifications': notificationsEnabled,
      'sound': soundEnabled,
      'darkMode': darkModeEnabled,
      'language': language,
    };
  }
}
