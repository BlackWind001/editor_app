import 'package:editor_app/base/helpers/ShortcutsAndActionMaps.dart';
import 'package:editor_app/base/models/ShortcutActivators.dart';
import 'package:editor_app/constants/shortcuts.dart';
import 'package:flutter/material.dart';

typedef DefaultWorkspaceActionCallback<T extends Intent> = void Function(T intent);

class CmdPIntent extends Intent {
  const CmdPIntent();
}

ActivatorToIntentMap getCommandPaletteShortcuts() {
  ActivatorToIntentMap map = {};
  shortcutActivators.initialize();

  map[shortcutActivators.activators[SHORTCUT_TOGGLE_COMMAND_PALETTE]!] = CmdPIntent();

  return map;
}


IntentToActionMap getCommandPaletteActions({
  required DefaultWorkspaceActionCallback<CmdPIntent> onCmdP
}) {
  return {
    CmdPIntent: CallbackAction<CmdPIntent>(onInvoke: (CmdPIntent intent) {
      onCmdP(intent);
    })
  };
}


ShortcutsAndActionsMaps getCommandPaletteShortcutsAndActions({
  required DefaultWorkspaceActionCallback<CmdPIntent> onCmdP,
}) {
  ShortcutsAndActionsMaps res = ShortcutsAndActionsMaps();

  shortcutActivators.initialize();

  res.shortcuts = getCommandPaletteShortcuts();
  res.actions = getCommandPaletteActions(onCmdP: onCmdP);

  return res;
}
