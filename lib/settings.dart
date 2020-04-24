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
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          columnOrderSetting(),
        ],
      ),
    );
  }

  columnOrderSetting() {
    List<Widget> widgetList = [];
    widgetList.add(Text(
      "Job List Column Order",
      style: TextStyle(fontSize: 20),
    ));
    widgetList.add(Divider());
    widgetList.add(Text(
        "Change the order of the columns displayed for the Job List of a machine."));
    return Card(
        child: Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgetList,
      ),
      padding: EdgeInsets.all(10),
    ));
  }
}
