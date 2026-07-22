import 'dart:developer';
import 'dart:io';

import 'package:editor_app/base/components/EditorLite.dart';
import 'package:editor_app/base/models/Document.dart';
import 'package:editor_app/base/models/EditorLiteModel.dart';
import 'package:editor_app/base/models/EditorsSetModel.dart';
import 'package:editor_app/constants/editor.dart';
import 'package:editor_app/types/Callbacks.dart';
import 'package:flutter/widgets.dart';

class EditorContainer extends StatefulWidget{
  EditorLiteModel elModel;
  EditorsSetModel esModel;

  EditorContainer({ super.key, required this.elModel, required this.esModel });

  @override
  State<EditorContainer> createState() => _EditorContainer();
}

class _EditorContainer extends State<EditorContainer> {

  @override
  void dispose () {
    widget.esModel.removeEditor(widget.elModel.document.id);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return EditorLite(model: widget.elModel);
  }
}