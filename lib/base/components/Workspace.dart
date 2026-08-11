import 'dart:async';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:editor_app/base/components/CommandPaletteWrapper.dart';
import 'package:editor_app/base/helpers/ShortcutsAndActionMaps.dart';
import 'package:editor_app/base/helpers/workspaceShortcutsAndActions.dart';
import 'package:editor_app/base/models/DirectoryWatchers.dart';
import 'package:editor_app/base/models/WorkspaceModel.dart';
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
  late WorkspaceViewModel model;

  @override
  void initState() {
    super.initState();

    sAndAMaps = getWorkspaceShortcutsAndActions(onOpenFolder: handleOpenWorkspace, onOpenFile: handleOpenFile);
    model = WorkspaceViewModel();

    // testRipGrep();
  }

  Future<void> testRipGrep () async {
    final resourcesDir = path.join(path.dirname(Platform.resolvedExecutable), '..', 'Resources');
    Abi arch = Abi.current();
    String rg;

    if (arch == Abi.macosArm64) {
      rg = path.join(resourcesDir, 'rg-arm');

    }
    else if (arch == Abi.macosX64) {
      rg = path.join(resourcesDir, 'rg-x86');
    }
    else {
      throw('Workspace~testRipGrep: ERROR: Unsupported platform');
    }

    if (!(await File(rg).exists())) {
      throw('Workspace~testRipGrep: ERROR: rg not found');
    }

    final result = await Process.run(rg, ['--version']);
    print('Exit code: ${result.exitCode}');
    print('Stdout: ${result.stdout}');
    print('Stderr: ${result.stderr}');
  }

  @override
  void dispose () {
    DirectoryWatchers.unregisterAllListeners();
    super.dispose();
  }

  Future<void> closeFile(String filePath) async {
    assert(true, "Reimplement the closeFile shortcut somewhere else");
  }

  void _handleOF () async {
    assert(true, "Reimplement the openFile shortcut somewhere else");
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

    model.updatePath(dirPath);
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
        child: CommandPaletteWrapper()
      )
    );
  }
}
