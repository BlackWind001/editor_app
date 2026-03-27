import 'package:editor_app/Cursor.dart';
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
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
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

        if (key == null) {
          return KeyEventResult.ignored;
        }

        setState(() {
          lineText += key;
        });
        return KeyEventResult.handled;
      },
      child: Container(
        height: 16,
        width: double.infinity,
        color: Colors.lightGreen,
        child: Row(
          children: [
            Text(lineText),
            if (_focusNode.hasFocus)
              Cursor()
          ]
        )
      )
    );
  }
}