import 'package:flutter_test/flutter_test.dart';
import 'package:waste_sorter_app/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const WasteSorterApp());

    // Verify the app builds without errors
    expect(find.byType(WasteSorterApp), findsOneWidget);
  });
}
