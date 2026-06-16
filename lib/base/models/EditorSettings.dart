import 'package:editor_app/constants/editor.dart';

class EditorSettings {
  double fontSize = FONT_SIZE;

  void setFontSize (double value) {
    fontSize = value;
  }
}

EditorSettings edSettings = EditorSettings();
