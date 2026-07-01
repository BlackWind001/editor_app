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

class SaveIntent extends Intent {
  const SaveIntent();
}

class WordEndIntent extends Intent {
  const WordEndIntent();
}
class WordStartIntent extends Intent {
  const WordStartIntent();
}
class LineEndIntent extends Intent {
  const LineEndIntent();
}
class LineStartIntent extends Intent {
  const LineStartIntent();
}

ActivatorToIntentMap getEditorShortcuts() {
  ActivatorToIntentMap map = {};
  shortcutActivators.initialize();

  map[shortcutActivators.activators[SHORTCUT_ZOOM_IN]!] = ZoomInIntent();
  map[shortcutActivators.activators[SHORTCUT_ZOOM_OUT]!] = ZoomOutIntent();
  map[shortcutActivators.activators[SHORTCUT_SAVE]!] = SaveIntent();
  map[shortcutActivators.activators[SHORTCUT_WORD_END]!] = WordEndIntent();
  map[shortcutActivators.activators[SHORTCUT_WORD_START]!] = WordStartIntent();
  map[shortcutActivators.activators[SHORTCUT_LINE_END]!] = LineEndIntent();
  map[shortcutActivators.activators[SHORTCUT_LINE_START]!] = LineStartIntent();

  return map;
}


IntentToActionMap getEditorActions({
  required DefaultEditorActionCallback<ZoomInIntent> onZoomIn,
  required DefaultEditorActionCallback<ZoomOutIntent> onZoomOut,
  required DefaultEditorActionCallback<SaveIntent> onSave,
  required DefaultEditorActionCallback<WordEndIntent> onWordEnd,
  required DefaultEditorActionCallback<WordStartIntent> onWordStart,
  required DefaultEditorActionCallback<LineEndIntent> onLineEnd,
  required DefaultEditorActionCallback<LineStartIntent> onLineStart,
}) {
  return {
    ZoomInIntent: CallbackAction<ZoomInIntent>(onInvoke: (ZoomInIntent intent) {
      onZoomIn(intent);
    }),
    ZoomOutIntent: CallbackAction<ZoomOutIntent>(onInvoke: (ZoomOutIntent intent) {
      onZoomOut(intent);
    }),
    SaveIntent: CallbackAction<SaveIntent>(onInvoke: (SaveIntent intent) {
      onSave(intent);
    }),
    WordEndIntent: CallbackAction<WordEndIntent>(onInvoke: (WordEndIntent intent) {
      onWordEnd(intent);
    }),
    WordStartIntent: CallbackAction<WordStartIntent>(onInvoke: (WordStartIntent intent) {
      onWordStart(intent);
    }),
    LineEndIntent: CallbackAction<LineEndIntent>(onInvoke: (LineEndIntent intent) {
      onLineEnd(intent);
    }),
    LineStartIntent: CallbackAction<LineStartIntent>(onInvoke: (LineStartIntent intent) {
      onLineStart(intent);
    }),
  };
}


ShortcutsAndActionsMaps getEditorShortcutsAndActions({
  required DefaultEditorActionCallback<ZoomInIntent> onZoomIn,
  required DefaultEditorActionCallback<ZoomOutIntent> onZoomOut,
  required DefaultEditorActionCallback<SaveIntent> onSave,
  required DefaultEditorActionCallback<WordEndIntent> onWordEnd,
  required DefaultEditorActionCallback<WordStartIntent> onWordStart,
  required DefaultEditorActionCallback<LineEndIntent> onLineEnd,
  required DefaultEditorActionCallback<LineStartIntent> onLineStart,
}) {
  ShortcutsAndActionsMaps res = ShortcutsAndActionsMaps();

  shortcutActivators.initialize();

  res.shortcuts = getEditorShortcuts();
  res.actions = getEditorActions(
    onZoomIn: onZoomIn,
    onZoomOut: onZoomOut,
    onSave: onSave,
    onWordEnd: onWordEnd,
    onWordStart: onWordStart,
    onLineEnd: onLineEnd,
    onLineStart: onLineStart,
  );

  return res;
}
