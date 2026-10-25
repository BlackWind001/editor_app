import 'package:editor_app/base/helpers/ShortcutsAndActionMaps.dart';
import 'package:editor_app/base/models/ShortcutActivators.dart';
import 'package:editor_app/constants/shortcuts.dart';
import 'package:flutter/material.dart';

typedef DefaultEditorSetActionCallback<T extends Intent> =
    void Function(T intent);

class ActivateNextEditorIntent extends Intent {
  const ActivateNextEditorIntent();
}

class ActivatePreviousEditorIntent extends Intent {
  const ActivatePreviousEditorIntent();
}

class CloseCurrentEditorIntent extends Intent {
  const CloseCurrentEditorIntent();
}

class CreateNewEditorIntent extends Intent {
  const CreateNewEditorIntent();
}

class OpenFileIntent extends Intent {
  const OpenFileIntent();
}

ActivatorToIntentMap getEditorsSetShortcuts() {
  ActivatorToIntentMap map = {};
  shortcutActivators.initialize();

  map[shortcutActivators.activators[SHORTCUT_ACTIVATE_NEXT_EDITOR]!] =
      ActivateNextEditorIntent();
  map[shortcutActivators.activators[SHORTCUT_ACTIVATE_PREVIOUS_EDITOR]!] =
      ActivatePreviousEditorIntent();
  map[shortcutActivators.activators[SHORTCUT_CLOSE_CURRENT_EDITOR]!] =
      CloseCurrentEditorIntent();
  map[shortcutActivators.activators[SHORTCUT_CREATE_NEW_EDITOR]!] =
      CreateNewEditorIntent();
  map[shortcutActivators.activators[SHORTCUT_OPEN_FILE]!] = OpenFileIntent();

  return map;
}

IntentToActionMap getEditorsSetActions({
  required DefaultEditorSetActionCallback<ActivateNextEditorIntent>
  onActivateNextEditor,
  required DefaultEditorSetActionCallback<ActivatePreviousEditorIntent>
  onActivatePreviousEditor,
  required DefaultEditorSetActionCallback<CloseCurrentEditorIntent>
  onCloseCurrentEditor,
  required DefaultEditorSetActionCallback<CreateNewEditorIntent>
  onCreateNewEditor,
  required DefaultEditorSetActionCallback<OpenFileIntent> onOpenFile,
}) {
  return {
    ActivateNextEditorIntent: CallbackAction<ActivateNextEditorIntent>(
      onInvoke: (ActivateNextEditorIntent intent) {
        onActivateNextEditor(intent);
      },
    ),
    ActivatePreviousEditorIntent: CallbackAction<ActivatePreviousEditorIntent>(
      onInvoke: (ActivatePreviousEditorIntent intent) {
        onActivatePreviousEditor(intent);
      },
    ),
    CloseCurrentEditorIntent: CallbackAction<CloseCurrentEditorIntent>(
      onInvoke: (CloseCurrentEditorIntent intent) {
        onCloseCurrentEditor(intent);
      },
    ),
    CreateNewEditorIntent: CallbackAction<CreateNewEditorIntent>(
      onInvoke: (CreateNewEditorIntent intent) {
        onCreateNewEditor(intent);
      },
    ),
    OpenFileIntent: CallbackAction<OpenFileIntent>(
      onInvoke: (OpenFileIntent intent) {
        onOpenFile(intent);
      },
    ),
  };
}

ShortcutsAndActionsMaps getEditorsSetShortcutsAndActions({
  required DefaultEditorSetActionCallback<ActivateNextEditorIntent>
  onActivateNextEditor,
  required DefaultEditorSetActionCallback<ActivatePreviousEditorIntent>
  onActivatePreviousEditor,
  required DefaultEditorSetActionCallback<CloseCurrentEditorIntent>
  onCloseCurrentEditor,
  required DefaultEditorSetActionCallback<CreateNewEditorIntent>
  onCreateNewEditor,
  required DefaultEditorSetActionCallback<OpenFileIntent> onOpenFile,
}) {
  ShortcutsAndActionsMaps res = ShortcutsAndActionsMaps();

  shortcutActivators.initialize();

  res.shortcuts = getEditorsSetShortcuts();
  res.actions = getEditorsSetActions(
    onActivateNextEditor: onActivateNextEditor,
    onActivatePreviousEditor: onActivatePreviousEditor,
    onCloseCurrentEditor: onCloseCurrentEditor,
    onCreateNewEditor: onCreateNewEditor,
    onOpenFile: onOpenFile,
  );

  return res;
}
