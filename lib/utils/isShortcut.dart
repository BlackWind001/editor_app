import 'package:flutter/services.dart';

bool isShortcut () {
    final ctrl = HardwareKeyboard.instance.isControlPressed;
    final meta = HardwareKeyboard.instance.isMetaPressed; // Cmd on macOS
    final alt = HardwareKeyboard.instance.isAltPressed;
    // final shift = HardwareKeyboard.instance.isShiftPressed;

    return (meta || ctrl || alt);
    
  }