import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waste_sorter_app/features/leaderboard/screens/leaderboard_screen.dart';

void main() {
  group('Leaderboard Screen Tests', () {
    testWidgets('Leaderboard screen works without overflow', (WidgetTester tester) async {
      // Set a small screen size to test overflow
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: const LeaderboardScreen(),
        ),
      );
      
      // Check for overflow errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('Leaderboard podium displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LeaderboardScreen(),
        ),
      );
      
      // Should find the leaderboard title
      expect(find.text('Leaderboard'), findsOneWidget);
      
      // Should find the tabs
      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
    });
  });
}
