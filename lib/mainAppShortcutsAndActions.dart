import 'package:editor_app/base/models/ShortcutActivators.dart';
import 'package:flutter/material.dart';

class QuitIntent extends Intent {
  const QuitIntent();
}

typedef IntentToActionMap = Map<Type, Action<Intent>>;
typedef DefaultMainAppActionCallback<T extends Intent> = void Function(T intent);
typedef ActivatorToIntentMap = Map<ShortcutActivator, Intent>;

ActivatorToIntentMap getMainAppShortcuts() {
  ActivatorToIntentMap map = {};
  shortcutActivators.initialize();

  map[shortcutActivators.quitActivator] = QuitIntent();

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

class ShortcutsAndActionsMaps {
  ActivatorToIntentMap shortcuts = {};
  IntentToActionMap actions = {};
}

ShortcutsAndActionsMaps getShortcutsAndActions({
  required DefaultMainAppActionCallback<QuitIntent> onQuit
}) {
  ShortcutsAndActionsMaps res = ShortcutsAndActionsMaps();

  shortcutActivators.initialize();

  res.shortcuts = getMainAppShortcuts();
  res.actions = getMainAppActions(onQuit: onQuit);

  return res;
}
