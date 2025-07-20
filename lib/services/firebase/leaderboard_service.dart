import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get daily leaderboard
  static Future<List<LeaderboardEntry>> getDailyLeaderboard({int limit = 50}) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dailyDocId = 'daily-${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final doc = await _firestore.collection('leaderboard').doc(dailyDocId).get();
      
      if (!doc.exists) {
        return [];
      }

      final data = doc.data()!;
      final topUsers = data['topUsers'] as List<dynamic>? ?? [];
      
      // Convert to LeaderboardEntry objects and sort by points
      final entries = topUsers
          .map((user) => LeaderboardEntry(
                rank: 0, // Will be set after sorting
                userId: user['userID'] as String,
                name: user['name'] as String,
                points: user['points'] as int,
                isCurrentUser: user['userID'] == _auth.currentUser?.uid,
              ))
          .toList();

      // Sort by points descending and assign ranks
      entries.sort((a, b) => b.points.compareTo(a.points));
      for (int i = 0; i < entries.length; i++) {
        entries[i] = entries[i].copyWith(rank: i + 1);
      }

      return entries.take(limit).toList();
    } catch (e) {
      print('Error fetching daily leaderboard: $e');
      return [];
    }
  }

  /// Get weekly leaderboard
  static Future<List<LeaderboardEntry>> getWeeklyLeaderboard({int limit = 50}) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);

      // Query users and calculate weekly points
      final query = await _firestore
          .collection('scans')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStartDay))
          .get();

      final Map<String, int> userPoints = {};
      final Map<String, String> userNames = {};

      // Calculate points per user for this week
      for (final doc in query.docs) {
        final data = doc.data();
        final userId = data['userId'] as String;
        final itemCount = (data['detectedItems'] as List).length;
        final points = itemCount * 5; // 5 points per item

        userPoints[userId] = (userPoints[userId] ?? 0) + points;
      }

      // Get user names
      final userIds = userPoints.keys.toList();
      if (userIds.isNotEmpty) {
        final userDocs = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: userIds.take(10).toList())
            .get();

        for (final doc in userDocs.docs) {
          final data = doc.data();
          userNames[doc.id] = data['name'] as String? ?? 'Anonymous';
        }
      }

      // Create leaderboard entries
      final entries = userPoints.entries
          .map((entry) => LeaderboardEntry(
                rank: 0, // Will be set after sorting
                userId: entry.key,
                name: userNames[entry.key] ?? 'Anonymous',
                points: entry.value,
                isCurrentUser: entry.key == _auth.currentUser?.uid,
              ))
          .toList();

      // Sort by points descending and assign ranks
      entries.sort((a, b) => b.points.compareTo(a.points));
      for (int i = 0; i < entries.length; i++) {
        entries[i] = entries[i].copyWith(rank: i + 1);
      }

      return entries.take(limit).toList();
    } catch (e) {
      print('Error fetching weekly leaderboard: $e');
      return [];
    }
  }

  /// Get monthly leaderboard
  static Future<List<LeaderboardEntry>> getMonthlyLeaderboard({int limit = 50}) async {
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);

      // Query users and calculate monthly points
      final query = await _firestore
          .collection('scans')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
          .get();

      final Map<String, int> userPoints = {};
      final Map<String, String> userNames = {};

      // Calculate points per user for this month
      for (final doc in query.docs) {
        final data = doc.data();
        final userId = data['userId'] as String;
        final itemCount = (data['detectedItems'] as List).length;
        final points = itemCount * 5; // 5 points per item

        userPoints[userId] = (userPoints[userId] ?? 0) + points;
      }

      // Get user names
      final userIds = userPoints.keys.toList();
      if (userIds.isNotEmpty) {
        // Split into chunks of 10 (Firestore limit for whereIn)
        for (int i = 0; i < userIds.length; i += 10) {
          final chunk = userIds.skip(i).take(10).toList();
          final userDocs = await _firestore
              .collection('users')
              .where(FieldPath.documentId, whereIn: chunk)
              .get();

          for (final doc in userDocs.docs) {
            final data = doc.data();
            userNames[doc.id] = data['name'] as String? ?? 'Anonymous';
          }
        }
      }

      // Create leaderboard entries
      final entries = userPoints.entries
          .map((entry) => LeaderboardEntry(
                rank: 0, // Will be set after sorting
                userId: entry.key,
                name: userNames[entry.key] ?? 'Anonymous',
                points: entry.value,
                isCurrentUser: entry.key == _auth.currentUser?.uid,
              ))
          .toList();

      // Sort by points descending and assign ranks
      entries.sort((a, b) => b.points.compareTo(a.points));
      for (int i = 0; i < entries.length; i++) {
        entries[i] = entries[i].copyWith(rank: i + 1);
      }

      return entries.take(limit).toList();
    } catch (e) {
      print('Error fetching monthly leaderboard: $e');
      return [];
    }
  }

  /// Get current user's rankings
  static Future<UserRankings> getCurrentUserRankings() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return UserRankings.empty();
      }

      final dailyLeaderboard = await getDailyLeaderboard(limit: 1000);
      final weeklyLeaderboard = await getWeeklyLeaderboard(limit: 1000);
      final monthlyLeaderboard = await getMonthlyLeaderboard(limit: 1000);

      int dailyRank = 0;
      int weeklyRank = 0;
      int monthlyRank = 0;

      // Find user's rank in each leaderboard
      for (int i = 0; i < dailyLeaderboard.length; i++) {
        if (dailyLeaderboard[i].userId == user.uid) {
          dailyRank = i + 1;
          break;
        }
      }

      for (int i = 0; i < weeklyLeaderboard.length; i++) {
        if (weeklyLeaderboard[i].userId == user.uid) {
          weeklyRank = i + 1;
          break;
        }
      }

      for (int i = 0; i < monthlyLeaderboard.length; i++) {
        if (monthlyLeaderboard[i].userId == user.uid) {
          monthlyRank = i + 1;
          break;
        }
      }

      return UserRankings(
        dailyRank: dailyRank,
        weeklyRank: weeklyRank,
        monthlyRank: monthlyRank,
      );
    } catch (e) {
      print('Error fetching user rankings: $e');
      return UserRankings.empty();
    }
  }

  /// Get user stats
  static Future<UserStats> getUserStats(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return UserStats.empty();
      }

      final userData = userDoc.data()!;
      final totalPoints = userData['totalPoints'] as int? ?? 0;
      final streakCount = userData['streakCount'] as int? ?? 0;

      // Get total scans count
      final scansQuery = await _firestore
          .collection('scans')
          .where('userId', isEqualTo: userId)
          .get();

      final totalScans = scansQuery.docs.length;

      // Calculate weekly points
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);

      final weeklyScansQuery = await _firestore
          .collection('scans')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStartDay))
          .get();

      int weeklyPoints = 0;
      for (final doc in weeklyScansQuery.docs) {
        final data = doc.data();
        final itemCount = (data['detectedItems'] as List).length;
        weeklyPoints += itemCount * 5;
      }

      // Calculate monthly points
      final monthStart = DateTime(now.year, now.month, 1);
      final monthlyScansQuery = await _firestore
          .collection('scans')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
          .get();

      int monthlyPoints = 0;
      final Map<String, int> categoryCounts = {};

      for (final doc in monthlyScansQuery.docs) {
        final data = doc.data();
        final detectedItems = data['detectedItems'] as List;
        monthlyPoints += detectedItems.length * 5;

        // Count categories
        for (final item in detectedItems) {
          final category = item['category'] as String;
          categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
        }
      }

      return UserStats(
        totalPoints: totalPoints,
        currentStreak: streakCount,
        totalScans: totalScans,
        weeklyPoints: weeklyPoints,
        monthlyPoints: monthlyPoints,
        categoryCounts: categoryCounts,
      );
    } catch (e) {
      print('Error fetching user stats: $e');
      return UserStats.empty();
    }
  }
}

