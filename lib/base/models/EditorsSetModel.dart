import 'dart:developer';

import 'package:editor_app/base/models/Document.dart';
import 'package:editor_app/base/models/TabsModel.dart' as tm;

class EditorsSetModel {
  late tm.TabsModel tabsModel;
  String? activeTabId;

  EditorsSetModel () {
    tabsModel = tm.TabsModel();
    createEmptyTab();
  }

  void createEmptyTab () {
    Document d = documentStore.createEmptyDocument();
    // Then, create a tab for it in the tabsModel.
    tabsModel.addTab(tm.SingleTabModel(id: d.id, type: '', title: 'Untitled'));
    // Set this tab as the active tab.
    activeTabId = d.id;
  }

  void closeTab (String id) {
    int index = tabsModel.tabs.indexWhere((tab) => tab.id == id);

    if (index == -1) {
      log('Tab not found', name: 'EditorsSetModel~closeTab');
      return;
    }

    documentStore.removeDocument(id);
    tabsModel.removeTab(id);

    if (id == activeTabId) {
      final tab = tabsModel.tabs.elementAtOrNull(index-1);
      if (tabsModel.tabs.isNotEmpty) {
        if (tab != null) {
          activeTabId = tab.id;
        }
        else {
          activeTabId = tabsModel.tabs[index].id;
        }
      }
      else {
        activeTabId = null;
      }
    }
  }

  void setActiveTab (String id) {

  }
}