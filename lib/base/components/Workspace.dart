import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:editor_app/base/components/EditorContainer.dart';
import 'package:editor_app/base/helpers/ShortcutsAndActionMaps.dart';
import 'package:editor_app/base/helpers/workspaceShortcutsAndActions.dart';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as path;

class Workspace extends StatefulWidget {
  const Workspace({ super.key });

  @override
  State<Workspace> createState() => _Workspace();
}

class _Workspace extends State<Workspace> {

  late ShortcutsAndActionsMaps sAndAMaps;
  String? workspacePath;
  List<String> openFiles = [];
  Map<String, StreamSubscription<FileSystemEvent>> watchers = {};
  String? activeFilePath;

  @override
  void initState() {
    super.initState();

    sAndAMaps = getWorkspaceShortcutsAndActions(onOpenFolder: handleOpenWorkspace, onOpenFile: handleOpenFile);
  }

  @override
  void dispose () {
    watchers.forEach((_, watcher) {
      watcher.cancel();
    });
    watchers.removeWhere((key, value) {
      return true;
    });
    super.dispose();
  }
  

  Future<bool> setupDirectoryListeners (String dirPath) async {
    Directory dir = Directory(dirPath);
    bool exists = await dir.exists();

    if (!exists) {
      return false;
    }

    if (watchers.containsKey(dirPath)) {
      return true;
    }

    StreamSubscription<FileSystemEvent> watcher = dir.watch().listen((event) {
      handleDirectoryEvents(event);
    });

    watchers[dirPath] = watcher;

    return true;
  }

  void handleDirectoryEvents (FileSystemEvent event) {
    String name = 'Workspace~handleDirectoryEvents';
    log('${event.type} ${event.path}',name: name);
  }

  Future<void> closeFile(String filePath) async {
    String dirPath = path.dirname(filePath);
    StreamSubscription<FileSystemEvent>? watcher = watchers[dirPath];
    String name = 'Workspace~removeListenerForFile';
    int fileIndex = openFiles.indexOf(filePath);
    if (fileIndex == -1) {
      log('Failed for $filePath since there was no entry in opened files', name: name);
      return;
    }

    openFiles.removeAt(fileIndex);

    if (watcher == null) {
      log('Failed for $filePath since there was a mismatch between opened files and registered listeners', name: name);
      return;
    }

    if (openFiles.map((e) => path.dirname(e),).contains(dirPath)) {
      log('Not cleaning up the dir listener for $filePath', name: name);
      return;
    }

    log('Closing watcher for directory $dirPath', name: name);
    watcher.cancel();
    watchers.remove(dirPath);
  }

  void _handleOF () async {
    final XFile? openedFile = await openFile();
    final String name = 'Workspace~_handleOF';

    if (openedFile == null) {
      log('User has cancelled opening file', name: name);
      return;
    }

    // Track the file as one of oepned files.
    openFiles.add(openedFile.path);

    // Start listening to parent directory.
    String parentDir = path.dirname(openedFile.path);
    // Add to existing listeners if not present;
    bool isDirListeningSuccess = await setupDirectoryListeners(parentDir);
    // Make sure to dispose.
    if (!isDirListeningSuccess) {
      openFiles.remove(openedFile.path);
      log('Directory listening was not a success. Not opening file.', name: name);
      return;
    }

    setState(() {
      activeFilePath = openedFile.path;
    });

    log('Opening file $activeFilePath', name: name);
  }

  void handleOpenFile (OpenFileIntent intent) {
    _handleOF();
  }

  void _handleOW () async {
    final String? dirPath = await getDirectoryPath();

    if (dirPath == null) {
      print('Workspace~_handleOW: User has cancelled opening folder');
      return;
    }

    workspacePath = dirPath;
  }

  void handleOpenWorkspace(OpenFolderIntent intent) {
    _handleOW();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: sAndAMaps.shortcuts,
      child: Actions(
        actions: sAndAMaps.actions,
        child: EditorContainer(
          filePath: activeFilePath,
          onCloseFile: closeFile,
        )
      )
    );
  }
}
