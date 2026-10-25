import 'package:editor_app/base/helpers/ShortcutsAndActionMaps.dart';
import 'package:editor_app/base/models/ShortcutActivators.dart';
import 'package:editor_app/constants/shortcuts.dart';
import 'package:flutter/material.dart';

typedef DefaultWorkspaceActionCallback<T extends Intent> =
    void Function(T intent);

class OpenFolderIntent extends Intent {
  const OpenFolderIntent();
}

ActivatorToIntentMap getWorkspaceShortcuts() {
  ActivatorToIntentMap map = {};
  shortcutActivators.initialize();

  map[shortcutActivators.activators[SHORTCUT_OPEN_WORKSPACE]!] =
      OpenFolderIntent();

  return map;
}

IntentToActionMap getWorkspaceActions({
  required DefaultWorkspaceActionCallback<OpenFolderIntent> onOpenFolder,
}) {
  return {
    OpenFolderIntent: CallbackAction<OpenFolderIntent>(
      onInvoke: (OpenFolderIntent intent) {
        onOpenFolder(intent);
      },
    ),
  };
}

ShortcutsAndActionsMaps getWorkspaceShortcutsAndActions({
  required DefaultWorkspaceActionCallback<OpenFolderIntent> onOpenFolder,
}) {
  ShortcutsAndActionsMaps res = ShortcutsAndActionsMaps();

  shortcutActivators.initialize();

  res.shortcuts = getWorkspaceShortcuts();
  res.actions = getWorkspaceActions(onOpenFolder: onOpenFolder);

  return res;
}
