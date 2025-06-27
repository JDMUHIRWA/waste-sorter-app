import 'package:flutter_test/flutter_test.dart';
import 'package:waste_sorter_app/main.dart';

void main() {
  testWidgets('Displays Firebase Ready text', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(MyApp());

    // Look for the expected text
    expect(find.text('Firebase Ready ✅'), findsOneWidget);
  });
}
