import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:uuid/uuid.dart';
import 'package:waste_sorter_app/services/logging_service.dart';
import '../models/enhanced_user_model.dart';
import '../models/scan_models.dart';
import 'firebase_storage_service.dart';
import 'waste_classification_service.dart';

class ScanService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const Uuid _uuid = Uuid();

  /// Process a complete scan: upload image, classify waste, save result, update user stats
  static Future<ScanResultModel> processScan({
    required String imagePath,
    required String city,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      String imageUrl;

      // 1. Try to upload image to Firebase Storage, fallback to local path if it fails
      try {
        imageUrl =
            await FirebaseStorageService.uploadScanImage(user.uid, imagePath);
      } catch (storageError) {
        // For now, use a placeholder URL if Firebase Storage is not configured
        // In production, this should be properly configured
        LoggingService.error('Warning: Firebase Storage upload failed: $storageError');
        imageUrl =
            'placeholder://local-image-${DateTime.now().millisecondsSinceEpoch}';
      }

      // 2. Classify the waste using the AI API
      final classification =
          await WasteClassificationService.classifyWaste(imageUrl);

      // 3. Calculate points earned
      final pointsEarned =
          WasteClassificationService.calculatePoints(classification);

      // 4. Create scan result
      final scanResult = ScanResultModel(
        scanId: _uuid.v4(),
        userId: user.uid,
        imageUrl: imageUrl,
        detectedItems: classification.detectedItems,
        categories: classification.categories,
        binColor: classification.binColor,
        instructions: classification.instructions,
        city: city,
        timestamp: DateTime.now(),
        pointsEarned: pointsEarned,
        confidence: classification.confidence,
      );

      // 5. Save scan to Firestore
      await _firestore
          .collection('scans')
          .doc(scanResult.scanId)
          .set(scanResult.toJson());

      // 6. Update user stats
      await _updateUserStats(user.uid, pointsEarned);

      // 7. Update leaderboards
      await _updateLeaderboards(user.uid, pointsEarned);

      // 8. Check for new badges
      await _checkAndAwardBadges(user.uid);

      return scanResult;
    } catch (e) {
      throw Exception('Failed to process scan: $e');
    }
  }

  /// Update user statistics after a scan
  static Future<void> _updateUserStats(String userId, int pointsEarned) async {
    final userRef = _firestore.collection('users').doc(userId);
    final statsRef = _firestore.collection('stats').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      final statsDoc = await transaction.get(statsRef);

      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final userData = userDoc.data()!;
      final user = EnhancedUserModel.fromJson(userData);

      // Calculate new streak
      int newStreak = user.streakCount;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (user.lastScanDate != null) {
        final lastScanDay = DateTime(
          user.lastScanDate!.year,
          user.lastScanDate!.month,
          user.lastScanDate!.day,
        );

        final daysDifference = today.difference(lastScanDay).inDays;

        if (daysDifference == 1) {
          // Consecutive day - increment streak
          newStreak++;
        } else if (daysDifference > 1) {
          // Missed days - reset streak
          newStreak = 1;
        }
        // Same day - keep current streak
      } else {
        // First scan ever
        newStreak = 1;
      }

      // Update user document
      final updatedUser = user.copyWith(
        totalPoints: user.totalPoints + pointsEarned,
        streakCount: newStreak,
        lastScanDate: now,
      );

      transaction.update(userRef, updatedUser.toJson());

      // Update stats document
      Map<String, dynamic> currentStats;
      if (statsDoc.exists) {
        currentStats = statsDoc.data()!;
      } else {
        // Initialize stats with user's existing data
        currentStats = {
          'totalPoints': user.totalPoints,  // Use existing points
          'totalScans': 0,  // Start from 0 for new stats
          'currentStreak': user.streakCount,  // Use existing streak
          'longestStreak': user.streakCount,  // Initialize with current streak
          'weeklyProgress': List<int>.filled(7, 0),
          'categoryBreakdown': {
            'Recyclable': 0,
            'Compostable': 0,
            'Hazardous': 0,
            'Landfill': 0,
          }
        };
      }

      // Update stats
      currentStats['totalPoints'] = (currentStats['totalPoints'] as int) + pointsEarned;
      currentStats['totalScans'] = (currentStats['totalScans'] as int) + 1;
      currentStats['currentStreak'] = newStreak;
      currentStats['longestStreak'] = newStreak > (currentStats['longestStreak'] as int) 
          ? newStreak 
          : currentStats['longestStreak'];

      // Update weekly progress
      List<int> weeklyProgress = List<int>.from(currentStats['weeklyProgress']);
      int dayIndex = DateTime.now().weekday - 1; // 0 = Monday, 6 = Sunday
      weeklyProgress[dayIndex] = weeklyProgress[dayIndex] + 1;
      currentStats['weeklyProgress'] = weeklyProgress;

      transaction.set(statsRef, currentStats, SetOptions(merge: true));
    });
  }

  /// Update leaderboard entries
  static Future<void> _updateLeaderboards(
      String userId, int pointsEarned) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeek = _getWeekStart(now);

    // Update daily leaderboard
    final dailyLeaderboardId =
        'daily-${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    await _updateLeaderboardEntry(
        'leaderboard', dailyLeaderboardId, userId, pointsEarned);

    // Update weekly leaderboard
    final weeklyLeaderboardId =
        'weekly-${thisWeek.year}-${thisWeek.month.toString().padLeft(2, '0')}-${thisWeek.day.toString().padLeft(2, '0')}';
    await _updateLeaderboardEntry(
        'leaderboard', weeklyLeaderboardId, userId, pointsEarned);
  }

  /// Update a specific leaderboard entry
  static Future<void> _updateLeaderboardEntry(
      String collection, String docId, String userId, int points) async {
    final leaderboardRef = _firestore.collection(collection).doc(docId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(leaderboardRef);

      Map<String, dynamic> data;
      if (doc.exists) {
        data = doc.data()!;
      } else {
        data = {'topUsers': []};
      }

      List<dynamic> topUsers = List.from(data['topUsers'] ?? []);

      // Find existing user entry
      int existingIndex =
          topUsers.indexWhere((user) => user['userID'] == userId);

      if (existingIndex >= 0) {
        // Update existing entry
        topUsers[existingIndex]['points'] =
            (topUsers[existingIndex]['points'] as int) + points;
      } else {
        // Get user name for new entry
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final userName = userDoc.data()?['name'] ?? 'Anonymous';

        // Add new entry
        topUsers.add({
          'userID': userId,
          'name': userName,
          'points': points,
        });
      }

      // Sort by points (descending) and keep top 100
      topUsers
          .sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));
      if (topUsers.length > 100) {
        topUsers = topUsers.take(100).toList();
      }

      transaction.set(
          leaderboardRef, {'topUsers': topUsers}, SetOptions(merge: true));
    });
  }

  /// Check and award badges based on user activity
  static Future<void> _checkAndAwardBadges(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return;

    final user = EnhancedUserModel.fromJson(userDoc.data()!);
    final scanCount = await _getUserScanCount(userId);

    final badgesToAward = <BadgeModel>[];

    // First scan badge
    if (scanCount == 1) {
      badgesToAward.add(BadgeModel(
        badgeId: 'first-scan',
        name: 'First Scan',
        description: 'Completed your first waste scan!',
        iconUrl: 'assets/badges/first-scan.png',
        earnedAt: DateTime.now(),
      ));
    }

    // Streak badges
    if (user.streakCount == 7) {
      badgesToAward.add(BadgeModel(
        badgeId: '7-day-streak',
        name: '7-Day Streak',
        description: 'Scanned waste for 7 consecutive days!',
        iconUrl: 'assets/badges/7-day-streak.png',
        earnedAt: DateTime.now(),
      ));
    }

    if (user.streakCount == 30) {
      badgesToAward.add(BadgeModel(
        badgeId: '30-day-streak',
        name: '30-Day Streak',
        description: 'Scanned waste for 30 consecutive days!',
        iconUrl: 'assets/badges/30-day-streak.png',
        earnedAt: DateTime.now(),
      ));
    }

    // Scan count badges
    if (scanCount == 10) {
      badgesToAward.add(BadgeModel(
        badgeId: '10-scans',
        name: 'Getting Started',
        description: 'Completed 10 waste scans!',
        iconUrl: 'assets/badges/10-scans.png',
        earnedAt: DateTime.now(),
      ));
    }

    if (scanCount == 50) {
      badgesToAward.add(BadgeModel(
        badgeId: '50-scans',
        name: 'Eco Warrior',
        description: 'Completed 50 waste scans!',
        iconUrl: 'assets/badges/50-scans.png',
        earnedAt: DateTime.now(),
      ));
    }

    if (scanCount == 100) {
      badgesToAward.add(BadgeModel(
        badgeId: '100-scans',
        name: 'Eco Champion',
        description: 'Completed 100 waste scans!',
        iconUrl: 'assets/badges/100-scans.png',
        earnedAt: DateTime.now(),
      ));
    }

    // Points badges
    if (user.totalPoints >= 100) {
      badgesToAward.add(BadgeModel(
        badgeId: '100-points',
        name: 'Point Collector',
        description: 'Earned 100 points!',
        iconUrl: 'assets/badges/100-points.png',
        earnedAt: DateTime.now(),
      ));
    }

    if (user.totalPoints >= 500) {
      badgesToAward.add(BadgeModel(
        badgeId: '500-points',
        name: 'Point Master',
        description: 'Earned 500 points!',
        iconUrl: 'assets/badges/500-points.png',
        earnedAt: DateTime.now(),
      ));
    }

    // Award badges that haven't been earned yet
    if (badgesToAward.isNotEmpty) {
      await _awardBadges(userId, badgesToAward);
    }
  }

  /// Award badges to user
  static Future<void> _awardBadges(
      String userId, List<BadgeModel> badges) async {
    final badgesRef = _firestore.collection('badges').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(badgesRef);

      List<dynamic> existingBadges = [];
      if (doc.exists) {
        existingBadges = List.from(doc.data()?['badgeList'] ?? []);
      }

      final existingBadgeIds = existingBadges.map((b) => b['badgeId']).toSet();

      for (var badge in badges) {
        if (!existingBadgeIds.contains(badge.badgeId)) {
          existingBadges.add(badge.toJson());
        }
      }

      transaction.set(
          badgesRef, {'badgeList': existingBadges}, SetOptions(merge: true));
    });
  }

  /// Get user's total scan count
  static Future<int> _getUserScanCount(String userId) async {
    final scansQuery = await _firestore
        .collection('scans')
        .where('userId', isEqualTo: userId)
        .get();

    return scansQuery.docs.length;
  }

  /// Get scan history for a user
  static Future<List<ScanResultModel>> getUserScanHistory(String userId,
      {int limit = 20, int offset = 0}) async {
    final query = await _firestore
        .collection('scans')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return query.docs
        .map((doc) => ScanResultModel.fromJson(doc.data()))
        .toList();
  }

  /// Get leaderboard data
  static Future<List<LeaderboardEntry>> getLeaderboard({
    required String type, // 'daily', 'weekly'
    DateTime? date,
    int limit = 50,
  }) async {
    date ??= DateTime.now();
    String docId;

    if (type == 'daily') {
      docId =
          'daily-${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } else {
      final weekStart = _getWeekStart(date);
      docId =
          'weekly-${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
    }

    final doc = await _firestore.collection('leaderboard').doc(docId).get();

    if (!doc.exists) return [];

    final topUsers = List.from(doc.data()?['topUsers'] ?? []);

    return topUsers.take(limit).map((userData) {
      return LeaderboardEntry(
        userId: userData['userID'],
        name: userData['name'],
        points: userData['points'],
        rank: topUsers.indexOf(userData) + 1,
      );
    }).toList();
  }

  /// Get user's rank in leaderboard
  static Future<int?> getUserRank(String userId, String type,
      {DateTime? date}) async {
    final leaderboard =
        await getLeaderboard(type: type, date: date, limit: 1000);

    for (int i = 0; i < leaderboard.length; i++) {
      if (leaderboard[i].userId == userId) {
        return i + 1;
      }
    }

    return null;
  }

  /// Get weekly eco tips
  static Future<List<TipModel>> getEcoTips({int limit = 10}) async {
    final query = await _firestore
        .collection('tips')
        .orderBy('postedAt', descending: true)
        .limit(limit)
        .get();

    return query.docs.map((doc) => TipModel.fromJson(doc.data())).toList();
  }

  /// Get user badges
  static Future<List<BadgeModel>> getUserBadges(String userId) async {
    final doc = await _firestore.collection('badges').doc(userId).get();

    if (!doc.exists) return [];

    final badgeList = List.from(doc.data()?['badgeList'] ?? []);

    return badgeList
        .map((badgeData) => BadgeModel.fromJson(badgeData))
        .toList();
  }

  /// Helper function to get start of week (Monday)
  static DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysFromMonday));
  }

  /// Update user location
  static Future<void> updateUserLocation(String userId, String location) async {
    await _firestore.collection('users').doc(userId).update({
      'location': location,
    });
  }

  /// Get disposal rules for a city
  static Future<Map<String, String>> getDisposalRules(String city) async {
    try {
      final doc =
          await _firestore.collection('rules').doc(city.toLowerCase()).get();

      if (doc.exists) {
        final data = doc.data()!;
        return Map<String, String>.from(data);
      }
    } catch (e) {
      LoggingService.error('Error fetching disposal rules: $e');
    }

    // Default rules for Kigali
    return {
      'plastic': 'Blue',
      'organic': 'Green',
      'paper': 'Yellow',
      'e-waste': 'Red',
      'hazardous': 'Black',
      'metal': 'Blue',
      'glass': 'Blue',
    };
  }

  /// Initialize default tips and rules (call once during app setup)
  static Future<void> initializeDefaultData() async {
    await _initializeDefaultTips();
    await _initializeDefaultRules();
  }

  static Future<void> _initializeDefaultTips() async {
    final tips = [
      TipModel(
        tipId: 'tip-1',
        title: 'What Belongs in the Blue Bin?',
        content:
            'Plastic bottles, containers, metal cans, and glass jars go in the blue recycling bin. Always rinse them first!',
        imageUrl: null,
        postedAt: DateTime.now(),
      ),
      TipModel(
        tipId: 'tip-2',
        title: 'Composting at Home',
        content:
            'Fruit peels, vegetable scraps, and coffee grounds make great compost. Avoid meat, dairy, and oils in your compost bin.',
        imageUrl: null,
        postedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      TipModel(
        tipId: 'tip-3',
        title: 'E-Waste Safety',
        content:
            'Never throw electronics in regular bins. Take them to designated e-waste collection points to prevent environmental damage.',
        imageUrl: null,
        postedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    for (var tip in tips) {
      await _firestore.collection('tips').doc(tip.tipId).set(tip.toJson());
    }
  }

  static Future<void> _initializeDefaultRules() async {
    final kigaliRules = {
      'plastic': 'Blue',
      'organic': 'Green',
      'paper': 'Yellow',
      'e-waste': 'Red',
      'hazardous': 'Black',
      'metal': 'Blue',
      'glass': 'Blue',
      'cardboard': 'Yellow',
    };

    await _firestore.collection('rules').doc('kigali').set(kigaliRules);
  }

  /// Temporary method to debug user stats document
// static Future<void> debugUserStats(String userId) async {
//   try {
//     final statsRef = _firestore.collection('stats').doc(userId);
//     final userRef = _firestore.collection('users').doc(userId);
    
//     final statsDoc = await statsRef.get();
//     final userDoc = await userRef.get();

//     if (userDoc.exists && !statsDoc.exists) {
//       // If user exists but stats don't, initialize stats
//       final userData = userDoc.data()!;
//       final user = EnhancedUserModel.fromJson(userData);
      
//       final initialStats = {
//         'totalPoints': user.totalPoints,
//         'totalScans': 0,
//         'currentStreak': user.streakCount,
//         'longestStreak': user.streakCount,
//         'weeklyProgress': List<int>.filled(7, 0),
//         'categoryBreakdown': {
//           'Recyclable': 0,
//           'Compostable': 0,
//           'Hazardous': 0,
//           'Landfill': 0,
//         }
//       };
      
//       await statsRef.set(initialStats);
//       debugPrint('Initialized stats for user: $userId with data from users collection');
//     }

//     final updatedStatsDoc = await statsRef.get();
//     debugPrint('User stats: ${updatedStatsDoc.data()}');
//     debugPrint('User data: ${userDoc.data()}');
//   } catch (e) {
//     debugPrint('Error managing user stats: $e');
//   }

// }
}
