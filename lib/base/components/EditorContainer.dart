import 'package:editor_app/base/components/EditorLite.dart';
import 'package:editor_app/base/models/EditorLiteModel.dart';
import 'package:editor_app/base/models/EditorsSetModel.dart';
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return EditorLite(model: widget.elModel);
  }
}