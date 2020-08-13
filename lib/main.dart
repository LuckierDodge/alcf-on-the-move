import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'swatch.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  Widget build(BuildContext context) {
    // TODO
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
//        _showItemDialog(message);
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
//        _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
//        _navigateToItemDetail(message);
      },
    );

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

// TODO
Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
  return null;
}
