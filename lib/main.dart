import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Lista de Afazeres',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: Container());
  }
}
