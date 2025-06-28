import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waste_sorter_app/features/home/screens/home_screen.dart';

void main() {
  group('Home Screen Tests', () {
    testWidgets('Home screen works on small screen', (WidgetTester tester) async {
      // Set a small screen size
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
        ),
      );
      
      // Check for overflow errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('Home screen works on large screen', (WidgetTester tester) async {
      // Set a large screen size
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
        ),
      );
      
      // Check for overflow errors
      expect(tester.takeException(), isNull);
    });
  });
}
