import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart' as path;

typedef HandleDirectoryEventsCallback = void Function(FileSystemEvent);

class _Watcher {
  late StreamSubscription<FileSystemEvent> stream;
  Map<String, HandleDirectoryEventsCallback> filesCallbackMap = {};

  _Watcher({ required this.stream });
}

class _DirectoryWatchers {
  Map<String, _Watcher> _watchers = {};

  void _handleDirEvents (String dirPath, FileSystemEvent event) {
    _Watcher? watcher = _watchers[dirPath];

    if (watcher == null) {
      return;
    }

    watcher.filesCallbackMap.forEach((_, handler) {
      handler(event);
    });
  }

  Future<bool> registerListenerForFile (String filePath, HandleDirectoryEventsCallback onDirectoryEvents) async {
    String dirPath = path.dirname(filePath);

    Directory dir = Directory(dirPath);
    bool exists = await dir.exists();

    if (!exists) {
      return false;
    }

    if (!_watchers.containsKey(dirPath)) {
      StreamSubscription<FileSystemEvent> watcher = dir.watch().listen((event) {
        _handleDirEvents(dirPath, event);
      });
      _watchers[dirPath] = _Watcher(stream: watcher);
    }

    _watchers[dirPath]!.filesCallbackMap[filePath] = onDirectoryEvents;
    return true;
  }

  Future<void> unregisterListenerForFile (String filePath) async {
    String dirPath = path.dirname(filePath);
    _Watcher? watcher = _watchers[dirPath];
    String name = '_DirectoryWatchers~unregisterListenerForFile';

    if (watcher == null) {
      log('Failed for $filePath since there was no listener for the parent directory. Possible memory leak.', name: name);
      return;
    }

    watcher.filesCallbackMap.remove(filePath);

    if (watcher.filesCallbackMap.isEmpty) {
      watcher.stream.cancel();
      _watchers.remove(dirPath);
    }
  }

  void unregisterAllListeners () {
    _watchers.forEach((dirPath, watcher) {
      watcher.stream.cancel();
      watcher.filesCallbackMap.removeWhere((key, value) { return true; });
    });

    _watchers.removeWhere((key, value) { return true; });
  }
}

_DirectoryWatchers DirectoryWatchers = _DirectoryWatchers();
