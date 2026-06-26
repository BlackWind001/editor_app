import 'package:editor_app/base/components/Cursor.dart';
import 'package:editor_app/base/components/EditorLite.dart';
import 'package:editor_app/base/components/Line.dart';
import 'package:editor_app/base/models/Document.dart';
import 'package:editor_app/base/models/EditorSettings.dart';
import 'package:editor_app/constants/editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/editor_test_support.dart';

void main() {
  // edSettings is a global singleton; keep font size from leaking between tests.
  tearDown(() => edSettings.setFontSize(FONT_SIZE));

  Future<void> pumpEditor(WidgetTester tester, String content) async {
    await tester.pumpWidget(wrapEditor(EditorLite(document: Document(content))));
    await tester.pump(); // post-frame focus for the active line
    await tester.pump();
  }

  Finder caretInLine(int lineIndex) => find.descendant(
        of: find.byType(Line).at(lineIndex),
        matching: find.byType(Cursor),
      );

  // The caret only renders once the newly-active line wins focus, which is
  // requested in a post-frame callback. Pump a couple of frames to settle it.
  Future<void> settleFocus(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('renders every line and its gutter number', (tester) async {
    await pumpEditor(tester, 'hello\nworld');

    expect(find.text('hello'), findsOneWidget);
    expect(find.text('world'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('typing inserts a character at the cursor', (tester) async {
    await pumpEditor(tester, 'hello\nworld');

    await typeChar(tester, LogicalKeyboardKey.keyA, 'a');

    expect(editorDocument(tester).lineAtIndex(0)!.pcStr.piecedValue, 'ahello');
  });

  testWidgets('typing several characters builds up text', (tester) async {
    await pumpEditor(tester, '\n'); // two empty lines

    await typeChar(tester, LogicalKeyboardKey.keyH, 'h');
    await typeChar(tester, LogicalKeyboardKey.keyI, 'i');

    expect(editorDocument(tester).lineAtIndex(0)!.pcStr.piecedValue, 'hi');
  });

  testWidgets('Enter splits the current line into two', (tester) async {
    await pumpEditor(tester, 'hello\nworld');

    await pressKey(tester, LogicalKeyboardKey.arrowRight);
    await pressKey(tester, LogicalKeyboardKey.arrowRight); // cursor at index 2
    await pressKey(tester, LogicalKeyboardKey.enter);

    final doc = editorDocument(tester);
    expect(doc.getLength(), 3);
    expect(doc.lineAtIndex(0)!.pcStr.piecedValue, 'he');
    expect(doc.lineAtIndex(1)!.pcStr.piecedValue, 'llo');
  });

  testWidgets('Backspace deletes the character before the cursor', (tester) async {
    await pumpEditor(tester, 'hello\nworld');

    await pressKey(tester, LogicalKeyboardKey.arrowRight); // index 1
    await pressKey(tester, LogicalKeyboardKey.backspace);

    expect(editorDocument(tester).lineAtIndex(0)!.pcStr.piecedValue, 'ello');
  });

  testWidgets('Backspace at column 0 merges into the previous line',
      (tester) async {
    await pumpEditor(tester, 'hello\nworld');

    await pressKey(tester, LogicalKeyboardKey.arrowDown); // line 1, index 0
    await pressKey(tester, LogicalKeyboardKey.backspace);

    final doc = editorDocument(tester);
    expect(doc.getLength(), 1);
    expect(doc.lineAtIndex(0)!.pcStr.piecedValue, 'helloworld');
  });

  testWidgets('the caret renders only on the active line', (tester) async {
    await pumpEditor(tester, 'hello\nworld');

    expect(find.byType(Cursor), findsOneWidget);
    expect(caretInLine(0), findsOneWidget);
  });

  testWidgets('Arrow Down moves the caret to the next line', (tester) async {
    await pumpEditor(tester, 'hello\nworld');

    await pressKey(tester, LogicalKeyboardKey.arrowDown);
    await settleFocus(tester);

    expect(caretInLine(1), findsOneWidget);
  });

  testWidgets('Arrow Right at end of line wraps to the next line',
      (tester) async {
    await pumpEditor(tester, 'hi\nthere');

    await pressKey(tester, LogicalKeyboardKey.arrowRight);
    await pressKey(tester, LogicalKeyboardKey.arrowRight); // end of 'hi'
    await pressKey(tester, LogicalKeyboardKey.arrowRight); // wrap
    await settleFocus(tester);

    expect(caretInLine(1), findsOneWidget);
  });

  testWidgets('a mouse tap moves the caret to the tapped line', (tester) async {
    await pumpEditor(tester, 'hello\nworld');

    await tester.tap(find.byType(Line).at(1));
    await settleFocus(tester);

    expect(caretInLine(1), findsOneWidget);
  });

  testWidgets('the zoom-in shortcut increases the font size', (tester) async {
    await pumpEditor(tester, 'hello\nworld');
    final before = edSettings.fontSize;

    await sendEditorShortcut(tester, LogicalKeyboardKey.equal);

    expect(edSettings.fontSize, before + 1);
  });

  testWidgets('BUG: longest-line index is wrong after splitting the longest line',
      (tester) async {
    await pumpEditor(tester, 'aaaaa\nbb\nc');

    await pressKey(tester, LogicalKeyboardKey.arrowRight);
    await pressKey(tester, LogicalKeyboardKey.arrowRight); // index 2 of line 0
    await pressKey(tester, LogicalKeyboardKey.enter); // 'aaaaa' -> 'aa','aaa'

    expect(editorDocument(tester).longestLineIndex, 1);
  });
}
