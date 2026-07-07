import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:editor_app/base/components/EditorContainer.dart';
import 'package:editor_app/base/components/TabsHeader.dart';
import 'package:editor_app/base/helpers/ShortcutsAndActionMaps.dart';
import 'package:editor_app/base/helpers/workspaceShortcutsAndActions.dart';
import 'package:editor_app/base/models/DirectoryWatchers.dart';
import 'package:editor_app/base/models/TabsModel.dart' as tm;
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
  late tm.TabsModel tabsModel;
  String? workspacePath;
  List<String> openFiles = [];
  String? activeFilePath;

  @override
  void initState() {
    super.initState();

    tm.SingleTabModel untitledTab = tm.SingleTabModel(
      id: '1',
      type: 'file',
      title: 'Untitled',
      ContentWidget: EditorContainer(filePath: null, onCloseFile: this.closeFile,));

    sAndAMaps = getWorkspaceShortcutsAndActions(onOpenFolder: handleOpenWorkspace, onOpenFile: handleOpenFile);
    tabsModel = tm.TabsModel(tabs: [untitledTab]);
  }

  @override
  void dispose () {
    DirectoryWatchers.unregisterAllListeners();
    super.dispose();
  }

  Future<void> closeFile(String filePath) async {
    String name = 'Workspace~closeFile';
    int fileIndex = openFiles.indexOf(filePath);
    if (fileIndex == -1) {
      log('Failed for $filePath since there was no entry in opened files', name: name);
      throw 'Close failed for $filePath since there was no entry in opened files';
    }

    openFiles.removeAt(fileIndex);
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
      log('Workspace~_handleOW: User has cancelled opening folder');
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
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              TabsHeader(model: tabsModel),
              Expanded(
                child: EditorContainer(
                  onCloseFile: closeFile,
                  filePath: activeFilePath,
                )
              )
            ],
          )
        )
      )
    );
  }
}
