import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_models.dart';
import '../services/classification_service.dart';
import '../services/user_service.dart';

// Service Providers - These will be swapped from mock to real implementations

/// Classification service provider
final classificationServiceProvider = Provider<ClassificationService>((ref) {
  // TODO: Replace with real service when backend is ready
  return MockClassificationService();

  // Future implementation:
  // return HttpClassificationService(
  //   baseUrl: AppConfig.apiBaseUrl,
  //   httpClient: ref.read(httpClientProvider),
  // );
});

/// User service provider
final userServiceProvider = Provider<UserService>((ref) {
  // TODO: Replace with real service when backend is ready
  return MockUserService();

  // Future implementation:
  // return HttpUserService(
  //   baseUrl: AppConfig.apiBaseUrl,
  //   httpClient: ref.read(httpClientProvider),
  // );
});

/// Progress service provider
final progressServiceProvider = Provider<ProgressService>((ref) {
  // TODO: Replace with real service when backend is ready
  return MockProgressService();
});

/// Leaderboard service provider
final leaderboardServiceProvider = Provider<LeaderboardService>((ref) {
  // TODO: Replace with real service when backend is ready
  return MockLeaderboardService();
});

// State Providers

/// Current user provider
final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, UserProfile?>((ref) {
  return CurrentUserNotifier(ref.read(userServiceProvider));
});

/// User stats provider
final userStatsProvider = FutureProvider<UserStats?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final progressService = ref.read(progressServiceProvider);
  return await progressService.getUserStats(user.id);
});

/// Weekly leaderboard provider
final weeklyLeaderboardProvider =
    FutureProvider<List<LeaderboardUser>>((ref) async {
  final leaderboardService = ref.read(leaderboardServiceProvider);
  return await leaderboardService.getWeeklyLeaderboard();
});

/// Monthly leaderboard provider
final monthlyLeaderboardProvider =
    FutureProvider<List<LeaderboardUser>>((ref) async {
  final leaderboardService = ref.read(leaderboardServiceProvider);
  return await leaderboardService.getMonthlyLeaderboard();
});

// State Notifiers

class CurrentUserNotifier extends StateNotifier<UserProfile?> {
  CurrentUserNotifier(this._userService) : super(null) {
    _loadCurrentUser();
  }

  final UserService _userService;

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _userService.getCurrentUser();
      state = user;
    } catch (e) {
      // Handle error silently - user might not be signed in
      state = null;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      final user = await _userService.signIn(email: email, password: password);
      state = user;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String username) async {
    try {
      final user = await _userService.signUp(
        email: email,
        password: password,
        username: username,
      );
      state = user;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    await _userService.signOut();
    state = null;
  }

  Future<void> updateProfile(UserProfile profile) async {
    try {
      final updatedUser = await _userService.updateProfile(profile);
      state = updatedUser;
    } catch (e) {
      // Handle error
    }
  }
}

// Mock Services for Development

class MockUserService implements UserService {
  UserProfile? _currentUser;

  @override
  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserProfile(
      id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      email: email,
      totalPoints: 0,
      currentStreak: 0,
      totalScans: 0,
      joinedAt: DateTime.now(),
    );

    return _currentUser!;
  }

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserProfile(
      id: 'mock_user_existing',
      username: 'MockUser',
      email: email,
      totalPoints: 125,
      currentStreak: 7,
      totalScans: 45,
      joinedAt: DateTime.now().subtract(const Duration(days: 30)),
    );

    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = profile;
    return profile;
  }

  @override
  Future<bool> isSignedIn() async {
    return _currentUser != null;
  }
}

class MockProgressService implements ProgressService {
  @override
  Future<void> recordScan({
    required String userId,
    required String category,
    required int pointsEarned,
    required String classificationData,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In real implementation, this would update the database
  }

  @override
  Future<UserStats> getUserStats(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return const UserStats(
      totalPoints: 125,
      currentStreak: 7,
      longestStreak: 12,
      totalScans: 45,
      weeklyPoints: 35,
      monthlyPoints: 125,
      categoryCounts: {
        'Recyclable': 25,
        'Compostable': 15,
        'Landfill': 3,
        'Hazardous': 2,
      },
    );
  }

  @override
  Future<List<ScanHistoryEntry>> getScanHistory(String userId,
      {int limit = 50}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return List.generate(limit, (index) {
      return ScanHistoryEntry(
        id: 'scan_$index',
        imagePath: '/mock/path/scan_$index.jpg',
        classificationResult:
            '{"category": "Recyclable", "itemType": "Mock Item $index"}',
        pointsEarned: 5,
        scannedAt: DateTime.now().subtract(Duration(days: index)),
      );
    });
  }

  @override
  Future<void> updateUserLocation(String userId, String location) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock implementation
  }
}

class MockLeaderboardService implements LeaderboardService {
  @override
  Future<List<LeaderboardUser>> getWeeklyLeaderboard({int limit = 50}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      const LeaderboardUser(rank: 1, username: "Alex Chen", points: 2450),
      const LeaderboardUser(rank: 2, username: "Sarah Johnson", points: 2320),
      const LeaderboardUser(rank: 3, username: "Mike Wilson", points: 2180),
      const LeaderboardUser(rank: 4, username: "Emma Davis", points: 1950),
      const LeaderboardUser(
          rank: 5, username: "You", points: 1820, isCurrentUser: true),
    ];
  }

  @override
  Future<List<LeaderboardUser>> getMonthlyLeaderboard({int limit = 50}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      const LeaderboardUser(rank: 1, username: "Sarah Johnson", points: 8950),
      const LeaderboardUser(rank: 2, username: "Alex Chen", points: 8720),
      const LeaderboardUser(
          rank: 3, username: "You", points: 7640, isCurrentUser: true),
      const LeaderboardUser(rank: 4, username: "Emma Davis", points: 7320),
      const LeaderboardUser(rank: 5, username: "Mike Wilson", points: 6890),
    ];
  }

  @override
  Future<List<LeaderboardUser>> getLocalLeaderboard(String location,
      {int limit = 50}) async {
    return getWeeklyLeaderboard(limit: limit);
  }

  @override
  Future<UserRankings> getUserRankings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return const UserRankings(
      weeklyRank: 5,
      monthlyRank: 12,
      overallRank: 234,
      localRank: 3,
    );
  }
}
