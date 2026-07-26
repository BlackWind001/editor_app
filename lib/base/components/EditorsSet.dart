import 'dart:developer';

import 'package:editor_app/base/components/EditorContainer.dart';
import 'package:editor_app/base/components/TabsHeader.dart';
import 'package:editor_app/base/helpers/ShortcutsAndActionMaps.dart';
import 'package:editor_app/base/helpers/editorsSetShortcutsAndActions.dart';
import 'package:editor_app/base/models/EditorsSetModel.dart';
import 'package:editor_app/constants/editor.dart';
import 'package:flutter/material.dart';

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
  late ShortcutsAndActionsMaps sAndAMaps;

  @override
  void initState() {
    super.initState();
    
    model = EditorsSetModel();
    sAndAMaps = getEditorsSetShortcutsAndActions(
      onActivateNextEditor: handleActivateNextEditor,
      onActivatePreviousEditor: handleActivatePreviousEditor,
      onCloseCurrentEditor: handleCloseCurrentEditor,
      onCreateNewEditor: handleCreateNewEditor
    );
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

  void handleActivateNextEditor (ActivateNextEditorIntent intent) {
    try {
      if (model.activeEditorModel == null) {
        return;
      }

      final index = model.editors.indexOf(model.activeEditorModel!);

      // Return if
      // The above index was zero or
      // If the index was for the last editor in the array.
      // Eg: [1, 2, 3] -> Current editor: 3 -> next editor shortcut: do nothing
      if (index < 0 || index > (model.editors.length - 2)) {
        return;
      }

      model.setActiveEditor(model.editors[index + 1].document.id);
    }
    catch (e) {
      log('Errored out while switching to next editor: $e', name: 'EditorsSet~handleActivateNextEditor');
      return;
    }
    finally {
      setState(() {});
    }
  }

  void handleActivatePreviousEditor (ActivatePreviousEditorIntent intent) {
    try {
      if (model.activeEditorModel == null) {
        return;
      }

      final index = model.editors.indexOf(model.activeEditorModel!);

      // If index is -1 (element not found) or if index is 0
      // aka element is first element in the array, do nothing.
      if (index <=0 || index >= model.editors.length) {
        return;
      }

      model.setActiveEditor(model.editors[index - 1].document.id);
    }
    catch (e) {
      log('Errored out while switching to next editor: $e', name: 'EditorsSet~handleActivatePreviousEditor');
      return;
    }
    finally {
      setState(() {});
    }
  }

  void handleCloseCurrentEditor (CloseCurrentEditorIntent intent) {
    if (model.activeEditorModel == null) {
      return;
    }

    handleCloseTab(model.activeEditorModel!.document.id);
  }

  void handleCreateNewEditor (CreateNewEditorIntent intent) {
    handleCreateNewTab();
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

    return Shortcuts(
      shortcuts: sAndAMaps.shortcuts,
      child: Actions(
        actions: sAndAMaps.actions,
        child: Container(
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
        )
      )
    );
  }

}