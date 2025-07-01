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
