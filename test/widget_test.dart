// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myapp/main.dart';

void main() {
  testWidgets('Player Selection Screen Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CosmoQuestApp());

    // Verify the initial screen title.
    expect(find.text('Cosmo Quest - Select Players'), findsOneWidget);

    // Verify the default number of players is 2.
    expect(find.text('2 Players'), findsOneWidget);

    // Tap the dropdown to open it.
    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle(); // Wait for animation

    // Tap on the '3 Players' option.
    await tester.tap(find.text('3 Players').last);
    await tester.pumpAndSettle(); // Wait for animation

    // Verify the selection has changed.
    expect(find.text('3 Players'), findsOneWidget);
  });

  testWidgets('Navigation to Game Screen and Title Verification', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CosmoQuestApp());

    // Find the 'Start Game' button and tap it.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Start Game'));
    await tester.pumpAndSettle(); // Wait for the navigation animation to complete.

    // Verify that the GameScreen is displayed with the correct title.
    expect(find.text('Cosmo Quest'), findsOneWidget);
    // Also verify the old title is gone
    expect(find.text('Cosmo Quest - Select Players'), findsNothing);
  });
}
