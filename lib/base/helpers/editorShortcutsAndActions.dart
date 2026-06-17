import 'package:editor_app/base/helpers/ShortcutsAndActionMaps.dart';
import 'package:editor_app/base/models/ShortcutActivators.dart';
import 'package:editor_app/constants/shortcuts.dart';
import 'package:flutter/material.dart';

typedef DefaultEditorActionCallback<T extends Intent> = void Function(T intent);

class ZoomInIntent extends Intent {
  const ZoomInIntent();
}
class ZoomOutIntent extends Intent {
  const ZoomOutIntent();
}

ActivatorToIntentMap getEditorShortcuts() {
  ActivatorToIntentMap map = {};
  shortcutActivators.initialize();

  map[shortcutActivators.activators[SHORTCUT_ZOOM_IN]!] = ZoomInIntent();
  map[shortcutActivators.activators[SHORTCUT_ZOOM_OUT]!] = ZoomOutIntent();

  return map;
}


IntentToActionMap getEditorActions({
  required DefaultEditorActionCallback<ZoomInIntent> onZoomIn,
  required DefaultEditorActionCallback<ZoomOutIntent> onZoomOut
}) {
  return {
    ZoomInIntent: CallbackAction<ZoomInIntent>(onInvoke: (ZoomInIntent intent) {
      onZoomIn(intent);
    }),
    ZoomOutIntent: CallbackAction<ZoomOutIntent>(onInvoke: (ZoomOutIntent intent) {
      onZoomOut(intent);
    })
  };
}


ShortcutsAndActionsMaps getEditorShortcutsAndActions({
  required DefaultEditorActionCallback<ZoomInIntent> onZoomIn,
  required DefaultEditorActionCallback<ZoomOutIntent> onZoomOut
}) {
  ShortcutsAndActionsMaps res = ShortcutsAndActionsMaps();

  shortcutActivators.initialize();

  res.shortcuts = getEditorShortcuts();
  res.actions = getEditorActions(onZoomIn: onZoomIn, onZoomOut: onZoomOut);

  return res;
}
