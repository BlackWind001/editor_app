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
};

var macShortcuts = <String, ShortcutCombo>{
  SHORTCUT_QUIT: ShortcutCombo(key: LogicalKeyboardKey.keyQ, meta: true),
  SHORTCUT_ZOOM_IN: ShortcutCombo(key: LogicalKeyboardKey.equal, meta: true),
  SHORTCUT_ZOOM_OUT: ShortcutCombo(key: LogicalKeyboardKey.minus, meta: true),
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