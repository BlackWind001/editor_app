import 'dart:io';

import 'package:editor_app/base/helpers/FileActions.dart';
import 'package:editor_app/base/helpers/FileLoader.dart';
import 'package:editor_app/base/models/DirectoryWatchers.dart';
import 'package:editor_app/base/models/Document.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Note on coverage: external-change *detection* (Document.handleDirectoryEvents)
  // is not unit-tested here. It is driven only by FileSystemEvents, whose classes
  // are final (no public constructor to fake) and whose real OS watcher delivery
  // is timing-dependent and flaky. The user-visible consequence — refusing to
  // save once the flag is set — is covered deterministically in
  // test/widgets/file_operations_test.dart.

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('editor_helpers_');
  });

  tearDown(() async {
    DirectoryWatchers.unregisterAllListeners();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  group('FileActions', () {
    test('getFileIfExists returns the file when it exists', () async {
      final f = File('${tempDir.path}/a.txt');
      await f.writeAsString('x');
      expect(await FileActions.getFileIfExists(f.path), isNotNull);
    });

    test('getFileIfExists returns null when the file is missing', () async {
      expect(await FileActions.getFileIfExists('${tempDir.path}/nope.txt'), isNull);
    });

    test('getFileLines returns the file lines', () async {
      final f = File('${tempDir.path}/b.txt');
      await f.writeAsString('one\ntwo');
      expect(await FileActions.getFileLines(f), ['one', 'two']);
    });

    test('getFileLines returns null when the file is missing', () async {
      expect(
        await FileActions.getFileLines(File('${tempDir.path}/nope.txt')),
        isNull,
      );
    });

    test('getFileLines returns an empty list for an empty file', () async {
      final f = File('${tempDir.path}/empty.txt');
      await f.writeAsString('');
      expect(await FileActions.getFileLines(f), isEmpty);
    });

    test('saveFile fails for a missing file and does not create it', () async {
      final path = '${tempDir.path}/missing.txt';
      final res = await FileActions.saveFile(File(path), 'data');

      expect(res.success, isFalse);
      expect(res.errMsg, 'File does not exist');
      expect(await File(path).exists(), isFalse);
    });

    test('BUG(saveFile await): writes contents to an existing file', () async {
      // writeAsString is not awaited inside saveFile, so reading immediately
      // afterwards may observe stale content. Asserts the correct behaviour and
      // may flake until the await is added.
      final f = File('${tempDir.path}/save.txt');
      await f.writeAsString('old');

      await FileActions.saveFile(f, 'new');

      expect(await f.readAsString(), 'new');
    });
  });

  group('Fileloader', () {
    test('getFileContentsSync returns the file lines', () async {
      final f = File('${tempDir.path}/c.txt');
      await f.writeAsString('a\nb');
      expect(Fileloader.getFileContentsSync(f.path), ['a', 'b']);
    });

    test('getFileContentsSync throws for a missing file', () {
      expect(
        () => Fileloader.getFileContentsSync('${tempDir.path}/nope.txt'),
        throwsA(isA<FileSystemException>()),
      );
    });
  });

  group('DirectoryWatchers', () {
    test('returns false when the parent directory does not exist', () async {
      final ok = await DirectoryWatchers.registerListenerForFile(
        '/no/such/dir/file.txt',
        (_) {},
      );
      expect(ok, isFalse);
    });

    test('registers files in an existing directory and unregisters cleanly',
        () async {
      final f1 = '${tempDir.path}/one.txt';
      final f2 = '${tempDir.path}/two.txt';

      expect(await DirectoryWatchers.registerListenerForFile(f1, (_) {}), isTrue);
      expect(await DirectoryWatchers.registerListenerForFile(f2, (_) {}), isTrue);

      await DirectoryWatchers.unregisterListenerForFile(f1);
      await DirectoryWatchers.unregisterListenerForFile(f2);
    });

    test('unregisterAllListeners clears everything without throwing', () async {
      await DirectoryWatchers.registerListenerForFile('${tempDir.path}/x.txt', (_) {});
      DirectoryWatchers.unregisterAllListeners();
    });
  });

  group('Document.save', () {
    test('fails when there is no backing file', () async {
      final res = await Document('hello').save();

      expect(res.success, isFalse);
      expect(res.errMsg, 'Document._file is null');
    });

    test('refuses to save when the file was modified externally', () async {
      final f = File('${tempDir.path}/h.txt');
      await f.writeAsString('hi');
      final doc = await Document.createFromPath(f.path);

      doc.hasFileBeenModifiedExternally = true;
      final res = await doc.save();

      expect(res.success, isFalse);
      expect(res.errMsg, 'File has been modified externally');
      doc.cleanup();
    });
  });
}
