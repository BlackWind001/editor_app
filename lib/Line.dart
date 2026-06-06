import 'package:editor_app/Cursor.dart';
import 'package:editor_app/PiecableString.dart';
import 'package:editor_app/utils/isShortcut.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Line extends StatefulWidget {
  const Line({super.key, required this.text});

  final String text;

  @override
  State<Line> createState() => _Line();
}

class _Line extends State<Line> with SingleTickerProviderStateMixin {
  String lineText = '';
  late PiecableString pcStr;
  late int cursorPosition;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    lineText = widget.text;
    pcStr = PiecableString(originalString: lineText);
    cursorPosition = lineText.length;
     WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Focus(
      autofocus: true,
      focusNode: _focusNode,
      onFocusChange: (hasFocus) => setState(() {}),
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent || isShortcut()) {
          return KeyEventResult.ignored;
        }

        String? key = event.character;


        if (event.logicalKey == LogicalKeyboardKey.backspace) {
          setState(() {
            pcStr.delete(cursorPosition-1, 1);
            cursorPosition -=1;
          });

          return KeyEventResult.handled;
        }
        else if (event.logicalKey == LogicalKeyboardKey.enter) {
          // Add code here to somehow create a new line
        }
        else if (key == null) {
          return KeyEventResult.ignored;
        }
        else {
          setState(() {
            pcStr.insert(cursorPosition, key);
            cursorPosition +=1;
          });
        }
        return KeyEventResult.handled;
      },
      child: Container(
        height: 16,
        width: double.infinity,
        color: Colors.lightGreen,
        child: Row(
          children: [
            Text(pcStr.piecedValue),
            if (_focusNode.hasFocus)
              Cursor()
          ]
        )
      )
    );
  }
}