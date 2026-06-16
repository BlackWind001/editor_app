import 'package:editor_app/base/models/EditorSettings.dart';
import 'package:editor_app/constants/editor.dart';
import 'package:flutter/material.dart';

// A function that gets the latest value of fontSize and is used as the
// single source of truth for the editor styles.
// This ensures that stuff like cursor click calculation do not go out
// of sync when the text style changes.
TextStyle getContentStyle () {
  return TextStyle(
    color: PRIMARY_TEXT_COLOR,
    fontSize: edSettings.fontSize,
  );
} 