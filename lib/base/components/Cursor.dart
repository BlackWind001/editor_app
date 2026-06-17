import 'package:flutter/material.dart';

class Cursor extends StatefulWidget {
  const Cursor({super.key});

  @override
  State<StatefulWidget> createState() => _Cursor();
}

class _Cursor extends State<Cursor> with SingleTickerProviderStateMixin {

  late final AnimationController _cursorController;
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();

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
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    if (_showCursor) {
      return Container(
        width: 2,
        height: double.infinity,
        color: Colors.amber,
        margin: EdgeInsets.symmetric(vertical: 2.0),
      );
    }
    return Container(
        width: 2,
        height: double.infinity,
        color: Colors.transparent,
        margin: EdgeInsets.symmetric(vertical: 2.0),
      );
    
  }
}