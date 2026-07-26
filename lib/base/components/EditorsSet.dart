import 'dart:developer';

import 'package:editor_app/base/components/EditorContainer.dart';
import 'package:editor_app/base/components/TabsHeader.dart';
import 'package:editor_app/base/models/Document.dart';
import 'package:editor_app/base/models/EditorsSetModel.dart';
import 'package:editor_app/constants/editor.dart';
import 'package:editor_app/types/Callbacks.dart';
import 'package:flutter/material.dart';
import 'package:editor_app/base/models/TabsModel.dart' as tm;

/// Wrapper widget that's supposed to represent
/// a set of editors. A workspace can have multiple
/// editors
class EditorsSet extends StatefulWidget {

  EditorsSet({ super.key });

  @override
  State<EditorsSet> createState() => _EditorsSet();
}

class _EditorsSet extends State<EditorsSet> {
  late EditorsSetModel model;

  @override
  void initState() {
    super.initState();
    
    model = EditorsSetModel();
  }

  void handleCreateNewTab () {
    model.addEditor(null, makeActiveEditor: true);

    setState(() {});
  }

  void handleCloseTab (String id) {
    model.removeEditor(id);

    setState(() {});
  }

  void handleClickOnTab (String id) {
    model.setActiveEditor(id);

    setState(() {});
  }

  Widget getWorkbench () {
    String name = '_EditorsSet~getWorkbench';
    switch (model.state) {
      case READY_STATE.LOADING:
        return Container(
          color: EDITOR_BACKGROUND,
          child: Text('Loading...')
        );
      case READY_STATE.LOADED:
        if (model.activeEditorModel == null) {
          throw('EditorsSetModel is marked as LOADED but the document is null', name: name);
        }
        else {
          return EditorContainer(
            elModel: model.activeEditorModel!,
            esModel: model,
            key: Key(model.activeEditorModel!.document.id)
          );
        }
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      color: EDITOR_BACKGROUND,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          TabsHeader(
            model: model.tabsModel,
            activeTabId: model.activeEditorModel?.document.id,
            onCreateNewTab: handleCreateNewTab,
            onCloseTab: handleCloseTab,
            onClickOnTab: handleClickOnTab
          ),
          Expanded(
            child: getWorkbench()
          )
        ],
      )
    );
  }

}