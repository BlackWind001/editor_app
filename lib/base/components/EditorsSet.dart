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
  String? activeFilePath;
  CloseFileCallback onCloseFile;

  EditorsSet({ super.key, required this.onCloseFile, this.activeFilePath });

  @override
  State<EditorsSet> createState() => _EditorsSet();
}

class _EditorsSet extends State<EditorsSet> {
  late EditorsSetModel model;

  @override
  void initState() {
    super.initState();
    
    model = EditorsSetModel();
    print('Finished initState');
  }

  void handleCreateNewTab () {
    model.createEmptyTab();

    setState(() {});
  }

  void handleCloseTab (String id) {
    model.closeTab(id);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print('Building');
    return Container(
      height: double.infinity,
      color: EDITOR_BACKGROUND,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          TabsHeader(
            model: model.tabsModel,
            activeTabId: model.activeTabId,
            onCreateNewTab: handleCreateNewTab,
            onCloseTab: handleCloseTab,
          ),
          Expanded(
            child: EditorContainer(
              onCloseFile: widget.onCloseFile,
              filePath: widget.activeFilePath,
            )
          )
        ],
      )
    );
  }

}