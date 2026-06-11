import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyPress {
  final LogicalKeyboardKey key;
  final bool meta;
  final bool ctrl;
  final bool shift;
  final bool alt;

  const KeyPress({
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

class KeypressWidget extends StatelessWidget {
  final Widget child;
  final Map<String, VoidCallback> mapping = {};

  KeypressWidget({ super.key, required this.child });

  void register(KeyPress k, VoidCallback h) {
    mapping[k.toString()] = h;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) {
          return KeyEventResult.handled;
        }

        KeyPress key = KeyPress(
            key: event.logicalKey,
            ctrl: HardwareKeyboard.instance.isControlPressed,
            meta: HardwareKeyboard.instance.isMetaPressed,
            alt: HardwareKeyboard.instance.isAltPressed,
            shift: HardwareKeyboard.instance.isShiftPressed
          );

          VoidCallback? handler = mapping[key.toString()];

          if (handler != null) {
            try {
              handler();
              return KeyEventResult.handled;
            }
            catch (e) {
              return KeyEventResult.ignored;
            }
          }

        return KeyEventResult.ignored;
      },
      child: child
    );
  }
}