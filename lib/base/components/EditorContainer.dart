import 'dart:developer';
import 'dart:io';

import 'package:editor_app/base/components/EditorLite.dart';
import 'package:editor_app/base/models/Document.dart';
import 'package:editor_app/constants/editor.dart';
import 'package:editor_app/types/Callbacks.dart';
import 'package:flutter/widgets.dart';

enum READY_STATE {
  LOADING,
  LOADED,
  ERROR,
  UNINITIALIZED
}

class EditorContainer extends StatefulWidget{

  String? filePath;
  CloseFileCallback? onCloseFile;

  EditorContainer({ super.key, this.filePath, this.onCloseFile });

  @override
  State<EditorContainer> createState() => _EditorContainer();
}

class _EditorContainer extends State<EditorContainer> {
  Document document = documentStore.createEmptyDocument();
  READY_STATE state = READY_STATE.UNINITIALIZED;

  Future<void> handleInitialFileLoadAndRead (String filePath) async {
    state = READY_STATE.LOADING;

    const errorName = 'EditorLite~handleInitialFileLoadAndRead';

    Document? d = await documentStore.createNewDocument(filePath);

    if (d == null) {
      state = READY_STATE.ERROR;
      log('Error: Could not load file: $filePath', name: errorName);
    }
    else {
      document = d;
      state = READY_STATE.LOADED;
    }
    setState(() {});
  }

  @override
  void dispose () {
    documentStore.removeDocument(document.id);
    super.dispose();
  }

  @override
  void didUpdateWidget (oldWidget) {
    super.didUpdateWidget(oldWidget);

    String? oldFilePath = oldWidget.filePath;
    String? filePath = widget.filePath;
    CloseFileCallback? onCloseFile = widget.onCloseFile;

    if (oldFilePath != filePath) {
      if (onCloseFile != null && oldFilePath != null) {

        // NOTE: The following line closes the file since we are
        // only showing one editor at a time. In multi-tab mode,
        // this needs to be removed.
        // This needs to go in dispose ideally.
        // This line allows the parent to clean up.
        onCloseFile(oldFilePath);
        // This line allows the document and its listeners to be cleaned up
       documentStore.removeDocument(document.id);
      }
      if (filePath != null) {
        handleInitialFileLoadAndRead(filePath);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    state = READY_STATE.LOADING;

    if (widget.filePath == null) {
      document = documentStore.createEmptyDocument();
      state = READY_STATE.LOADED;
    }
    else {
      handleInitialFileLoadAndRead(widget.filePath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (state) { 
      case READY_STATE.LOADING:
        return Container(
          color: EDITOR_BACKGROUND,
          child: Text('Loading...')
        );
      case READY_STATE.LOADED:
        return EditorLite(document: document);
      case READY_STATE.ERROR:
        return Container(
          color: EDITOR_BACKGROUND,
          child: Text('Error occurred. Please look at the logs.')
        );
      case READY_STATE.UNINITIALIZED:
        return Container(
          color: EDITOR_BACKGROUND,
          child: Text("You shouldn't be seeing this")
        );
    }
  }
}