import 'package:editor_app/base/components/EditorContainer.dart';
import 'package:editor_app/base/components/EditorLite.dart';
import 'package:editor_app/base/components/EditorsSet.dart';
import 'package:editor_app/base/components/TabsHeader.dart';
import 'package:editor_app/base/models/Document.dart';
import 'package:editor_app/base/models/EditorSettings.dart';
import 'package:editor_app/constants/editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/editor_test_support.dart';

void main() {
  tearDown(() => edSettings.setFontSize(FONT_SIZE));

  Future<void> pumpEditorsSet(WidgetTester tester) async {
    await tester.pumpWidget(wrapEditor(EditorsSet()));
    await tester.pump();
    await settleEditorFocus(tester);
  }

  final untitledTabs = find.text('Untitled');
  final addTabButton = find.byIcon(Icons.add);
  final closeTabButtons = find.byIcon(Icons.close);

  Future<void> createTabViaButton(WidgetTester tester) async {
    await tester.tap(addTabButton);
    await tester.pump();
    await settleEditorFocus(tester);
  }

  Future<void> createTabViaShortcut(WidgetTester tester) async {
    await sendEditorShortcut(tester, LogicalKeyboardKey.keyN);
    await settleEditorFocus(tester);
  }

  Future<void> closeActiveTabViaShortcut(WidgetTester tester) async {
    await sendEditorShortcut(tester, LogicalKeyboardKey.keyW);
    await tester.pump();
    await settleEditorFocus(tester);
  }

  group('initial state', () {
    testWidgets('boots with one Untitled tab and an editor', (tester) async {
      await pumpEditorsSet(tester);

      expect(find.byType(TabsHeader), findsOneWidget);
      expect(untitledTabs, findsOneWidget);
      expect(find.byType(EditorLite), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('creating tabs', () {
    testWidgets('the + button opens a new Untitled tab and makes it active',
        (tester) async {
      await pumpEditorsSet(tester);
      final firstDocId = editorDocument(tester).id;

      await createTabViaButton(tester);

      expect(untitledTabs, findsNWidgets(2));
      expect(find.byType(EditorLite), findsOneWidget);
      expect(editorDocument(tester).id, isNot(firstDocId));
    });

    testWidgets('Cmd/Ctrl+N creates a new editor tab', (tester) async {
      await pumpEditorsSet(tester);
      final firstDocId = editorDocument(tester).id;

      await createTabViaShortcut(tester);

      expect(untitledTabs, findsNWidgets(2));
      expect(editorDocument(tester).id, isNot(firstDocId));
    });
  });

  group('closing tabs', () {
    testWidgets('the tab close button removes that tab', (tester) async {
      await pumpEditorsSet(tester);
      await createTabViaButton(tester);
      expect(untitledTabs, findsNWidgets(2));

      await tester.tap(closeTabButtons.at(1));
      await tester.pump();

      expect(untitledTabs, findsOneWidget);
      expect(find.byType(EditorLite), findsOneWidget);
    });

    testWidgets('Cmd/Ctrl+W closes the active editor tab', (tester) async {
      await pumpEditorsSet(tester);
      await createTabViaButton(tester);
      final activeId = editorDocument(tester).id;

      await closeActiveTabViaShortcut(tester);

      expect(untitledTabs, findsOneWidget);
      expect(editorDocument(tester).id, isNot(activeId));
    });

    testWidgets('closing the last tab leaves the uninitialized workbench',
        (tester) async {
      await pumpEditorsSet(tester);

      await tester.tap(closeTabButtons.first);
      await tester.pump();

      expect(untitledTabs, findsNothing);
      expect(find.byType(EditorLite), findsNothing);
      expect(find.text("You shouldn't be seeing this"), findsOneWidget);
    });

    testWidgets('closing the active tab activates a neighbouring tab',
        (tester) async {
      await pumpEditorsSet(tester);
      final firstId = editorDocument(tester).id;
      await createTabViaButton(tester);
      await createTabViaButton(tester);
      // Tabs: [0, 1, 2], active is 2.
      expect(untitledTabs, findsNWidgets(3));

      await closeActiveTabViaShortcut(tester);

      expect(untitledTabs, findsNWidgets(2));
      // Active should fall back to tab 1 (previous neighbour), not the first.
      expect(editorDocument(tester).id, isNot(firstId));
      expect(find.byType(EditorLite), findsOneWidget);
    });
  });

  group('switching tabs', () {
    testWidgets('clicking a tab activates its editor and preserves buffers',
        (tester) async {
      await pumpEditorsSet(tester);

      await typeChar(tester, LogicalKeyboardKey.keyA, 'a');
      final firstId = editorDocument(tester).id;
      expect(editorDocument(tester).lineAtIndex(0)!.pcStr.piecedValue, 'a');

      await createTabViaButton(tester);
      await typeChar(tester, LogicalKeyboardKey.keyB, 'b');
      final secondId = editorDocument(tester).id;
      expect(secondId, isNot(firstId));
      expect(editorDocument(tester).lineAtIndex(0)!.pcStr.piecedValue, 'b');

      await tester.tap(untitledTabs.at(0));
      await tester.pump();
      await settleEditorFocus(tester);

      expect(editorDocument(tester).id, firstId);
      expect(editorDocument(tester).lineAtIndex(0)!.pcStr.piecedValue, 'a');

      await tester.tap(untitledTabs.at(1));
      await tester.pump();
      await settleEditorFocus(tester);

      expect(editorDocument(tester).id, secondId);
      expect(editorDocument(tester).lineAtIndex(0)!.pcStr.piecedValue, 'b');
    });

    testWidgets('next-editor shortcut advances to the following tab',
        (tester) async {
      await pumpEditorsSet(tester);
      await typeChar(tester, LogicalKeyboardKey.keyA, 'a');
      final firstId = editorDocument(tester).id;

      await createTabViaButton(tester);
      await typeChar(tester, LogicalKeyboardKey.keyB, 'b');

      // Switch back to the first tab, then advance with the shortcut.
      await tester.tap(untitledTabs.at(0));
      await tester.pump();
      await settleEditorFocus(tester);
      expect(editorDocument(tester).id, firstId);

      await sendActivateNextEditorShortcut(tester);
      await settleEditorFocus(tester);

      expect(editorDocument(tester).id, isNot(firstId));
      expect(editorDocument(tester).lineAtIndex(0)!.pcStr.piecedValue, 'b');
    });

    testWidgets('previous-editor shortcut returns to the prior tab',
        (tester) async {
      await pumpEditorsSet(tester);
      await typeChar(tester, LogicalKeyboardKey.keyA, 'a');
      final firstId = editorDocument(tester).id;

      await createTabViaButton(tester);
      expect(editorDocument(tester).id, isNot(firstId));

      await sendActivatePreviousEditorShortcut(tester);
      await settleEditorFocus(tester);

      expect(editorDocument(tester).id, firstId);
      expect(editorDocument(tester).lineAtIndex(0)!.pcStr.piecedValue, 'a');
    });

    testWidgets('next-editor shortcut is a no-op on the last tab',
        (tester) async {
      await pumpEditorsSet(tester);
      await createTabViaButton(tester);
      final lastId = editorDocument(tester).id;

      await sendActivateNextEditorShortcut(tester);

      expect(editorDocument(tester).id, lastId);
    });

    testWidgets('previous-editor shortcut is a no-op on the first tab',
        (tester) async {
      await pumpEditorsSet(tester);
      final firstId = editorDocument(tester).id;
      await createTabViaButton(tester);

      await tester.tap(untitledTabs.at(0));
      await tester.pump();
      await settleEditorFocus(tester);
      expect(editorDocument(tester).id, firstId);

      await sendActivatePreviousEditorShortcut(tester);

      expect(editorDocument(tester).id, firstId);
    });

    testWidgets('EditorContainer is keyed by the active document id',
        (tester) async {
      await pumpEditorsSet(tester);
      final firstId = editorDocument(tester).id;
      await createTabViaButton(tester);
      final secondId = editorDocument(tester).id;

      await tester.tap(untitledTabs.at(0));
      await tester.pump();

      expect(find.byKey(Key(firstId)), findsOneWidget);
      expect(find.byType(EditorContainer), findsOneWidget);

      await tester.tap(untitledTabs.at(1));
      await tester.pump();

      expect(find.byKey(Key(firstId)), findsNothing);
      expect(find.byKey(Key(secondId)), findsOneWidget);
      expect(editorDocument(tester).id, secondId);
    });
  });

  group('document store cleanup', () {
    testWidgets('closing a tab removes its document from the store',
        (tester) async {
      await pumpEditorsSet(tester);
      await createTabViaButton(tester);
      final closedId = editorDocument(tester).id;

      await closeActiveTabViaShortcut(tester);

      expect(documentStore.getDocument(closedId), isNull);
      expect(documentStore.getDocument(editorDocument(tester).id), isNotNull);
    });
  });
}
