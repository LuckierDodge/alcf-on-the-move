import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  Settings();
  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  SettingsState();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text("Settings"),
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemBuilder: (context, i) {
            if (i == 0) {
              return Text("TODO: Figure out what goes here...");
            }
          }
        ),
      );
  }
}
