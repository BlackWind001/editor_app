import 'package:editor_app/base/components/EditorLite.dart';
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

class AppContainer extends StatelessWidget {
  const AppContainer({super.key});
  @override
  Widget build(BuildContext context) {
    return EditorLite(
      // filePath: '/Users/anirudhms/Desktop/Projects/editor_app/lib/base/components/EditorLite.dart',
      filePath: '/Users/anirudhms/Desktop/Projects/editor_app/lib/main.dart',
    );
  }
}
