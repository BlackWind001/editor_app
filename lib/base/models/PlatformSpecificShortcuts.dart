import 'dart:io';
import 'package:editor_app/constants/shortcuts.dart';
import 'package:flutter/services.dart';

class ShortcutCombo {
  final LogicalKeyboardKey key;
  bool control = false;
  bool shift = false;
  bool alt = false;
  bool meta = false;

  ShortcutCombo({ required this.key, this.control = false, this.shift = false, this.alt = false, this.meta = false });
}

 

var linuxShortcuts = <String, ShortcutCombo>{
  SHORTCUT_QUIT: ShortcutCombo(key: LogicalKeyboardKey.f4, control: true),
  SHORTCUT_ZOOM_IN: ShortcutCombo(key: LogicalKeyboardKey.equal, control: true),
  SHORTCUT_ZOOM_OUT: ShortcutCombo(key: LogicalKeyboardKey.minus, control: true),
  SHORTCUT_SAVE: ShortcutCombo(key: LogicalKeyboardKey.keyS, control: true),
  SHORTCUT_OPEN_WORKSPACE: ShortcutCombo(key: LogicalKeyboardKey.keyO, control: true, shift: true),
  SHORTCUT_OPEN_FILE: ShortcutCombo(key: LogicalKeyboardKey.keyO, control: true),
  SHORTCUT_WORD_END: ShortcutCombo(key:LogicalKeyboardKey.arrowRight, alt: true),
  SHORTCUT_WORD_START: ShortcutCombo(key:LogicalKeyboardKey.arrowLeft, alt: true),
  SHORTCUT_LINE_END: ShortcutCombo(key:LogicalKeyboardKey.end),
  SHORTCUT_LINE_START: ShortcutCombo(key:LogicalKeyboardKey.home)
};

var macShortcuts = <String, ShortcutCombo>{
  SHORTCUT_QUIT: ShortcutCombo(key: LogicalKeyboardKey.keyQ, meta: true),
  SHORTCUT_ZOOM_IN: ShortcutCombo(key: LogicalKeyboardKey.equal, meta: true),
  SHORTCUT_ZOOM_OUT: ShortcutCombo(key: LogicalKeyboardKey.minus, meta: true),
  SHORTCUT_SAVE: ShortcutCombo(key: LogicalKeyboardKey.keyS, meta: true),
  SHORTCUT_OPEN_WORKSPACE: ShortcutCombo(key: LogicalKeyboardKey.keyO, meta: true, shift: true),
  SHORTCUT_OPEN_FILE: ShortcutCombo(key: LogicalKeyboardKey.keyO, meta: true),
  SHORTCUT_WORD_END: ShortcutCombo(key:LogicalKeyboardKey.arrowRight, alt: true),
  SHORTCUT_WORD_START: ShortcutCombo(key:LogicalKeyboardKey.arrowLeft, alt: true),
  SHORTCUT_LINE_END: ShortcutCombo(key:LogicalKeyboardKey.arrowRight, meta: true),
  SHORTCUT_LINE_START: ShortcutCombo(key:LogicalKeyboardKey.arrowLeft, meta: true)
};

class Platformspecificshortcuts {
  var shortcuts = linuxShortcuts;
  bool _initializationDone = false;
  void init () {
    if (_initializationDone) {
      return;
    }
    if (Platform.isMacOS) {
      shortcuts = macShortcuts;
    }

    _initializationDone = true;
  }
}

var platformShortcuts = Platformspecificshortcuts();