import 'dart:io';

import 'package:flutter/services.dart';

class ShortcutKeys {
  final LogicalKeyboardKey key;
  final bool meta;
  final bool ctrl;
  final bool shift;
  final bool alt;

  const ShortcutKeys({
    required this.key,
    this.meta = false,
    this.ctrl = false,
    this.shift = false,
    this.alt = false,
  });

  @override
  String toString () {
    final result = <String>[];
    if (meta) result.add(Platform.isMacOS ? 'Cmd' : 'Win');
    if (ctrl) result.add('Ctrl');
    if (shift) result.add('Shift');
    if (alt) result.add('Alt');
    result.add(key.keyLabel);

    return result.join('+');
  }
}

class PlatformSpecificBindings {
  late VoidCallback handler;
  late ShortcutKeys? windows;
  late ShortcutKeys? mac;
  late ShortcutKeys? linux;

  PlatformSpecificBindings({
    this.windows,
    this.mac,
    this.linux,
    required this.handler
  }) {
    if (windows == null && mac == null && linux == null) {
      throw Exception('No platform registered for the shortcut');
    }
  }
}

class AppwideShortcutsMapping {

  Map<String, VoidCallback> mapping = {};

  static final AppwideShortcutsMapping _instance = AppwideShortcutsMapping._internal();
  factory AppwideShortcutsMapping () => _instance;
  AppwideShortcutsMapping._internal() {

    // QUIT action
    register(PlatformSpecificBindings(
      handler: _onQuit,
      windows: ShortcutKeys(key: LogicalKeyboardKey.f4, alt: true),
      linux: ShortcutKeys(key: LogicalKeyboardKey.f4, alt: true),
      mac: ShortcutKeys(key: LogicalKeyboardKey.keyQ, meta: true)
    ));

    // REGISTER more shortcuts here.
  }


  void _onQuit () {
    exit(0);
  }

  void register (PlatformSpecificBindings binding) {
    VoidCallback handler = binding.handler;
    ShortcutKeys? platformShortcutKey;

    if (Platform.isMacOS) {
      platformShortcutKey = binding.mac;
    }

    else if (Platform.isWindows) {
      platformShortcutKey = binding.windows;
    }

    else {
      platformShortcutKey = binding.linux;
    }

    if (platformShortcutKey == null) {
      return;
    }

    mapping[platformShortcutKey.toString()] = handler;
  }
}