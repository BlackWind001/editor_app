import 'package:editor_app/base/helpers/ShortcutsAndActionMaps.dart';
import 'package:editor_app/base/models/ShortcutActivators.dart';
import 'package:editor_app/constants/shortcuts.dart';
import 'package:flutter/material.dart';

typedef DefaultWorkspaceActionCallback<T extends Intent> =
    void Function(T intent);

class CmdPIntent extends Intent {
  const CmdPIntent();
}

class EscapeIntent extends Intent {
  const EscapeIntent();
}

ActivatorToIntentMap getCommandPaletteShortcuts() {
  ActivatorToIntentMap map = {};
  shortcutActivators.initialize();

  map[shortcutActivators.activators[SHORTCUT_TOGGLE_COMMAND_PALETTE]!] =
      CmdPIntent();
  map[shortcutActivators.activators[SHORTCUT_UNIVERSAL_ESCAPE_ACTION]!] =
      EscapeIntent();

  return map;
}

IntentToActionMap getCommandPaletteActions({
  required DefaultWorkspaceActionCallback<CmdPIntent> onCmdP,
  required DefaultWorkspaceActionCallback<EscapeIntent> onEscape,
}) {
  return {
    CmdPIntent: CallbackAction<CmdPIntent>(
      onInvoke: (CmdPIntent intent) {
        onCmdP(intent);
      },
    ),

    EscapeIntent: CallbackAction<EscapeIntent>(
      onInvoke: (EscapeIntent intent) {
        onEscape(intent);
      },
    ),
  };
}

ShortcutsAndActionsMaps getCommandPaletteShortcutsAndActions({
  required DefaultWorkspaceActionCallback<CmdPIntent> onCmdP,
  required DefaultWorkspaceActionCallback<EscapeIntent> onEscape,
}) {
  ShortcutsAndActionsMaps res = ShortcutsAndActionsMaps();

  shortcutActivators.initialize();

  res.shortcuts = getCommandPaletteShortcuts();
  res.actions = getCommandPaletteActions(onCmdP: onCmdP, onEscape: onEscape);

  return res;
}
