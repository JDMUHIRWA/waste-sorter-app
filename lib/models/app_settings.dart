// lib/models/app_settings.dart
class AppSettings {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool darkMode;
  final String language;

  AppSettings({
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.darkMode,
    required this.language,
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? darkMode,
    String? language,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
    );
  }
}
