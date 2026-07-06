import 'package:editor_app/constants/editor.dart';
import 'package:flutter/material.dart';

class EditorSettings extends ChangeNotifier {
  double fontSize = FONT_SIZE;
  final double lineHeightMultiplier = 1.5;

  void setFontSize (double value) {
    fontSize = value;
    notifyListeners();
  }
}

EditorSettings edSettings = EditorSettings();
