// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_box/main.dart';

void main() {
  testWidgets('Clicker app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ClickerApp());

    // Verify that our clicker starts with basic elements
    expect(find.text('💎'), findsOneWidget);
    expect(find.text('Очки'), findsOneWidget);

    // Find and tap the clicker button
    await tester.tap(find.text('💎'));
    await tester.pump();

    // The app should still be functional
    expect(find.text('💎'), findsOneWidget);
  });
}
