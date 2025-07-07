import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waste_sorter_app/services/app_services.dart';
import 'package:waste_sorter_app/services/classification_service.dart';
import 'package:waste_sorter_app/models/classification_result.dart';
import 'package:waste_sorter_app/models/user_models.dart';

void main() {
  group('Service Providers Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('classification service provider returns mock service', () {
      final service = container.read(classificationServiceProvider);

      expect(service, isA<MockClassificationService>());
    });

    test('user service provider returns mock service', () {
      final service = container.read(userServiceProvider);

      expect(service, isA<MockUserService>());
    });

    test('progress service provider returns mock service', () {
      final service = container.read(progressServiceProvider);

      expect(service, isA<MockProgressService>());
    });

    test('leaderboard service provider returns mock service', () {
      final service = container.read(leaderboardServiceProvider);

      expect(service, isA<MockLeaderboardService>());
    });

    test('classification service works through provider', () async {
      final service = container.read(classificationServiceProvider);

      final result = await service.classifyImage('/test/image.jpg');

      expect(result, isA<ClassificationResult>());
      expect(result.category,
          isIn(['Recyclable', 'Compostable', 'Landfill', 'Hazardous']));
      expect(result.confidence, greaterThan(0.0));
    });

    test('current user provider handles sign in', () async {
      final notifier = container.read(currentUserProvider.notifier);

      // Initially no user
      expect(container.read(currentUserProvider), isNull);

      // Sign in
      final success = await notifier.signIn('test@example.com', 'password123');

      expect(success, isTrue);
      expect(container.read(currentUserProvider), isNotNull);
      expect(container.read(currentUserProvider)?.email, 'test@example.com');
    });

    test('current user provider handles sign up', () async {
      final notifier = container.read(currentUserProvider.notifier);

      // Sign up
      final success =
          await notifier.signUp('new@example.com', 'password123', 'NewUser');

      expect(success, isTrue);
      expect(container.read(currentUserProvider), isNotNull);
      expect(container.read(currentUserProvider)?.username, 'NewUser');
      expect(container.read(currentUserProvider)?.email, 'new@example.com');
    });

    test('current user provider handles sign out', () async {
      final notifier = container.read(currentUserProvider.notifier);

      // Sign in first
      await notifier.signIn('test@example.com', 'password123');
      expect(container.read(currentUserProvider), isNotNull);

      // Sign out
      await notifier.signOut();
      expect(container.read(currentUserProvider), isNull);
    });

    test('user stats provider returns data when user is signed in', () async {
      final userNotifier = container.read(currentUserProvider.notifier);

      // Sign in user
      await userNotifier.signIn('test@example.com', 'password123');

      // Wait for the future to complete
      final stats = await container.read(userStatsProvider.future);

      expect(stats, isNotNull);
      expect(stats!.totalPoints, 1820);
      expect(stats.currentStreak, 7);
    });

    test('user stats provider returns null when no user signed in', () async {
      // Wait for the future to complete
      final stats = await container.read(userStatsProvider.future);

      expect(stats, isNull);
    });

    test('weekly leaderboard provider returns data', () async {
      // Wait for the future to complete
      final leaderboard =
          await container.read(weeklyLeaderboardProvider.future);

      expect(leaderboard, isNotEmpty);
      expect(leaderboard.first.rank, 1);
      expect(leaderboard.first.username, 'Alex Chen');

      // Should have current user marked
      final currentUsers = leaderboard.where((user) => user.isCurrentUser);
      expect(currentUsers, hasLength(1));
    });

    test('monthly leaderboard provider returns data', () async {
      // Wait for the future to complete
      final leaderboard =
          await container.read(monthlyLeaderboardProvider.future);

      expect(leaderboard, isNotEmpty);
      expect(leaderboard.first.rank, 1);
      expect(leaderboard.first.username, 'Sarah Johnson');
    });
  });

  group('State Management Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('user profile update reflects in provider', () async {
      final notifier = container.read(currentUserProvider.notifier);

      // Sign in
      await notifier.signIn('test@example.com', 'password123');
      final originalUser = container.read(currentUserProvider)!;

      // Update profile
      final updatedProfile = originalUser.copyWith(
        username: 'UpdatedName',
        location: 'New Location',
      );

      await notifier.updateProfile(updatedProfile);

      final currentUser = container.read(currentUserProvider);
      expect(currentUser?.username, 'UpdatedName');
      expect(currentUser?.location, 'New Location');
      expect(currentUser?.email, originalUser.email); // Should remain same
    });

    test('service provider dependencies work correctly', () {
      // All providers should be able to create their services
      expect(
          () => container.read(classificationServiceProvider), returnsNormally);
      expect(() => container.read(userServiceProvider), returnsNormally);
      expect(() => container.read(progressServiceProvider), returnsNormally);
      expect(() => container.read(leaderboardServiceProvider), returnsNormally);
    });

    test('providers are singletons within container', () {
      final service1 = container.read(classificationServiceProvider);
      final service2 = container.read(classificationServiceProvider);

      expect(identical(service1, service2), isTrue);
    });
  });

  group('Error Handling Integration Tests', () {
    test('classification exception handling', () {
      expect(
        () => throw const ClassificationException('Test error'),
        throwsA(isA<ClassificationException>()),
      );

      expect(
        () => throw const ClassificationException('Server error',
            statusCode: 500),
        throwsA(
          predicate<ClassificationException>(
              (e) => e.message == 'Server error' && e.statusCode == 500),
        ),
      );
    });

    test('async error handling in providers', () async {
      final container = ProviderContainer();

      try {
        // This should not throw in normal operation
        final service = container.read(classificationServiceProvider);
        await service.classifyImage('/test/path.jpg');
      } catch (e) {
        fail('Mock service should not throw errors');
      } finally {
        container.dispose();
      }
    });
  });

  group('Performance Tests', () {
    test('classification service timing', () async {
      final container = ProviderContainer();
      final service = container.read(classificationServiceProvider);

      final stopwatch = Stopwatch()..start();
      await service.classifyImage('/test/image.jpg');
      stopwatch.stop();

      // Mock service should simulate realistic timing
      expect(stopwatch.elapsedMilliseconds, greaterThan(2000));
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));

      container.dispose();
    });

    test('leaderboard provider performance', () async {
      final container = ProviderContainer();

      final stopwatch = Stopwatch()..start();
      final leaderboardAsync = container.read(weeklyLeaderboardProvider);
      await leaderboardAsync.when(
        data: (data) => data,
        loading: () => <LeaderboardUser>[],
        error: (error, stack) => <LeaderboardUser>[],
      );
      stopwatch.stop();

      // Should be reasonably fast for mock data
      expect(
          stopwatch.elapsedMilliseconds, lessThan(2000)); // Increased tolerance

      container.dispose();
    });
  });
}
