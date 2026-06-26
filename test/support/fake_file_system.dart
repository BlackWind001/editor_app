import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// An in-memory [IOOverrides] so widget tests can drive file loading and saving
/// *through the editor* without touching the real disk or starting an OS
/// directory watcher.
///
/// Why this exists: real `dart:io` futures only progress inside
/// `tester.runAsync`, and `Document.createFromPath` registers a live
/// `Directory.watch()` stream that never lets the test event loop quiesce —
/// together they make file-backed widget tests hang. The fakes here return
/// already-completed futures (so a plain `pump()` drains them) and a watcher
/// stream that emits nothing.
///
/// Run a test body against it with:
/// `await IOOverrides.runWithIOOverrides(() async { ... }, fs);`
base class FakeFileSystem extends IOOverrides {
  final Map<String, String> files = {};
  final Map<String, DateTime> modified = {};
  final List<StreamController<FileSystemEvent>> _watchControllers = [];

  /// Pre-populates a file so the editor can open it.
  void seed(String path, String contents) {
    files[path] = contents;
    modified[path] = DateTime.now();
  }

  /// Cancels any watcher streams handed out during the test.
  void dispose() {
    for (final c in _watchControllers) {
      c.close();
    }
    _watchControllers.clear();
  }

  @override
  File createFile(String path) => _FakeFile(this, path);

  @override
  Directory createDirectory(String path) => _FakeDirectory(this, path);

  Stream<FileSystemEvent> _watch() {
    // A broadcast stream that stays open but never emits: registerListenerForFile
    // can listen and later cancel it, and nothing storms the event loop.
    final controller = StreamController<FileSystemEvent>.broadcast();
    _watchControllers.add(controller);
    return controller.stream;
  }
}

class _FakeFile implements File {
  _FakeFile(this._fs, this.path);

  final FakeFileSystem _fs;

  @override
  final String path;

  @override
  Future<bool> exists() async => _fs.files.containsKey(path);

  @override
  bool existsSync() => _fs.files.containsKey(path);

  @override
  Future<List<String>> readAsLines({Encoding encoding = utf8}) async =>
      const LineSplitter().convert(_fs.files[path] ?? '');

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async =>
      _fs.files[path] ?? '';

  @override
  Future<File> writeAsString(
    String contents, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) async {
    _fs.files[path] = contents;
    _fs.modified[path] = DateTime.now();
    return this;
  }

  @override
  Future<DateTime> lastModified() async =>
      _fs.modified[path] ?? (throw FileSystemException('No such file', path));

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('_FakeFile.${invocation.memberName} is not stubbed');
}

class _FakeDirectory implements Directory {
  _FakeDirectory(this._fs, this.path);

  final FakeFileSystem _fs;

  @override
  final String path;

  @override
  Future<bool> exists() async => true;

  @override
  bool existsSync() => true;

  @override
  Stream<FileSystemEvent> watch({
    int events = FileSystemEvent.all,
    bool recursive = false,
  }) =>
      _fs._watch();

  @override
  Never noSuchMethod(Invocation invocation) => throw UnsupportedError(
      '_FakeDirectory.${invocation.memberName} is not stubbed');
}
