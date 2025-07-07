import 'package:flutter_test/flutter_test.dart';
import 'package:waste_sorter_app/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WasteSorterApp());
    expect(find.byType(WasteSorterApp), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}
