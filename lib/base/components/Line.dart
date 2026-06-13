import 'package:editor_app/base/components/Cursor.dart';
import 'package:editor_app/base/data-structures/PiecableString.dart';
import 'package:editor_app/base/models/Document.dart';
import 'package:flutter/material.dart';

typedef LineKeyEventCallback = KeyEventResult Function(FocusNode node, KeyEvent event);

class Line extends StatefulWidget {
  const Line({super.key, required this.nLine, required this.text, required this.onKeyEvent, required this.cursorIndex});

  final String text;
  final int? cursorIndex;
  final NotifyingLine nLine;
  final LineKeyEventCallback onKeyEvent;

  @override
  State<Line> createState() => _Line();
}

class _Line extends State<Line> with SingleTickerProviderStateMixin {
  String lineText = '';
  late NotifyingLine nLine;
  late PiecableString pcStr;
  late int? cursorIndex;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    lineText = widget.text;
    nLine  = widget.nLine;
    pcStr = PiecableString(originalString: lineText);
    cursorIndex = widget.cursorIndex;
    if (cursorIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    cursorIndex = widget.cursorIndex;
    return Focus(
      autofocus: true,
      focusNode: _focusNode,
      onFocusChange: (hasFocus) => setState(() {}),
      onKeyEvent: (node, event) {
        return widget.onKeyEvent(node, event);
      },
      child: Container(
        height: 32,
        width: double.infinity,
        color: Colors.lightGreen,
        child: ListenableBuilder(listenable: nLine, builder: (BuildContext context, Widget? child) {
          final cp = cursorIndex;

          if (cp == null) {
            return Row(
              children: [
                Text(nLine.pcStr.piecedValue)
              ]
            );
          }
          else {
            return Row(
              children: [
                Text(nLine.pcStr.piecedValue.substring(0, cp)),
                if (_focusNode.hasFocus)
                  Cursor(),
                Text(nLine.pcStr.piecedValue.substring(cp))
              ]
            );
          }
        })
      )
    );
  }
}