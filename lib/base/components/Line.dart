import 'package:editor_app/base/components/Cursor.dart';
import 'package:editor_app/base/data-structures/PiecableString.dart';
import 'package:editor_app/base/models/Document.dart';
import 'package:editor_app/constants/editor.dart';
import 'package:flutter/material.dart';

typedef LineKeyEventCallback =
    KeyEventResult Function(FocusNode node, KeyEvent event);
TextStyle contentStyle = TextStyle(
  color: PRIMARY_TEXT_COLOR,
  fontSize: FONT_SIZE
);

class Line extends StatefulWidget {
  const Line({
    super.key,
    required this.nLine,
    required this.text,
    required this.onKeyEvent,
    required this.cursorIndex,
  });

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

  void requestFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void initState() {
    super.initState();
    lineText = widget.text;
    nLine = widget.nLine;
    pcStr = PiecableString(originalString: lineText);
    cursorIndex = widget.cursorIndex;
    if (cursorIndex != null) {
      requestFocus();
    }
  }

  @override
  void didUpdateWidget(covariant Line oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.cursorIndex == null && widget.cursorIndex != null) {
      /**
       * In order to display the cursor, we first need to request focus.
       * This enables actions like arrow-down/up keys to focus another line.
       */
      requestFocus();
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
        height: EDITOR_LINE_HEIGHT,
        width: double.infinity,
        color: cursorIndex == null ? LINE_BACKGROUND : ACTIVE_LINE_BACKGROUND,
        child: ListenableBuilder(
          listenable: nLine,
          builder: (BuildContext context, Widget? child) {
            final cp = cursorIndex;

            if (cp == null) {
              return Row(
                children: [Text(nLine.pcStr.piecedValue, style: contentStyle)],
              );
            } else {
              return Row(
                children: [
                  Text(
                    nLine.pcStr.piecedValue.substring(0, cp),
                    style: contentStyle,
                  ),
                  if (_focusNode.hasFocus) Cursor(),
                  Text(
                    nLine.pcStr.piecedValue.substring(cp),
                    style: contentStyle,
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
