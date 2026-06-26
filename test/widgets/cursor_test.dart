import 'package:editor_app/base/components/Cursor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host() => const MaterialApp(
        home: Scaffold(
          body: Center(child: SizedBox(height: 20, child: Cursor())),
        ),
      );

  Container caret(WidgetTester tester) => tester.widget<Container>(
        find.descendant(of: find.byType(Cursor), matching: find.byType(Container)),
      );

  testWidgets('renders a 2px-wide caret container', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump();

    expect(caret(tester).constraints?.maxWidth, 2);
  });

  testWidgets('blinks: caret colour toggles across the animation', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(); // value ~0 -> visible

    final visible = caret(tester).color;
    await tester.pump(const Duration(milliseconds: 500)); // value ~0.55 -> hidden
    final hidden = caret(tester).color;

    expect(visible, isNot(hidden));
    expect(hidden, Colors.transparent);
  });
}
