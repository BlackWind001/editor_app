import 'dart:io';

import 'package:editor_app/base/components/EditorLite.dart';
import 'package:editor_app/base/helpers/ShortcutsAndActionMaps.dart';
import 'package:editor_app/base/helpers/mainAppShortcutsAndActions.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.indigo)
      ),
      home: Material(
        textStyle: TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'JetBrainsMono'),
        child: AppContainer(),
      )
    );
  }
}

class AppContainer extends StatefulWidget {
  const AppContainer({ super.key });

  @override
  State<AppContainer> createState() => _AppContainer();
}

class _AppContainer extends State<AppContainer> {
  late ShortcutsAndActionsMaps sAndAMaps;

  void handleQuit(QuitIntent intent) {
    exit(0);
  }

  @override
  void initState() {
    super.initState();
    sAndAMaps = getMainAppShortcutsAndActions(onQuit: handleQuit);
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: sAndAMaps.shortcuts,
      child: Actions(
        actions: sAndAMaps.actions,
        child: EditorLite(
          filePath: '/Users/anirudhms/Desktop/Projects/editor_app/lib/base/components/EditorLite.dart',
          // filePath: '/Users/anirudhms/Desktop/Projects/editor_app/lib/main.dart',
        )
      )
    );
  }
}
