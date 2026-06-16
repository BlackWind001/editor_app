import 'package:editor_app/base/components/Cursor.dart';
import 'package:editor_app/base/models/Document.dart';
import 'package:editor_app/constants/editor.dart';
import 'package:flutter/material.dart';

typedef LineKeyEventCallback =
    KeyEventResult Function(FocusNode node, KeyEvent event);

class Line extends StatefulWidget {
  const Line({
    super.key,
    required this.nLine,
    required this.text,
    required this.onKeyEvent,
    required this.cursorIndex,
    required this.contentStyle
  });

  final String text;
  final int? cursorIndex;
  final NotifyingLine nLine;
  final TextStyle contentStyle;
  final LineKeyEventCallback onKeyEvent;

  @override
  State<Line> createState() => _Line();
}

class _Line extends State<Line> with SingleTickerProviderStateMixin {
  late NotifyingLine nLine;
  late int? cursorIndex;
  late TextStyle contentStyle;
  final FocusNode _focusNode = FocusNode();

  void requestFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void initState() {
    super.initState();
    nLine = widget.nLine;
    cursorIndex = widget.cursorIndex;
    contentStyle = widget.contentStyle;
    if (cursorIndex != null) {
      requestFocus();
    }
  }

  @override
  void didUpdateWidget(covariant Line oldWidget) {
    super.didUpdateWidget(oldWidget);

    cursorIndex = widget.cursorIndex;
    nLine = widget.nLine;
    contentStyle = widget.contentStyle;

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
    String currentLineText = nLine.pcStr.piecedValue;

    return Focus(
      autofocus: true,
      focusNode: _focusNode,
      onFocusChange: (hasFocus) => setState(() {}),
      onKeyEvent: (node, event) {
        return widget.onKeyEvent(node, event);
      },
      child: Container(
        height: EDITOR_LINE_HEIGHT,
        color: cursorIndex == null ? LINE_BACKGROUND : ACTIVE_LINE_BACKGROUND,
        child: MouseRegion(
          cursor: SystemMouseCursors.text,
          child: ListenableBuilder(
            listenable: nLine,
            builder: (BuildContext context, Widget? child) {
              final cp = cursorIndex;
  
              if (cp == null) {
                return Row(
                  children: [Text(currentLineText, style: contentStyle)],
                );
              } else {
                return Row(
                  children: [
                    Text(
                      currentLineText.substring(0, cp),
                      style: contentStyle,
                    ),
                    if (_focusNode.hasFocus) Cursor(),
                    Text(
                      currentLineText.substring(cp),
                      style: contentStyle,
                    ),
                  ],
                );
              }
            }
          ),
        ),
      ),
    );
  }
}
