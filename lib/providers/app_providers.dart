import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enhanced_user_model.dart';
import '../models/scan_models.dart';
import '../services/enhanced_auth_service.dart';
import '../services/scan_service.dart';

// Auth Service Provider
final authServiceProvider = Provider<EnhancedAuthService>((ref) {
  return EnhancedAuthService();
});

// Current User Provider
final currentUserProvider = StreamProvider<EnhancedUserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.userStream;
});

// User Stats Provider
final userStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getUserStats();
});

// User Rankings Provider
final userRankingsProvider = FutureProvider<Map<String, int?>>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getUserRankings();
});

// Scan History Provider
final scanHistoryProvider = FutureProvider.family<List<ScanResultModel>, String>((ref, userId) async {
  return await ScanService.getUserScanHistory(userId);
});

// Daily Leaderboard Provider
final dailyLeaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  return await ScanService.getLeaderboard(type: 'daily');
});

// Weekly Leaderboard Provider
final weeklyLeaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  return await ScanService.getLeaderboard(type: 'weekly');
});

// Eco Tips Provider
final ecoTipsProvider = FutureProvider<List<TipModel>>((ref) async {
  return await ScanService.getEcoTips();
});

// User Badges Provider
final userBadgesProvider = FutureProvider.family<List<BadgeModel>, String>((ref, userId) async {
  return await ScanService.getUserBadges(userId);
});

// Scan Processing State Provider
final scanProcessingProvider = StateNotifierProvider<ScanProcessingNotifier, ScanProcessingState>((ref) {
  return ScanProcessingNotifier();
});

// Scan Processing State
class ScanProcessingState {
  final bool isProcessing;
  final double progress;
  final String? message;
  final ScanResultModel? result;
  final String? error;

  ScanProcessingState({
    this.isProcessing = false,
    this.progress = 0.0,
    this.message,
    this.result,
    this.error,
  });

  ScanProcessingState copyWith({
    bool? isProcessing,
    double? progress,
    String? message,
    ScanResultModel? result,
    String? error,
  }) {
    return ScanProcessingState(
      isProcessing: isProcessing ?? this.isProcessing,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }
}

// Scan Processing Notifier
class ScanProcessingNotifier extends StateNotifier<ScanProcessingState> {
  ScanProcessingNotifier() : super(ScanProcessingState());

  Future<void> processScan(String imagePath, String city) async {
    try {
      // Start processing
      state = state.copyWith(
        isProcessing: true,
        progress: 0.0,
        message: 'Uploading image...',
        error: null,
        result: null,
      );

      // Update progress as we go
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(progress: 0.2, message: 'Analyzing waste...');

      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(progress: 0.5, message: 'Classifying items...');

      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(progress: 0.8, message: 'Updating your progress...');

      // Process the scan
      final result = await ScanService.processScan(
        imagePath: imagePath,
        city: city,
      );

      // Complete
      state = state.copyWith(
        isProcessing: false,
        progress: 1.0,
        message: 'Scan complete!',
        result: result,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
        message: null,
      );
    }
  }

  void reset() {
    state = ScanProcessingState();
  }
}

// Location Provider
final locationProvider = StateProvider<String?>((ref) => null);

// Selected Tab Provider (for bottom navigation)
final selectedTabProvider = StateProvider<int>((ref) => 0);

// Theme Mode Provider
final themeModeProvider = StateProvider<bool>((ref) => false); // false = light, true = dark

// Notification Settings Provider
final notificationSettingsProvider = StateProvider<Map<String, bool>>((ref) => {
  'dailyReminders': true,
  'achievementAlerts': true,
  'leaderboardUpdates': false,
  'ecoTips': true,
});

// App Version Provider
final appVersionProvider = Provider<String>((ref) => '1.0.0');

// Loading State Provider for various operations
final loadingStateProvider = StateNotifierProvider<LoadingStateNotifier, Map<String, bool>>((ref) {
  return LoadingStateNotifier();
});

class LoadingStateNotifier extends StateNotifier<Map<String, bool>> {
  LoadingStateNotifier() : super({});

  void setLoading(String key, bool isLoading) {
    state = {...state, key: isLoading};
  }

  bool isLoading(String key) {
    return state[key] ?? false;
  }
}

// Error State Provider
final errorStateProvider = StateNotifierProvider<ErrorStateNotifier, Map<String, String?>>((ref) {
  return ErrorStateNotifier();
});

class ErrorStateNotifier extends StateNotifier<Map<String, String?>> {
  ErrorStateNotifier() : super({});

  void setError(String key, String? error) {
    state = {...state, key: error};
  }

  void clearError(String key) {
    final newState = Map<String, String?>.from(state);
    newState.remove(key);
    state = newState;
  }

  String? getError(String key) {
    return state[key];
  }
}

// Camera Permission Provider
final cameraPermissionProvider = StateProvider<bool>((ref) => false);

// Storage Permission Provider
final storagePermissionProvider = StateProvider<bool>((ref) => false);

// Location Permission Provider
final locationPermissionProvider = StateProvider<bool>((ref) => false);

// Recent Scans Provider (for quick access)
final recentScansProvider = FutureProvider<List<ScanResultModel>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return [];
  
  return await ScanService.getUserScanHistory(user.uid, limit: 5);
});

// Today's Points Provider
final todayPointsProvider = FutureProvider<int>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return 0;  
  return 0;
});

// Streak Status Provider
final streakStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return {'current': 0, 'isActive': false};

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  bool isActiveToday = false;
  if (user.lastScanDate != null) {
    final lastScanDay = DateTime(
      user.lastScanDate!.year,
      user.lastScanDate!.month,
      user.lastScanDate!.day,
    );
    isActiveToday = lastScanDay == today;
  }

  return {
    'current': user.streakCount,
    'isActive': isActiveToday,
    'lastScanDate': user.lastScanDate,
  };
});
