// Improved version with real-time updates
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:waste_sorter_app/services/logging_service.dart';
import '../../../services/authentication/auth.dart';
import '../../../models/user_stats.dart';
import '../../../models/scan_history_entry.dart';
// import '../../../services/scan_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// Real-time user stats provider
final userStatsProvider = StreamProvider<UserStats?>((ref) async* {
  final authService = AuthService();
  final user = await authService.getCurrentUser();
  if (user == null) {
    yield null;
    return;
  }
      // final userId = FirebaseAuth.instance.currentUser?.uid;
      // // fetching the username for logging
      // final username = user.name ?? 'Unknown User';
      // LoggingService.info('Fetching user stats for user: $username');
      // LoggingService.info('Fetching user stats for user: $userId');

  final statsRef = authService.firestore.collection('stats').doc(user.uid);
  
  // Check if document exists, create if not
  final doc = await statsRef.get();
  if (!doc.exists) {
    // Get user data to sync stats
    final userRef = authService.firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();
    
    if (userDoc.exists) {
      final userData = userDoc.data()!;
      final defaultStats = {
        'totalPoints': userData['totalPoints'] ?? 0,
        'totalScans': 0,
        'currentStreak': userData['streakCount'] ?? 0,
        'longestStreak': userData['streakCount'] ?? 0,
        'weeklyProgress': List<int>.filled(7, 0),
        'categoryBreakdown': {
          'Recyclable': 0,
          'Compostable': 0,
          'Hazardous': 0,
          'Landfill': 0,
        }
      };
      await statsRef.set(defaultStats);
    } else {
      // Fallback to default values if user document doesn't exist
      final defaultStats = {
        'totalPoints': 0,
        'totalScans': 0,
        'currentStreak': 0,
        'longestStreak': 0,
        'weeklyProgress': List<int>.filled(7, 0),
        'categoryBreakdown': {
          'Recyclable': 0,
          'Compostable': 0,
          'Hazardous': 0,
          'Landfill': 0,
        }
      };
      await statsRef.set(defaultStats);
    }
  }

  // Return real-time stream
  yield* statsRef.snapshots().map((doc) {
    if (!doc.exists) return null;
    return UserStats.fromJson(doc.data()!);
  });
});

// Real-time scan history provider
final scanHistoryProvider = StreamProvider<List<ScanHistoryEntry>>((ref) async* {
  final authService = AuthService();
  final user = await authService.getCurrentUser();
  if (user == null) {
    yield [];
    return;
  }

  yield* authService.firestore
      .collection('users')
      .doc(user.uid)
      .collection('history')
      .orderBy('scannedAt', descending: true)
      .limit(20)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ScanHistoryEntry.fromJson(doc.data()))
          .toList());
});

// Alternative: Keep your current FutureProvider approach but add refresh capability
final refreshableUserStatsProvider = FutureProvider.family<UserStats?, String>((ref, refreshKey) async {
  final authService = AuthService();
  final user = await authService.getCurrentUser();
  if (user == null) return null;

  final statsRef = authService.firestore.collection('stats').doc(user.uid);
  final doc = await statsRef.get();

  if (!doc.exists) {
    final defaultStats = {
      'totalPoints': 0,
      'totalScans': 0,
      'currentStreak': 0,
      'longestStreak': 0,
      'weeklyProgress': List<int>.filled(7, 0),
      'categoryBreakdown': {
        'Recyclable': 0,
        'Compostable': 0,
        'Hazardous': 0,
        'Landfill': 0,
      }
    };
    await statsRef.set(defaultStats);
    return UserStats.fromJson(defaultStats);
  }

  return UserStats.fromJson(doc.data()!);
});