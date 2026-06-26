import 'package:editor_app/base/components/Cursor.dart';
import 'package:editor_app/base/components/Line.dart';
import 'package:editor_app/base/models/Document.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/editor_test_support.dart';

void main() {
  Widget hostLine(
    NotifyingLine nLine, {
    int? cursorIndex,
    LineKeyEventCallback? onKey,
  }) {
    return wrapEditor(
      Line(
        nLine: nLine,
        text: nLine.pcStr.piecedValue,
        cursorIndex: cursorIndex,
        contentStyle: const TextStyle(),
        onKeyEvent: onKey ?? (node, event) => KeyEventResult.ignored,
      ),
    );
  }

  testWidgets('renders plain text and no caret when cursorIndex is null',
      (tester) async {
    await tester.pumpWidget(hostLine(NotifyingLine('hello'), cursorIndex: null));
    await tester.pump();

    expect(find.text('hello'), findsOneWidget);
    expect(find.byType(Cursor), findsNothing);
  });

  testWidgets('splits the text around a caret when cursorIndex is set',
      (tester) async {
    await tester.pumpWidget(hostLine(NotifyingLine('hello'), cursorIndex: 2));
    await tester.pump(); // post-frame focus request
    await tester.pump();

    expect(find.text('he'), findsOneWidget);
    expect(find.text('llo'), findsOneWidget);
    expect(find.byType(Cursor), findsOneWidget);
  });

  testWidgets('forwards key events to onKeyEvent when focused', (tester) async {
    final received = <LogicalKeyboardKey>[];
    await tester.pumpWidget(hostLine(
      NotifyingLine('hello'),
      cursorIndex: 0,
      onKey: (node, event) {
        received.add(event.logicalKey);
        return KeyEventResult.handled;
      },
    ));
    await tester.pump();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

    expect(received, contains(LogicalKeyboardKey.arrowRight));
  });

  testWidgets('renders the current value of its NotifyingLine', (tester) async {
    // Note: Line.build() reads the line text once and the inner ListenableBuilder
    // closes over that value, so a bare notifyListeners() does not refresh the
    // text on its own (the editor refreshes it by rebuilding the Line via
    // setState). This verifies the rendered text reflects the model at build.
    final nLine = NotifyingLine('hello');
    nLine.insert(0, 'Z'); // model is now 'Zhello'

    await tester.pumpWidget(hostLine(nLine, cursorIndex: null));
    await tester.pump();

    expect(find.text('Zhello'), findsOneWidget);
  });
}
