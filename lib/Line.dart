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
  late final AnimationController _cursorController;
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addListener(() {
      setState(() {
        _showCursor = _cursorController.value < 0.5;
      });
    })..repeat();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Focus(
      focusNode: _focusNode,
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
            if (_showCursor) 
              Container(
                width: 2,
                height: 16,
                color: Colors.black
              ),
          ]
        )
      )
    );
  }
}