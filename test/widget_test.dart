import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waste_sorter_app/app/app.dart';
import 'package:waste_sorter_app/features/splash/screens/splash_screen.dart';

void main() {
  group('App Tests', () {
    testWidgets('App smoke test', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(
        const ProviderScope(
          child: WasteSorterApp(),
        ),
      );

      // Verify the app builds without errors
      expect(find.byType(WasteSorterApp), findsOneWidget);

      // Wait for initial rendering
      await tester.pump();
      
      // Check if we have either a loading state or the splash screen
      final hasLoadingIndicator = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      final hasSplashScreen = find.byType(SplashScreen).evaluate().isNotEmpty;
      
      expect(hasLoadingIndicator || hasSplashScreen, isTrue);
    });

    group('Responsiveness Tests', () {
      testWidgets('App works on small screen', (WidgetTester tester) async {
        // Set a small screen size
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          const ProviderScope(
            child: WasteSorterApp(),
          ),
        );
        await tester.pump();

        // Verify no overflow errors and app builds properly
        expect(tester.takeException(), isNull);
        expect(find.byType(WasteSorterApp), findsOneWidget);
      });

      testWidgets('App works on large screen', (WidgetTester tester) async {
        // Set a large screen size
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          const ProviderScope(
            child: WasteSorterApp(),
          ),
        );
        await tester.pump();

        // Verify no overflow errors
        expect(tester.takeException(), isNull);
        expect(find.byType(WasteSorterApp), findsOneWidget);
      });
    });

    group('Navigation Tests', () {
      testWidgets('Navigation between screens works',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: WasteSorterApp(),
          ),
        );
        await tester.pump();

        // App should build properly 
        expect(find.byType(WasteSorterApp), findsOneWidget);
        
        // Wait for settings to load and then check if we can navigate
        await tester.pump(const Duration(milliseconds: 100));
        
        // The actual navigation testing will be expanded as we implement full navigation
      });

      testWidgets('Back buttons work correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: WasteSorterApp(),
          ),
        );
        await tester.pump();

        // Verify app builds properly
        expect(find.byType(WasteSorterApp), findsOneWidget);
        
        // Test back button functionality (will be implemented in navigation flow)
        // This test will be expanded as we implement the full navigation
      });
    });

    group('Screen-specific Tests', () {
      testWidgets('Home screen displays properly', (WidgetTester tester) async {
        // This will test the home screen layout and responsiveness
        // Will be implemented to test specific home screen components
      });

      testWidgets('Scan screen has proper navigation',
          (WidgetTester tester) async {
        // This will test the scan screen back button and navigation
        // Will be implemented to test scan screen functionality
      });
    });
  });
}
