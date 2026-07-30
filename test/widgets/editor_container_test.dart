import 'dart:io';

import 'package:editor_app/base/components/EditorContainer.dart';
import 'package:editor_app/base/components/EditorLite.dart';
import 'package:editor_app/base/models/DirectoryWatchers.dart';
import 'package:editor_app/base/models/Document.dart';
import 'package:editor_app/base/models/EditorsSetModel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/editor_test_support.dart';
import '../support/fake_file_system.dart';

void main() {
  late FakeFileSystem fs;
  late EditorsSetModel esModel;

  setUp(() {
    fs = FakeFileSystem();
    esModel = EditorsSetModel();
  });

  tearDown(() {
    // Close every remaining editor so scroll controllers / documents clean up.
    for (final editor in List.of(esModel.editors)) {
      esModel.removeEditor(editor.document.id);
    }
    DirectoryWatchers.unregisterAllListeners();
    fs.dispose();
  });

  Future<void> pumpActiveEditor(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapEditor(
        EditorContainer(
          elModel: esModel.activeEditorModel!,
          esModel: esModel,
        ),
      ),
    );
    await tester.pump();
    await settleEditorFocus(tester);
  }

  Future<void> settleLoad(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump();
      final loaded = find.byType(EditorLite).evaluate().isNotEmpty;
      if (loaded) return;
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  testWidgets('renders EditorLite for the active empty document', (tester) async {
    await IOOverrides.runWithIOOverrides(() async {
      await pumpActiveEditor(tester);

      expect(find.byType(EditorLite), findsOneWidget);
      expect(tester.takeException(), isNull);
    }, fs);
  });

  testWidgets('renders the contents of a file-backed document', (tester) async {
    await IOOverrides.runWithIOOverrides(() async {
      fs.seed('/work/sample.txt', 'alpha\nbeta');

      final untitledId = esModel.activeEditorModel!.document.id;
      await esModel.addEditor('/work/sample.txt', makeActiveEditor: true);
      esModel.removeEditor(untitledId);

      await pumpActiveEditor(tester);
      await settleLoad(tester);

      expect(find.byType(EditorLite), findsOneWidget);
      expect(find.text('beta'), findsOneWidget);
    }, fs);
  });

  testWidgets('renders an empty editor for an empty file', (tester) async {
    await IOOverrides.runWithIOOverrides(() async {
      fs.seed('/work/empty.txt', '');

      final untitledId = esModel.activeEditorModel!.document.id;
      await esModel.addEditor('/work/empty.txt', makeActiveEditor: true);
      esModel.removeEditor(untitledId);

      await pumpActiveEditor(tester);
      await settleLoad(tester);

      expect(find.byType(EditorLite), findsOneWidget);
    }, fs);
  });

  testWidgets('addEditor returns null for an unreadable path', (tester) async {
    await IOOverrides.runWithIOOverrides(() async {
      final id = await esModel.addEditor('/work/missing.txt', makeActiveEditor: true);

      expect(id, isNull);
      // Untitled starter tab is still the active editor.
      expect(esModel.activeEditorModel, isNotNull);
      expect(documentStore.getDocument(esModel.activeEditorModel!.document.id), isNotNull);
    }, fs);
  });
}
