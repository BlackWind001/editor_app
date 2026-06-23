import 'dart:developer';
import 'dart:io';

import 'package:editor_app/base/components/EditorLite.dart';
import 'package:editor_app/base/models/Document.dart';
import 'package:editor_app/constants/editor.dart';
import 'package:flutter/widgets.dart';

enum READY_STATE {
  LOADING,
  LOADED,
  ERROR,
  UNINITIALIZED
}

class EditorContainer extends StatefulWidget{

  String? filePath;

  EditorContainer({ super.key, this.filePath });

  @override
  State<EditorContainer> createState() => _EditorContainer();
}

class _EditorContainer extends State<EditorContainer> {
  Document document = Document('\n');
  READY_STATE state = READY_STATE.UNINITIALIZED;


  Future<void> handleInitialFileLoadAndRead (String filePath) async {
    state = READY_STATE.LOADING;

    const errorName = 'EditorLite~handleInitialFileLoadAndRead';
    try {
      Document d = await Document.createFromPath(filePath);

      document = d;
      state = READY_STATE.LOADED;
    } on FileSystemException catch (fileSysException, trace) {
      log(
        'Error occurred while loading file: $filePath.',
        name: errorName,
        error: fileSysException,
        stackTrace: trace
      );
      state = READY_STATE.ERROR;
    } catch (e, trace) {
      log(
        'Encountered error',
        name: errorName,
        error: e,
        stackTrace: trace
      );
      state = READY_STATE.ERROR;
    }
    finally {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    state = READY_STATE.LOADING;

    if (widget.filePath == null) {
      document = Document('\n');
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