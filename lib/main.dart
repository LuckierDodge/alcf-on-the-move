import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'swatch.dart';

import 'dashboard.dart';

/// Entrance point for the application
void main() => runApp(new MaterialApp(
    home: new MyApp(),
    title: 'ALCF On the Move',
    theme: ThemeData(
        fontFamily: 'ProximaNova',
        primarySwatch: ALCFSwatch['Blue'].materialColor,
        primaryColor: ALCFSwatch['Blue'].materialColor,
        accentColor: ALCFSwatch['lightBlue'].materialColor,
        backgroundColor: ALCFSwatch['Black'].materialColor,
        canvasColor: ALCFSwatch['darkestBlue'].materialColor,
        cardColor: ALCFSwatch['Black'].materialColor,
        dialogBackgroundColor: ALCFSwatch['Black'].materialColor,
        brightness: Brightness.dark)));

//
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    _checkInitialSetup();
    return new SplashScreen(
      seconds: 2,
      navigateAfterSeconds: Dashboard(title: 'ALCF On the Move'),
      title: new Text("ALCF On the Move",
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
      image: new Image(image: AssetImage('assets/icon/logo_anl.png')),
      backgroundColor: Theme.of(context).canvasColor,
      styleTextUnderTheLoader: new TextStyle(),
    );
  }

  _checkInitialSetup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getKeys().isEmpty) {
//      prefs.setStringList("runningJobHeaders", [
//        "Job ID",
//        "Project",
//        "Run Time",
//        "Wall Time",
//        "Nodes",
//        "Mode",
//        "Location",
//      ]);
    }
  }
}
