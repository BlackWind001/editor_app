import 'dart:io';

import 'package:editor_app/base/components/EditorContainer.dart';
import 'package:editor_app/base/components/EditorLite.dart';
import 'package:editor_app/base/models/DirectoryWatchers.dart';
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

  // The fake filesystem returns already-completed futures, so a plain pump loop
  // drains the async load; no runAsync and no real OS watcher are involved.
  Future<void> settleLoad(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump();
      final loaded = find.byType(EditorLite).evaluate().isNotEmpty;
      final errored =
          find.text('Error occurred. Please look at the logs.').evaluate().isNotEmpty;
      if (loaded || errored) return;
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  testWidgets('with no file path it loads straight into the editor',
      (tester) async {
    await IOOverrides.runWithIOOverrides(() async {
      await tester.pumpWidget(wrapEditor(EditorContainer()));
      await tester.pump();

      expect(find.byType(EditorLite), findsOneWidget);
      expect(find.text('Loading...'), findsNothing);
      expect(find.text('Error occurred. Please look at the logs.'), findsNothing);
    }, fs);
  });

  testWidgets('shows Loading then renders the file contents', (tester) async {
    await IOOverrides.runWithIOOverrides(() async {
      fs.seed('/work/sample.txt', 'alpha\nbeta');

      await tester.pumpWidget(
        wrapEditor(EditorContainer(filePath: '/work/sample.txt')),
      );
      expect(find.text('Loading...'), findsOneWidget); // first synchronous frame

      await settleLoad(tester);

      expect(find.byType(EditorLite), findsOneWidget);
      expect(find.text('beta'), findsOneWidget);
    }, fs);
  });

  testWidgets('shows an error for an unreadable path', (tester) async {
    await IOOverrides.runWithIOOverrides(() async {
      await tester.pumpWidget(
        wrapEditor(EditorContainer(filePath: '/work/missing.txt')),
      );

      await settleLoad(tester);

      expect(
        find.text('Error occurred. Please look at the logs.'),
        findsOneWidget,
      );
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
}
