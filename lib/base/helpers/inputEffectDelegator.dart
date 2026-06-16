import 'package:editor_app/utils/isShortcut.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef Callback = void Function(KeyEvent event);
typedef InsertCallback = void Function(String? key, KeyEvent event);

KeyEventResult inputEffectDelegator ({
  required KeyEvent event,
  required Callback onShortcut,
  required Callback onDelete,
  required Callback onBackspace,
  required InsertCallback onInsert,
  required Callback onNonKeyDownEvent,
  required Callback onArrowKey
}) {
  String? key = event.character;

  if (event is! KeyDownEvent) {
    onNonKeyDownEvent(event);
    return KeyEventResult.ignored;
  }
  else if (isShortcut()) {
    onShortcut(event);
    return KeyEventResult.handled;
  }

  switch (event.logicalKey) {
    case LogicalKeyboardKey.backspace: {
      onBackspace(event);
      break;
    }
    case LogicalKeyboardKey.delete: {
      onDelete(event);
      break;
    }
    case LogicalKeyboardKey.enter: {
      onInsert(null, event);
      break;
    }
    case LogicalKeyboardKey.arrowUp:
    case LogicalKeyboardKey.arrowDown:
    case LogicalKeyboardKey.arrowLeft:
    case LogicalKeyboardKey.arrowRight: {
      onArrowKey(event);
      break;
    }
    default: {
      if (key == null) {
        return KeyEventResult.ignored;
      }
      onInsert(key, event);
    }
  }


  return KeyEventResult.handled;
}