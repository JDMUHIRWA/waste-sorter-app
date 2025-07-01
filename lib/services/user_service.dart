import '../models/user_models.dart';

/// Abstract service for user authentication and management
abstract class UserService {
  /// Sign up a new user
  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String username,
  });

  /// Sign in an existing user
  Future<UserProfile> signIn({
    required String email,
    required String password,
  });

  /// Sign out current user
  Future<void> signOut();

  /// Get current user profile
  Future<UserProfile?> getCurrentUser();

  /// Update user profile
  Future<UserProfile> updateProfile(UserProfile profile);

  /// Check if user is signed in
  Future<bool> isSignedIn();
}

/// Abstract service for user progress and gamification
abstract class ProgressService {
  /// Record a scan result and award points
  Future<void> recordScan({
    required String userId,
    required String category,
    required int pointsEarned,
    required String classificationData,
  });

  /// Get user's current points and streak
  Future<UserStats> getUserStats(String userId);

  /// Get user's scan history
  Future<List<ScanHistoryEntry>> getScanHistory(String userId,
      {int limit = 50});

  /// Update user's location for local leaderboards
  Future<void> updateUserLocation(String userId, String location);
}

/// Abstract service for leaderboards
abstract class LeaderboardService {
  /// Get weekly leaderboard
  Future<List<LeaderboardUser>> getWeeklyLeaderboard({int limit = 50});

  /// Get monthly leaderboard
  Future<List<LeaderboardUser>> getMonthlyLeaderboard({int limit = 50});

  /// Get local leaderboard (by user's location)
  Future<List<LeaderboardUser>> getLocalLeaderboard(String location,
      {int limit = 50});

  /// Get user's rank in different leaderboards
  Future<UserRankings> getUserRankings(String userId);
}

/// User statistics model
class UserStats {
  const UserStats({
    required this.totalPoints,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalScans,
    required this.weeklyPoints,
    required this.monthlyPoints,
    required this.categoryCounts,
  });

  final int totalPoints;
  final int currentStreak;
  final int longestStreak;
  final int totalScans;
  final int weeklyPoints;
  final int monthlyPoints;
  final Map<String, int> categoryCounts;

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalPoints: json['totalPoints'] as int,
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      totalScans: json['totalScans'] as int,
      weeklyPoints: json['weeklyPoints'] as int,
      monthlyPoints: json['monthlyPoints'] as int,
      categoryCounts: Map<String, int>.from(json['categoryCounts'] as Map),
    );
  }
}

/// User rankings across different leaderboards
class UserRankings {
  const UserRankings({
    required this.weeklyRank,
    required this.monthlyRank,
    required this.overallRank,
    this.localRank,
  });

  final int weeklyRank;
  final int monthlyRank;
  final int overallRank;
  final int? localRank;

  factory UserRankings.fromJson(Map<String, dynamic> json) {
    return UserRankings(
      weeklyRank: json['weeklyRank'] as int,
      monthlyRank: json['monthlyRank'] as int,
      overallRank: json['overallRank'] as int,
      localRank: json['localRank'] as int?,
    );
  }
}
