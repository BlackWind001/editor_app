import 'package:editor_app/base/models/PlatformSpecificShortcuts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShortcutActivators {
  SingleActivator quitActivator = SingleActivator(LogicalKeyboardKey.keyQ, meta: true);
  var activators = <String, SingleActivator>{};

  void initialize () {
    platformShortcuts.init();
    platformShortcuts.shortcuts.forEach((shortcut, combo) {
      activators[shortcut] = SingleActivator(combo.key, meta: combo.meta, control: combo.control, alt: combo.alt, shift: combo.shift);
    });
  }
}

var shortcutActivators = ShortcutActivators();