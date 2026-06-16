import 'dart:io';

import 'package:flutter/services.dart';


const QUIT = 'quit';

class ShortcutCombo {
  final LogicalKeyboardKey key;
  bool control = false;
  bool shift = false;
  bool alt = false;
  bool meta = false;

  ShortcutCombo({ required this.key, this.control = false, this.shift = false, this.alt = false, this.meta = false });
}

 

var linuxShortcuts = <String, ShortcutCombo>{
  QUIT: ShortcutCombo(key: LogicalKeyboardKey.f4, control: true)
};

var macShortcuts = <String, ShortcutCombo>{
  QUIT: ShortcutCombo(key: LogicalKeyboardKey.keyQ, meta: true)
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