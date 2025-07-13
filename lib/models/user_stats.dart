// lib/models/user_stats.dart
class UserStats {
  final int totalPoints;
  final int totalScans;
  final int currentStreak;
  final int longestStreak;
  final List<int> weeklyProgress;
  final Map<String, int> categoryBreakdown;

  UserStats({
    required this.totalPoints,
    required this.totalScans,
    required this.currentStreak,
    required this.longestStreak,
    required this.weeklyProgress,
    required this.categoryBreakdown,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
        totalPoints: json['totalPoints'],
        totalScans: json['totalScans'],
        currentStreak: json['currentStreak'],
        longestStreak: json['longestStreak'],
        weeklyProgress: List<int>.from(json['weeklyProgress']),
        categoryBreakdown:
            Map<String, int>.from(json['categoryBreakdown'] ?? {}),
      );
}
