import 'package:editor_app/AppwideKeyboardFocus.dart';
import 'package:editor_app/Line.dart';
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
    return Appwidekeyboardfocus(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.inversePrimary,
        child: Align(
          alignment: Alignment.topLeft,
          child: Line(text: '')
        ),
      )
    );
  }
}
