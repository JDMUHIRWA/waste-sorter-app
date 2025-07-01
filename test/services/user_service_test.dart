import 'package:flutter_test/flutter_test.dart';
import 'package:waste_sorter_app/models/user_models.dart';
import 'package:waste_sorter_app/services/user_service.dart';
import 'package:waste_sorter_app/services/app_services.dart';

void main() {
  group('User Service Tests', () {
    late MockUserService userService;
    late MockProgressService progressService;
    late MockLeaderboardService leaderboardService;

    setUp(() {
      userService = MockUserService();
      progressService = MockProgressService();
      leaderboardService = MockLeaderboardService();
    });

    group('MockUserService', () {
      test('should sign up new user', () async {
        final user = await userService.signUp(
          email: 'test@example.com',
          password: 'password123',
          username: 'TestUser',
        );

        expect(user.username, 'TestUser');
        expect(user.email, 'test@example.com');
        expect(user.totalPoints, 0);
        expect(user.currentStreak, 0);
        expect(user.totalScans, 0);
      });

      test('should sign in existing user', () async {
        final user = await userService.signIn(
          email: 'existing@example.com',
          password: 'password123',
        );

        expect(user.username, 'MockUser');
        expect(user.email, 'existing@example.com');
        expect(user.totalPoints, 125);
        expect(user.currentStreak, 7);
        expect(user.totalScans, 45);
      });

      test('should handle sign out', () async {
        // Sign in first
        await userService.signIn(
          email: 'test@example.com',
          password: 'password123',
        );

        // Should be signed in
        expect(await userService.isSignedIn(), isTrue);

        // Sign out
        await userService.signOut();

        // Should be signed out
        expect(await userService.isSignedIn(), isFalse);
        expect(await userService.getCurrentUser(), isNull);
      });

      test('should update user profile', () async {
        // Sign in first
        final originalUser = await userService.signIn(
          email: 'test@example.com',
          password: 'password123',
        );

        // Update profile
        final updatedUser = originalUser.copyWith(
          username: 'UpdatedUsername',
          location: 'New York, NY',
        );

        final result = await userService.updateProfile(updatedUser);

        expect(result.username, 'UpdatedUsername');
        expect(result.location, 'New York, NY');
        expect(result.email, originalUser.email); // Should remain same
      });
    });

    group('MockProgressService', () {
      test('should record scan successfully', () async {
        // Should not throw any exceptions
        await progressService.recordScan(
          userId: 'test_user_id',
          category: 'Recyclable',
          pointsEarned: 5,
          classificationData: '{"itemType": "Plastic Bottle"}',
        );
      });

      test('should return user stats', () async {
        final stats = await progressService.getUserStats('test_user_id');

        expect(stats.totalPoints, 125);
        expect(stats.currentStreak, 7);
        expect(stats.longestStreak, 12);
        expect(stats.totalScans, 45);
        expect(stats.weeklyPoints, 35);
        expect(stats.monthlyPoints, 125);
        expect(stats.categoryCounts, isA<Map<String, int>>());
        expect(stats.categoryCounts['Recyclable'], 25);
      });

      test('should return scan history', () async {
        final history = await progressService.getScanHistory('test_user_id', limit: 10);

        expect(history, hasLength(10));
        
        for (final scan in history) {
          expect(scan.id, isNotEmpty);
          expect(scan.imagePath, contains('/mock/path/'));
          expect(scan.pointsEarned, 5);
          expect(scan.scannedAt, isA<DateTime>());
        }
      });

      test('should update user location', () async {
        // Should not throw any exceptions
        await progressService.updateUserLocation('test_user_id', 'San Francisco, CA');
      });
    });

    group('MockLeaderboardService', () {
      test('should return weekly leaderboard', () async {
        final leaderboard = await leaderboardService.getWeeklyLeaderboard(limit: 5);

        expect(leaderboard, hasLength(5));
        expect(leaderboard.first.rank, 1);
        expect(leaderboard.first.username, 'Alex Chen');
        expect(leaderboard.first.points, 2450);

        // Should contain current user
        final currentUser = leaderboard.firstWhere((user) => user.isCurrentUser);
        expect(currentUser.username, 'You');
        expect(currentUser.rank, 5);
      });

      test('should return monthly leaderboard', () async {
        final leaderboard = await leaderboardService.getMonthlyLeaderboard(limit: 5);

        expect(leaderboard, hasLength(5));
        expect(leaderboard.first.rank, 1);
        expect(leaderboard.first.username, 'Sarah Johnson');

        // Should contain current user
        final currentUser = leaderboard.firstWhere((user) => user.isCurrentUser);
        expect(currentUser.username, 'You');
        expect(currentUser.rank, 3);
      });

      test('should return local leaderboard', () async {
        final leaderboard = await leaderboardService.getLocalLeaderboard('San Francisco, CA');

        expect(leaderboard, isNotEmpty);
        // Should return same format as weekly for mock
      });

      test('should return user rankings', () async {
        final rankings = await leaderboardService.getUserRankings('test_user_id');

        expect(rankings.weeklyRank, 5);
        expect(rankings.monthlyRank, 12);
        expect(rankings.overallRank, 234);
        expect(rankings.localRank, 3);
      });
    });
  });

  group('User Models Tests', () {
    group('UserProfile', () {
      test('should serialize to JSON correctly', () {
        final profile = UserProfile(
          id: 'user_123',
          username: 'TestUser',
          email: 'test@example.com',
          avatarUrl: 'https://example.com/avatar.jpg',
          location: 'New York, NY',
          totalPoints: 100,
          currentStreak: 5,
          totalScans: 20,
          joinedAt: DateTime(2025, 1, 1),
        );

        final json = profile.toJson();

        expect(json['id'], 'user_123');
        expect(json['username'], 'TestUser');
        expect(json['email'], 'test@example.com');
        expect(json['avatarUrl'], 'https://example.com/avatar.jpg');
        expect(json['location'], 'New York, NY');
        expect(json['totalPoints'], 100);
        expect(json['currentStreak'], 5);
        expect(json['totalScans'], 20);
        expect(json['joinedAt'], '2025-01-01T00:00:00.000');
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'user_456',
          'username': 'AnotherUser',
          'email': 'another@example.com',
          'avatarUrl': null,
          'location': 'Los Angeles, CA',
          'totalPoints': 250,
          'currentStreak': 10,
          'totalScans': 50,
          'joinedAt': '2025-02-01T12:00:00.000Z',
        };

        final profile = UserProfile.fromJson(json);

        expect(profile.id, 'user_456');
        expect(profile.username, 'AnotherUser');
        expect(profile.email, 'another@example.com');
        expect(profile.avatarUrl, isNull);
        expect(profile.location, 'Los Angeles, CA');
        expect(profile.totalPoints, 250);
        expect(profile.currentStreak, 10);
        expect(profile.totalScans, 50);
        expect(profile.joinedAt.year, 2025);
        expect(profile.joinedAt.month, 2);
      });

      test('should create copy with updated values', () {
        final original = UserProfile(
          id: 'user_123',
          username: 'Original',
          email: 'original@example.com',
          totalPoints: 100,
          currentStreak: 5,
          totalScans: 20,
          joinedAt: DateTime(2025, 1, 1),
        );

        final updated = original.copyWith(
          username: 'Updated',
          totalPoints: 150,
        );

        expect(updated.username, 'Updated');
        expect(updated.totalPoints, 150);
        expect(updated.email, 'original@example.com'); // Should remain same
        expect(updated.id, 'user_123'); // Should remain same
      });
    });

    group('LeaderboardUser', () {
      test('should serialize to JSON correctly', () {
        const user = LeaderboardUser(
          rank: 1,
          username: 'TopUser',
          points: 1000,
          avatarUrl: 'https://example.com/top.jpg',
          isCurrentUser: true,
        );

        final json = user.toJson();

        expect(json['rank'], 1);
        expect(json['username'], 'TopUser');
        expect(json['points'], 1000);
        expect(json['avatarUrl'], 'https://example.com/top.jpg');
        expect(json['isCurrentUser'], true);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'rank': 2,
          'username': 'SecondPlace',
          'points': 900,
          'avatarUrl': null,
          'isCurrentUser': false,
        };

        final user = LeaderboardUser.fromJson(json);

        expect(user.rank, 2);
        expect(user.username, 'SecondPlace');
        expect(user.points, 900);
        expect(user.avatarUrl, isNull);
        expect(user.isCurrentUser, false);
      });

      test('should handle missing isCurrentUser field', () {
        final json = {
          'rank': 3,
          'username': 'ThirdPlace',
          'points': 800,
          'avatarUrl': null,
          // Missing isCurrentUser
        };

        final user = LeaderboardUser.fromJson(json);

        expect(user.isCurrentUser, false); // Should default to false
      });
    });

    group('ScanHistoryEntry', () {
      test('should serialize to JSON correctly', () {
        final entry = ScanHistoryEntry(
          id: 'scan_123',
          imagePath: '/path/to/image.jpg',
          classificationResult: '{"category": "Recyclable"}',
          pointsEarned: 5,
          scannedAt: DateTime(2025, 7, 1, 10, 30),
        );

        final json = entry.toJson();

        expect(json['id'], 'scan_123');
        expect(json['imagePath'], '/path/to/image.jpg');
        expect(json['classificationResult'], '{"category": "Recyclable"}');
        expect(json['pointsEarned'], 5);
        expect(json['scannedAt'], '2025-07-01T10:30:00.000');
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'scan_456',
          'imagePath': '/another/path/image.jpg',
          'classificationResult': '{"category": "Compostable"}',
          'pointsEarned': 3,
          'scannedAt': '2025-07-01T15:45:00.000Z',
        };

        final entry = ScanHistoryEntry.fromJson(json);

        expect(entry.id, 'scan_456');
        expect(entry.imagePath, '/another/path/image.jpg');
        expect(entry.classificationResult, '{"category": "Compostable"}');
        expect(entry.pointsEarned, 3);
        expect(entry.scannedAt.hour, 15);
        expect(entry.scannedAt.minute, 45);
      });
    });
  });

  group('Stats Models Tests', () {
    test('UserStats should deserialize from JSON correctly', () {
      final json = {
        'totalPoints': 500,
        'currentStreak': 15,
        'longestStreak': 25,
        'totalScans': 100,
        'weeklyPoints': 75,
        'monthlyPoints': 300,
        'categoryCounts': {
          'Recyclable': 60,
          'Compostable': 30,
          'Landfill': 8,
          'Hazardous': 2,
        },
      };

      final stats = UserStats.fromJson(json);

      expect(stats.totalPoints, 500);
      expect(stats.currentStreak, 15);
      expect(stats.longestStreak, 25);
      expect(stats.totalScans, 100);
      expect(stats.weeklyPoints, 75);
      expect(stats.monthlyPoints, 300);
      expect(stats.categoryCounts['Recyclable'], 60);
      expect(stats.categoryCounts['Hazardous'], 2);
    });

    test('UserRankings should deserialize from JSON correctly', () {
      final json = {
        'weeklyRank': 10,
        'monthlyRank': 25,
        'overallRank': 150,
        'localRank': 5,
      };

      final rankings = UserRankings.fromJson(json);

      expect(rankings.weeklyRank, 10);
      expect(rankings.monthlyRank, 25);
      expect(rankings.overallRank, 150);
      expect(rankings.localRank, 5);
    });

    test('UserRankings should handle missing localRank', () {
      final json = {
        'weeklyRank': 10,
        'monthlyRank': 25,
        'overallRank': 150,
        // Missing localRank
      };

      final rankings = UserRankings.fromJson(json);

      expect(rankings.localRank, isNull);
    });
  });
}
