import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Components
import 'package:editor_app/base/components/Line.dart';
import 'package:editor_app/base/components/KeypressWidget.dart';

// Models
import 'package:editor_app/base/models/Document.dart';

// Utils
import 'package:editor_app/utils/isShortcut.dart';

class EditorLite extends StatefulWidget {
  @override
  State<EditorLite> createState() => _EditorLite();
}

class _EditorLite extends State<EditorLite> {
  String textOnDisk = '';
  int cursorLine = 0;
  int cursorIndex = 0;
  late List<String> lines;
  late Document document;

  @override
  void initState() {
    super.initState();
    textOnDisk = 'Hey there.\nWhatcha doing?';

    textOnDisk.split('\n');
    document = Document(textOnDisk);
    lines = textOnDisk.split('\n');
  }

  KeyEventResult handleKeyEvent (int lineIndex, FocusNode node, KeyEvent event) {
      if (event is! KeyDownEvent || isShortcut()) {
        return KeyEventResult.ignored;
      }

      String? key = event.character;
      NotifyingLine nLine = document.lineAtIndex(cursorLine);
      int updatedIndex = cursorIndex, updatedLine = cursorLine;

      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        nLine.delete(cursorIndex - 1, 1);
        if (cursorIndex == 0) {
          if (cursorLine != 0) {
            updatedLine -= 1;
          }
        }
        else {
          updatedIndex -= 1;
        }
      }
      else if (event.logicalKey == LogicalKeyboardKey.enter) {
        // Add code here to somehow create a new line
      } else if (key == null) {
        return KeyEventResult.ignored;
      } else {
        nLine.insert(cursorIndex, key);
        updatedIndex +=1;
      }

     setState(() {
      cursorIndex = updatedIndex;
      cursorLine = updatedLine;
     });

      return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final widget = KeypressWidget(
      child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).colorScheme.inversePrimary,
          child: ListView.builder(
            itemCount: document.getLength(),
            itemBuilder: (context, i) {
              var cPos = cursorLine == i ? cursorIndex : null;
              return Line(
                text: lines[i],
                onKeyEvent: (FocusNode node, KeyEvent event) => handleKeyEvent(i, node, event),
                nLine: document.lineAtIndex(i),
                cursorIndex: cPos
              );
            }
          )
      ),
    );

    // ToDo: Move the following lines to a separate registerShortcuts function
    // along with other app wide shortcut registrations.
    // Also, only register the necessary platform's shortcuts.
    widget.register(
      const KeyPress(key: LogicalKeyboardKey.keyQ, meta: true),
      () => exit(0),
    );
    widget.register(
      const KeyPress(key: LogicalKeyboardKey.f4, alt: true),
      () => exit(0),
    );

    return widget;
  }
}