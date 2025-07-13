// lib/features/progress/provider/progress_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/authentication/auth.dart';
import '../../../models/user_stats.dart';
import '../../../models/scan_history_entry.dart';

final userStatsProvider = FutureProvider<UserStats?>((ref) async {
  final authService = AuthService();
  final user = await authService.getCurrentUser();
  if (user == null) return null;

  final doc =
      await authService.firestore.collection('stats').doc(user.uid).get();

  if (!doc.exists) return null;

  return UserStats.fromJson(doc.data()!);
});

final scanHistoryProvider = FutureProvider<List<ScanHistoryEntry>>((ref) async {
  final authService = AuthService();
  final user = await authService.getCurrentUser();
  if (user == null) return [];

  final snapshots = await authService.firestore
      .collection('users')
      .doc(user.uid)
      .collection('history')
      .orderBy('scannedAt', descending: true)
      .limit(20)
      .get();

  return snapshots.docs
      .map((doc) => ScanHistoryEntry.fromJson(doc.data()))
      .toList();
});
