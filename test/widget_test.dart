// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Should now resolve
import 'package:flutter_application_1/main.dart' as app; // ✅ Should now resolve

void main() {
  testWidgets('Splash screen navigates to HomeScreen after 2 seconds', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: app.MyApp())); // ✅ Now recognized
    expect(find.text('Tic Tac Toe'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Choose Your Game Mode'), findsOneWidget);
  });

  testWidgets('Can tap Play vs AI and navigate to GameScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: app.MyApp()));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(find.text('Play vs AI'));
    await tester.pumpAndSettle();
    expect(find.text('vs AI'), findsOneWidget);
  });
}