// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myapp/main.dart';
import 'package:myapp/screens/game_screen.dart';
import 'packagepackage:myapp/widgets/game_board.dart';

void main() {
  testWidgets('Player Selection Screen Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CosmoQuestApp());

    // Verify the initial screen title.
    expect(find.text('Select Your Warriors'), findsOneWidget);

    // Verify the default number of players is 2.
    expect(find.text('2 Warriors'), findsOneWidget);

    // Tap the dropdown to open it.
    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle(); // Wait for animation

    // Tap on the '3 Warriors' option.
    await tester.tap(find.text('3 Warriors').last);
    await tester.pumpAndSettle(); // Wait for animation

    // Verify the selection has changed.
    expect(find.text('3 Warriors'), findsOneWidget);
  });

  testWidgets('Navigation to Game Screen and Game Board Verification', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CosmoQuestApp());

    // Find the 'Embark on the Quest' button and tap it.
    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Embark on the Quest'),
    );
    await tester
        .pumpAndSettle(); // Wait for the navigation animation to complete.

    // Verify that the GameScreen is displayed.
    expect(find.byType(GameScreen), findsOneWidget);

    // Verify that the GameBoard is displayed.
    expect(find.byType(GameBoard), findsOneWidget);

    // Also verify the old screen's text is gone.
    expect(find.text('Select Your Warriors'), findsNothing);
  });
}