class LeaderboardEntry {
  final int rank;
  final String userId;
  final String name;
  final int points;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    required this.points,
    required this.isCurrentUser,
  });

  LeaderboardEntry copyWith({
    int? rank,
    String? userId,
    String? name,
    int? points,
    bool? isCurrentUser,
  }) {
    return LeaderboardEntry(
      rank: rank ?? this.rank,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      points: points ?? this.points,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}

class UserRankings {
  final int dailyRank;
  final int weeklyRank;
  final int monthlyRank;

  UserRankings({
    required this.dailyRank,
    required this.weeklyRank,
    required this.monthlyRank,
  });

  factory UserRankings.empty() {
    return UserRankings(
      dailyRank: 0,
      weeklyRank: 0,
      monthlyRank: 0,
    );
  }
}

class UserStats {
  final int totalPoints;
  final int currentStreak;
  final int totalScans;
  final int weeklyPoints;
  final int monthlyPoints;
  final Map<String, int> categoryCounts;

  UserStats({
    required this.totalPoints,
    required this.currentStreak,
    required this.totalScans,
    required this.weeklyPoints,
    required this.monthlyPoints,
    required this.categoryCounts,
  });

  factory UserStats.empty() {
    return UserStats(
      totalPoints: 0,
      currentStreak: 0,
      totalScans: 0,
      weeklyPoints: 0,
      monthlyPoints: 0,
      categoryCounts: {},
    );
  }
}
