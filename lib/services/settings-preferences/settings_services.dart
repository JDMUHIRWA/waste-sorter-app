// lib/services/settings_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  late SharedPreferences _prefs;

  bool get notificationsEnabled =>
      _prefs.getBool('notificationsEnabled') ?? true;

  bool get soundEnabled => _prefs.getBool('soundEnabled') ?? true;

  bool get darkModeEnabled => _prefs.getBool('darkMode') ?? false;

  String get language => _prefs.getString('language') ?? 'en';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool('notificationsEnabled', value);
  }

  Future<void> setSoundEnabled(bool value) async {
    await _prefs.setBool('soundEnabled', value);
  }

  Future<void> setDarkModeEnabled(bool value) async {
    await _prefs.setBool('darkMode', value);
  }

  Future<void> setLanguage(String lang) async {
    await _prefs.setString('language', lang);
  }
}
