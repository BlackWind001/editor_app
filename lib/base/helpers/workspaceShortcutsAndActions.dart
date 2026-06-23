import 'package:editor_app/base/helpers/ShortcutsAndActionMaps.dart';
import 'package:editor_app/base/models/ShortcutActivators.dart';
import 'package:editor_app/constants/shortcuts.dart';
import 'package:flutter/material.dart';

typedef DefaultWorkspaceActionCallback<T extends Intent> = void Function(T intent);

class OpenFolderIntent extends Intent {
  const OpenFolderIntent();
}

class OpenFileIntent extends Intent {
  const OpenFileIntent();
}

ActivatorToIntentMap getWorkspaceShortcuts() {
  ActivatorToIntentMap map = {};
  shortcutActivators.initialize();

  map[shortcutActivators.activators[SHORTCUT_OPEN_WORKSPACE]!] = OpenFolderIntent();
  map[shortcutActivators.activators[SHORTCUT_OPEN_FILE]!] = OpenFileIntent();

  return map;
}


IntentToActionMap getWorkspaceActions({
  required DefaultWorkspaceActionCallback<OpenFolderIntent> onOpenFolder,
  required DefaultWorkspaceActionCallback<OpenFileIntent> onOpenFile
}) {
  return {
    OpenFolderIntent: CallbackAction<OpenFolderIntent>(onInvoke: (OpenFolderIntent intent) {
      onOpenFolder(intent);
    }),
    OpenFileIntent: CallbackAction<OpenFileIntent>(onInvoke: (OpenFileIntent intent) {
      onOpenFile(intent);
    })
  };
}


ShortcutsAndActionsMaps getWorkspaceShortcutsAndActions({
  required DefaultWorkspaceActionCallback<OpenFolderIntent> onOpenFolder,
  required DefaultWorkspaceActionCallback<OpenFileIntent> onOpenFile
}) {
  ShortcutsAndActionsMaps res = ShortcutsAndActionsMaps();

  shortcutActivators.initialize();

  res.shortcuts = getWorkspaceShortcuts();
  res.actions = getWorkspaceActions(onOpenFolder: onOpenFolder, onOpenFile: onOpenFile);

  return res;
}
