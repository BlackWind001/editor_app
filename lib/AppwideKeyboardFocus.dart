import 'package:editor_app/AppwideShortcutsMapping.dart';
import 'package:editor_app/utils/isShortcut.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Appwidekeyboardfocus extends StatelessWidget {
  final Widget child;
  const Appwidekeyboardfocus({ super.key, required this.child });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) {
          return KeyEventResult.handled;
        }

        if (isShortcut()) {
          ShortcutKeys key = ShortcutKeys(
            key: event.logicalKey,
            ctrl: HardwareKeyboard.instance.isControlPressed,
            meta: HardwareKeyboard.instance.isMetaPressed,
            alt: HardwareKeyboard.instance.isAltPressed,
            shift: HardwareKeyboard.instance.isShiftPressed
          );

          VoidCallback? handler = AppwideShortcutsMapping().mapping[key.toString()];

          if (handler != null) {
            handler();
          }
        }

        return KeyEventResult.handled;
      },
      child: child
    );
  }
}