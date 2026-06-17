import 'package:editor_app/base/helpers/ShortcutsAndActionMaps.dart';
import 'package:editor_app/base/models/ShortcutActivators.dart';
import 'package:editor_app/constants/shortcuts.dart';
import 'package:flutter/material.dart';

typedef DefaultMainAppActionCallback<T extends Intent> = void Function(T intent);

class QuitIntent extends Intent {
  const QuitIntent();
}

ActivatorToIntentMap getMainAppShortcuts() {
  ActivatorToIntentMap map = {};
  shortcutActivators.initialize();

  map[shortcutActivators.activators[SHORTCUT_QUIT]!] = QuitIntent();

  return map;
}


IntentToActionMap getMainAppActions({
  required DefaultMainAppActionCallback<QuitIntent> onQuit
}) {
  return {
    QuitIntent: CallbackAction<QuitIntent>(onInvoke: (QuitIntent intent) {
      onQuit(intent);
    })
  };
}


ShortcutsAndActionsMaps getMainAppShortcutsAndActions({
  required DefaultMainAppActionCallback<QuitIntent> onQuit
}) {
  ShortcutsAndActionsMaps res = ShortcutsAndActionsMaps();

  shortcutActivators.initialize();

  res.shortcuts = getMainAppShortcuts();
  res.actions = getMainAppActions(onQuit: onQuit);

  return res;
}
