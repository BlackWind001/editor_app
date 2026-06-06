import 'dart:io';

import 'package:editor_app/Line.dart';
import 'package:editor_app/base/KeypressWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        colorScheme: .fromSeed(seedColor: Colors.indigo),
      ),
      home: Material(
        textStyle: TextStyle(fontSize: 16, color: Colors.black),
        child: AppContainer(),
      )
    );
  }
}

class AppContainer extends StatelessWidget {
  const AppContainer({super.key});
  @override
  Widget build(BuildContext context) {
    final widget = KeypressWidget(
      child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).colorScheme.inversePrimary,
          child: Align(
              alignment: Alignment.topLeft,
              child: Line(text: 'Hello there, my dear friend')
          )
      ),
    );

    // ToDo: Move the following lines to a separate registerShortcuts function
    // along with other app wide shortcut registrations.
    // Also, only register the necessary platform's shortcuts.
    widget.register(
      const KeyPress(key: LogicalKeyboardKey.keyQ, meta: true),
      () => exit(0),
    );
    widget.register(
      const KeyPress(key: LogicalKeyboardKey.f4, alt: true),
      () => exit(0),
    );

    return widget;
  }
}
