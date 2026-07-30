import 'dart:io';

import 'package:editor_app/base/components/EditorLite.dart';
import 'package:editor_app/base/models/Document.dart';
import 'package:editor_app/base/models/EditorLiteModel.dart';
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

/// Builds an [EditorLite] bound to [content] via a fresh [EditorLiteModel].
/// Callers that own the model should [EditorLiteModel.destroy] it when done.
({EditorLite widget, EditorLiteModel model}) editorLiteFor(String content) {
  final model = EditorLiteModel(document: Document(content));
  return (widget: EditorLite(model: model), model: model);
}

/// The live [Document] that the on-screen [EditorLite] is currently editing.
/// Lets a UI-driven test load/edit through the widgets while asserting on the
/// underlying model state.
Document editorDocument(WidgetTester tester) =>
    tester.widget<EditorLite>(find.byType(EditorLite)).model.document;

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
  bool alt = false,
}) async {
  final modifier =
      Platform.isMacOS ? LogicalKeyboardKey.metaLeft : LogicalKeyboardKey.controlLeft;
  await tester.sendKeyDownEvent(modifier);
  if (alt) await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
  if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyEvent(key);
  if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  if (alt) await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
  await tester.sendKeyUpEvent(modifier);
  await tester.pump();
}

/// Platform-correct "activate next editor" chord.
Future<void> sendActivateNextEditorShortcut(WidgetTester tester) async {
  if (Platform.isMacOS) {
    await sendEditorShortcut(tester, LogicalKeyboardKey.arrowRight, alt: true);
  } else {
    await sendEditorShortcut(tester, LogicalKeyboardKey.pageDown);
  }
}

/// Platform-correct "activate previous editor" chord.
Future<void> sendActivatePreviousEditorShortcut(WidgetTester tester) async {
  if (Platform.isMacOS) {
    await sendEditorShortcut(tester, LogicalKeyboardKey.arrowLeft, alt: true);
  } else {
    await sendEditorShortcut(tester, LogicalKeyboardKey.pageUp);
  }
}

/// Post-frame focus for the active line settles after a couple of pumps.
Future<void> settleEditorFocus(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
}
