import 'package:flutter/foundation.dart';

/// User profile data model
@immutable
class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.location,
    required this.totalPoints,
    required this.currentStreak,
    required this.totalScans,
    required this.joinedAt,
  });

  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String? location;
  final int totalPoints;
  final int currentStreak;
  final int totalScans;
  final DateTime joinedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'location': location,
      'totalPoints': totalPoints,
      'currentStreak': currentStreak,
      'totalScans': totalScans,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      location: json['location'] as String?,
      totalPoints: json['totalPoints'] as int,
      currentStreak: json['currentStreak'] as int,
      totalScans: json['totalScans'] as int,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }

  UserProfile copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    String? location,
    int? totalPoints,
    int? currentStreak,
    int? totalScans,
    DateTime? joinedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      location: location ?? this.location,
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      totalScans: totalScans ?? this.totalScans,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

/// Leaderboard user entry
@immutable
class LeaderboardUser {
  const LeaderboardUser({
    required this.rank,
    required this.username,
    required this.points,
    this.avatarUrl,
    this.isCurrentUser = false,
  });

  final int rank;
  final String username;
  final int points;
  final String? avatarUrl;
  final bool isCurrentUser;

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'username': username,
      'points': points,
      'avatarUrl': avatarUrl,
      'isCurrentUser': isCurrentUser,
    };
  }

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      rank: json['rank'] as int,
      username: json['username'] as String,
      points: json['points'] as int,
      avatarUrl: json['avatarUrl'] as String?,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
    );
  }
}

/// Scan history entry
@immutable
class ScanHistoryEntry {
  const ScanHistoryEntry({
    required this.id,
    required this.imagePath,
    required this.classificationResult,
    required this.pointsEarned,
    required this.scannedAt,
  });

  final String id;
  final String imagePath;
  final String classificationResult; // JSON string of ClassificationResult
  final int pointsEarned;
  final DateTime scannedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'classificationResult': classificationResult,
      'pointsEarned': pointsEarned,
      'scannedAt': scannedAt.toIso8601String(),
    };
  }

  factory ScanHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ScanHistoryEntry(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      classificationResult: json['classificationResult'] as String,
      pointsEarned: json['pointsEarned'] as int,
      scannedAt: DateTime.parse(json['scannedAt'] as String),
    );
  }
}

/// Comprehensive user statistics for progress tracking
@immutable
class UserStats {
  const UserStats({
    required this.totalScans,
    required this.totalPoints,
    required this.currentStreak,
    required this.longestStreak,
    required this.weeklyProgress,
    required this.monthlyProgress,
    required this.categoryBreakdown,
    required this.environmentalImpact,
    required this.achievements,
    required this.recentScans,
    required this.accuracyRate,
    required this.co2SavedKg,
    required this.wasteRecycledKg,
  });

  final int totalScans;
  final int totalPoints;
  final int currentStreak;
  final int longestStreak;
  final List<int> weeklyProgress; // 7 days of scan counts
  final List<int> monthlyProgress; // 4 weeks of scan counts
  final Map<String, int> categoryBreakdown; // category -> count
  final Map<String, double> environmentalImpact; // impact type -> value
  final List<String> achievements; // achievement IDs
  final List<ScanHistoryEntry> recentScans; // last 10 scans
  final double accuracyRate; // 0.0 to 1.0
  final double co2SavedKg;
  final double wasteRecycledKg;

  Map<String, dynamic> toJson() {
    return {
      'totalScans': totalScans,
      'totalPoints': totalPoints,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'weeklyProgress': weeklyProgress,
      'monthlyProgress': monthlyProgress,
      'categoryBreakdown': categoryBreakdown,
      'environmentalImpact': environmentalImpact,
      'achievements': achievements,
      'recentScans': recentScans.map((e) => e.toJson()).toList(),
      'accuracyRate': accuracyRate,
      'co2SavedKg': co2SavedKg,
      'wasteRecycledKg': wasteRecycledKg,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalScans: json['totalScans'] as int,
      totalPoints: json['totalPoints'] as int,
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      weeklyProgress: List<int>.from(json['weeklyProgress'] as List),
      monthlyProgress: List<int>.from(json['monthlyProgress'] as List),
      categoryBreakdown:
          Map<String, int>.from(json['categoryBreakdown'] as Map),
      environmentalImpact:
          Map<String, double>.from(json['environmentalImpact'] as Map),
      achievements: List<String>.from(json['achievements'] as List),
      recentScans: (json['recentScans'] as List)
          .map((e) => ScanHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      accuracyRate: json['accuracyRate'] as double,
      co2SavedKg: json['co2SavedKg'] as double,
      wasteRecycledKg: json['wasteRecycledKg'] as double,
    );
  }

  /// Create a mock instance for testing/development
  factory UserStats.mock() {
    return UserStats(
      totalScans: 156,
      totalPoints: 1820,
      currentStreak: 7,
      longestStreak: 12,
      weeklyProgress: [5, 8, 3, 12, 6, 9, 4],
      monthlyProgress: [23, 31, 28, 35],
      categoryBreakdown: {
        'Plastic': 45,
        'Paper': 38,
        'Metal': 22,
        'Glass': 15,
        'Organic': 36,
      },
      environmentalImpact: {
        'co2Saved': 15.6,
        'waterSaved': 234.5,
        'energySaved': 89.2,
      },
      achievements: [
        'first_scan',
        'week_streak',
        'eco_warrior',
        'accuracy_master'
      ],
      recentScans: [
        ScanHistoryEntry(
          id: '1',
          imagePath: '/path/to/image1.jpg',
          classificationResult: '{"category": "Plastic", "confidence": 0.95}',
          pointsEarned: 15,
          scannedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ScanHistoryEntry(
          id: '2',
          imagePath: '/path/to/image2.jpg',
          classificationResult: '{"category": "Paper", "confidence": 0.88}',
          pointsEarned: 12,
          scannedAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ],
      accuracyRate: 0.94,
      co2SavedKg: 15.6,
      wasteRecycledKg: 23.4,
    );
  }
}

/// App settings model
@immutable
class AppSettings {
  const AppSettings({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.darkMode = false,
    this.language = 'English',
  });

  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool darkMode;
  final String language;

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

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'darkMode': darkMode,
      'language': language,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      darkMode: json['darkMode'] ?? false,
      language: json['language'] ?? 'English',
    );
  }
}
