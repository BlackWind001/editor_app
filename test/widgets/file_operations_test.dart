import 'dart:io';

import 'package:editor_app/base/components/EditorContainer.dart';
import 'package:editor_app/base/components/EditorLite.dart';
import 'package:editor_app/base/models/DirectoryWatchers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/editor_test_support.dart';
import '../support/fake_file_system.dart';

void main() {
  late FakeFileSystem fs;

  setUp(() => fs = FakeFileSystem());
  tearDown(() {
    DirectoryWatchers.unregisterAllListeners();
    fs.dispose();
  });

  Future<void> settleLoad(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump();
      if (find.byType(EditorLite).evaluate().isNotEmpty) return;
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  // Lets the save action's async chain (lastModified -> exists -> write) drain.
  Future<void> settleSave(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  group('loading', () {
    testWidgets('renders the file contents as lines and gutter numbers',
        (tester) async {
      await IOOverrides.runWithIOOverrides(() async {
        fs.seed('/work/a.txt', 'alpha\nbeta\ngamma');
        await tester.pumpWidget(
          wrapEditor(EditorContainer(filePath: '/work/a.txt')),
        );
        await settleLoad(tester);

        expect(find.byType(EditorLite), findsOneWidget);
        expect(find.text('beta'), findsOneWidget);
        expect(find.text('gamma'), findsOneWidget);
        expect(find.text('3'), findsOneWidget); // gutter number for line 3
      }, fs);
    });

    testWidgets('renders an empty editor for an empty file', (tester) async {
      await IOOverrides.runWithIOOverrides(() async {
        fs.seed('/work/empty.txt', '');
        await tester.pumpWidget(
          wrapEditor(EditorContainer(filePath: '/work/empty.txt')),
        );
        await settleLoad(tester);

        expect(find.byType(EditorLite), findsOneWidget);
      }, fs);
    });
  });

  group('saving', () {
    testWidgets('editing then saving writes the change back to the file',
        (tester) async {
      await IOOverrides.runWithIOOverrides(() async {
        fs.seed('/work/save.txt', 'hello');
        await tester.pumpWidget(
          wrapEditor(EditorContainer(filePath: '/work/save.txt')),
        );
        await settleLoad(tester);

        await typeChar(tester, LogicalKeyboardKey.keyA, 'a'); // -> 'ahello'
        await sendEditorShortcut(tester, LogicalKeyboardKey.keyS);
        await settleSave(tester);

        expect(fs.files['/work/save.txt'], 'ahello');
      }, fs);
    });

    testWidgets('saving preserves the multi-line structure', (tester) async {
      await IOOverrides.runWithIOOverrides(() async {
        fs.seed('/work/multi.txt', 'one\ntwo');
        await tester.pumpWidget(
          wrapEditor(EditorContainer(filePath: '/work/multi.txt')),
        );
        await settleLoad(tester);

        await pressKey(tester, LogicalKeyboardKey.arrowDown); // line 1, index 0
        await typeChar(tester, LogicalKeyboardKey.keyX, 'X'); // -> 'Xtwo'
        await sendEditorShortcut(tester, LogicalKeyboardKey.keyS);
        await settleSave(tester);

        expect(fs.files['/work/multi.txt'], 'one\nXtwo');
      }, fs);
    });

    testWidgets('typing with no backing file neither crashes nor loses the buffer',
        (tester) async {
      await IOOverrides.runWithIOOverrides(() async {
        await tester.pumpWidget(wrapEditor(EditorContainer())); // filePath == null
        await tester.pump();
        await tester.pump();

        await typeChar(tester, LogicalKeyboardKey.keyA, 'a');
        await sendEditorShortcut(tester, LogicalKeyboardKey.keyS); // fails (logged)
        await settleSave(tester);

        expect(tester.takeException(), isNull);
        expect(editorDocument(tester).lineAtIndex(0)!.pcStr.piecedValue, 'a');
      }, fs);
    });
  });

  group('external modification', () {
    testWidgets('refuses to save once the file is modified externally',
        (tester) async {
      await IOOverrides.runWithIOOverrides(() async {
        fs.seed('/work/ext.txt', 'original');
        await tester.pumpWidget(
          wrapEditor(EditorContainer(filePath: '/work/ext.txt')),
        );
        await settleLoad(tester);

        // Stand in for the watcher having detected an external change.
        editorDocument(tester).hasFileBeenModifiedExternally = true;
        fs.files['/work/ext.txt'] = 'EXTERNAL'; // changed underneath us

        await typeChar(tester, LogicalKeyboardKey.keyZ, 'z'); // buffer -> 'zoriginal'
        await sendEditorShortcut(tester, LogicalKeyboardKey.keyS);
        await settleSave(tester);

        // Save was refused, so our buffer must not have overwritten the file.
        expect(fs.files['/work/ext.txt'], 'EXTERNAL');
      }, fs);
    });
  });
}
