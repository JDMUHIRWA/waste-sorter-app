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

  // Improved factory constructor with null safety
  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
        totalPoints: json['totalPoints'] as int? ?? 0,
        totalScans: json['totalScans'] as int? ?? 0,
        currentStreak: json['currentStreak'] as int? ?? 0,
        longestStreak: json['longestStreak'] as int? ?? 0,
        weeklyProgress: List<int>.from(json['weeklyProgress'] ?? List<int>.filled(7, 0)),
        categoryBreakdown: Map<String, int>.from(json['categoryBreakdown'] ?? {
          'Recyclable': 0,
          'Compostable': 0,
          'Hazardous': 0,
          'Landfill': 0,
        }),
      );

  // Helper method to convert back to JSON
  Map<String, dynamic> toJson() => {
        'totalPoints': totalPoints,
        'totalScans': totalScans,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'weeklyProgress': weeklyProgress,
        'categoryBreakdown': categoryBreakdown,
      };

  // Helper method to update stats
  UserStats copyWith({
    int? totalPoints,
    int? totalScans,
    int? currentStreak,
    int? longestStreak,
    List<int>? weeklyProgress,
    Map<String, int>? categoryBreakdown,
  }) => UserStats(
        totalPoints: totalPoints ?? this.totalPoints,
        totalScans: totalScans ?? this.totalScans,
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        weeklyProgress: weeklyProgress ?? this.weeklyProgress,
        categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      );
}