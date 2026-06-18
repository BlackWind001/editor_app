import 'package:editor_app/constants/editor.dart';

class EditorSettings {
  double fontSize = FONT_SIZE;
  final double lineHeightMultiplier = 1.5;

  void setFontSize (double value) {
    fontSize = value;
  }
}

EditorSettings edSettings = EditorSettings();
