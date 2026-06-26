import 'dart:io';

import 'package:editor_app/base/components/EditorLite.dart';
import 'package:editor_app/base/models/Document.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps an editor widget with the minimal app scaffolding it needs:
/// a [MaterialApp] for [Directionality]/[MediaQuery] and a [Material] that
/// provides the ambient [DefaultTextStyle] the editor merges its content
/// style into (mirrors what `main.dart` sets up).
Widget wrapEditor(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Material(
      textStyle: const TextStyle(fontSize: 16, color: Colors.black),
      child: child,
    ),
  );
}

/// The live [Document] that the on-screen [EditorLite] is currently editing.
/// Lets a UI-driven test load/edit through the widgets while asserting on the
/// underlying model state.
Document editorDocument(WidgetTester tester) =>
    tester.widget<EditorLite>(find.byType(EditorLite)).document;

/// Types a single printable character through the keyboard, taking the same
/// path a real keypress would into the focused line.
Future<void> typeChar(
  WidgetTester tester,
  LogicalKeyboardKey key,
  String character,
) async {
  await simulateKeyDownEvent(key, character: character);
  await simulateKeyUpEvent(key);
  await tester.pump();
}

/// Presses a non-character key (arrow / enter / backspace).
Future<void> pressKey(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pump();
}

/// Sends a platform-correct editor shortcut chord (meta on macOS, control
/// elsewhere) so tests match whichever activator map the app loads.
Future<void> sendEditorShortcut(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  bool shift = false,
}) async {
  final modifier =
      Platform.isMacOS ? LogicalKeyboardKey.metaLeft : LogicalKeyboardKey.controlLeft;
  await tester.sendKeyDownEvent(modifier);
  if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyEvent(key);
  if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyUpEvent(modifier);
  await tester.pump();
}
