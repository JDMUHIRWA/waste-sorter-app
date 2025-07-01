import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:waste_sorter_app/features/scan/screens/scan_screen.dart';

void main() {
  group('ScanScreen Widget Tests', () {
    testWidgets('ScanScreen displays loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ScanScreen(),
        ),
      );

      // The screen should initially show loading state
      expect(find.text('Initializing camera...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ScanScreen has proper navigation structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ScanScreen(),
        ),
      );

      // Should have a back button in the overlay
      expect(find.byIcon(Icons.arrow_back), findsAtLeastNWidgets(1));
      expect(find.text('Scan Waste Item'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
