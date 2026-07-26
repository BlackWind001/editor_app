import 'package:editor_app/base/models/Document.dart';
import 'package:editor_app/constants/editor.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

class EditorLiteModel {
  int cursorLine = 0;
  int cursorIndex = 0;
  late ScrollController vLineScrollController;
  late ScrollController vGutterScrollController;
  late LinkedScrollControllerGroup scrollControllerGroup;
  late ScrollController hScrollController;
  late Document document;
  double lineNumberGutterWidth = GUTTER_WIDTH;
  double longestLineWidth = 0.0;

  EditorLiteModel ({ required this.document }) {
    scrollControllerGroup = LinkedScrollControllerGroup();
    hScrollController = ScrollController();
    vLineScrollController = scrollControllerGroup.addAndGet();
    vGutterScrollController = scrollControllerGroup.addAndGet();
  }

  void destroy () {
    vLineScrollController.dispose();
    vGutterScrollController.dispose();
    hScrollController.dispose();
  }
}