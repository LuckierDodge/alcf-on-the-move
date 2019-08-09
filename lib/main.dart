import 'package:flutter/material.dart';

import 'dashboard.dart';

/// Entrance point for the application
void main() => runApp(MyApp());

//
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALCF On The Move',
      theme: ThemeData(
        primarySwatch: Colors.green,
        // For Light Theme: Brightness.light
        // For Dark Theme: Brightness.dark
        brightness: Brightness.dark,
      ),
      // App launches to the Dashboard
      home: Dashboard(title: 'ALCF On The Move'),
    );
  }
}
