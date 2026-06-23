import 'package:editor_app/base/components/EditorContainer.dart';
import 'package:flutter/material.dart';

class Workspace extends StatefulWidget {
  const Workspace({ super.key });

  @override
  State<Workspace> createState() => _Workspace();
}

class _Workspace extends State<Workspace> {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {},
      child: Actions(
        actions: {},
        child: EditorContainer(
          // filePath: '/Users/anirudhms/Desktop/Projects/editor_app/lib/base/components/EditorLite.dart',
        )
      )
    );
  }
}
