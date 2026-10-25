import 'dart:developer';

import 'package:editor_app/base/models/Document.dart';
import 'package:editor_app/base/models/EditorLiteModel.dart';
import 'package:editor_app/base/models/TabsModel.dart' as tm;
import 'package:path/path.dart';

enum READY_STATE { LOADING, LOADED, ERROR, UNINITIALIZED }

class EditorsSetModel {
  late tm.TabsModel tabsModel;
  late List<EditorLiteModel> editors;
  late EditorLiteModel? activeEditorModel;

  READY_STATE state = READY_STATE.UNINITIALIZED;

  EditorsSetModel() {
    tabsModel = tm.TabsModel();
    editors = [];

    addEditor(null, makeActiveEditor: true);
  }

  void _cleanupEditor(String id) {
    final index = editors.indexWhere((d) => d.document.id == id);

    if (index == -1) {
      log('Tab not found', name: 'EditorsSetModel~_cleanupEditor');
      return;
    }

    final editor = editors[index];

    // Remove from list and call cleanup.
    editors.removeAt(index);
    editor.destroy();
  }

  void removeEditor(String id) {
    state = READY_STATE.LOADING;
    int index = tabsModel.tabs.indexWhere((tab) => tab.id == id);

    if (index == -1) {
      log('Tab not found', name: 'EditorsSetModel~closeTab');

      state = READY_STATE.LOADED;
      return;
    }

    _cleanupEditor(id);
    documentStore.removeDocument(id);
    tabsModel.removeTab(id);

    if (id == activeEditorModel?.document.id) {
      tm.SingleTabModel? tab;
      try {
        tab = tabsModel.tabs.elementAtOrNull(index - 1);
      } catch (e) {
        tab = null;
      }
      if (tabsModel.tabs.isNotEmpty) {
        if (tab != null) {
          setActiveEditor(tab.id);
        } else {
          setActiveEditor(tabsModel.tabs[index].id);
        }
      } else {
        setActiveEditor(null);
        state = READY_STATE.UNINITIALIZED;
        return;
      }
    }

    state = READY_STATE.LOADED;
  }

  void setActiveEditor(String? id) {
    if (id == null) {
      activeEditorModel = null;
      return;
    }

    int eI = editors.indexWhere((d) => d.document.id == id);
    int tI = tabsModel.tabs.indexWhere((t) => t.id == id);

    if (!(tI > -1 && eI > -1)) {
      return;
    }

    activeEditorModel = editors[eI];
  }

  Future<String?> addEditor(
    String? filePath, {
    bool makeActiveEditor = false,
  }) async {
    state = READY_STATE.LOADING;

    const errorName = 'EditorsSetModel~addEditor';
    String? id;

    if (filePath == null) {
      Document d = documentStore.createEmptyDocument();

      editors.add(EditorLiteModel(document: d));
      // Then, create a tab for it in the tabsModel.
      tabsModel.addTab(
        tm.SingleTabModel(id: d.id, type: '', title: 'Untitled'),
      );
      id = d.id;
    } else {
      // For file editor (aka when a filePath has been given)
      Document? d = await documentStore.createNewDocument(filePath);

      if (d == null) {
        log('Error: Could not load file: $filePath', name: errorName);
        state = READY_STATE.ERROR;
        return null;
      }

      editors.add(EditorLiteModel(document: d));
      tabsModel.addTab(
        tm.SingleTabModel(id: d.id, type: 'file', title: basename(filePath)),
      );
      id = d.id;
    }

    if (makeActiveEditor) {
      setActiveEditor(id);
    }

    state = READY_STATE.LOADED;

    return id;
  }
}
