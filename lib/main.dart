import 'package:flutter/material.dart';
import 'package:listuser/user_search.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'user list',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: UserSearch());
  }
}
