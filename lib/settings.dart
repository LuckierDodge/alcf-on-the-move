import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  Settings();
  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  SettingsState();
  bool _refreshToggle = true;
  var _refreshInterval = 60;
  SharedPreferences prefs;
  @override
  Widget build(BuildContext context) {
    _getSettings();
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Settings"),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          _columnOrderSetting(),
          _refreshAndSyncSettings(),
          _notificationsSettings(),
        ],
      ),
    );
  }

  _getSettings() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _refreshToggle = prefs.getBool("refreshToggle");
      _refreshInterval = prefs.getInt("refreshInterval");
    });
  }

  _columnOrderSetting() {
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

  _refreshAndSyncSettings() {
    List<Widget> widgetList = [];
    widgetList.add(Text(
      "Refresh and Sync Settings",
      style: TextStyle(fontSize: 20),
    ));
    widgetList.add(SwitchListTile(
        value: _refreshToggle,
        onChanged: (bool value) => {
              setState(() {
                prefs.setBool("refreshToggle", value);
                _refreshToggle = value;
              })
            },
        title: const Text('Automatic Refresh'),
        subtitle: const Text(
            'Determines whether or not the app will automatically fetch and display the latest machine statuses.'),
        secondary: const Icon(Icons.refresh)));
    widgetList.add(Row(
      children: [
        Container(child: Icon(Icons.access_time), padding: EdgeInsets.all(16)),
        Container(
          child: DropdownButton(
            items: [
              DropdownMenuItem(child: Text("Never"), value: 0),
              DropdownMenuItem(child: Text("Every 30 seconds"), value: 30),
              DropdownMenuItem(child: Text("Every 1 minute"), value: 60),
              DropdownMenuItem(child: Text("Every 5 minutes"), value: 60 * 5),
              DropdownMenuItem(child: Text("Every 15 minutes"), value: 60 * 15),
              DropdownMenuItem(child: Text("Every 30 minutes"), value: 60 * 30),
              DropdownMenuItem(child: Text("Every 1 hour"), value: 60 * 60),
            ],
            onChanged: (var value) {
              setState(() {
                prefs.setInt("refreshInterval", value);
                _refreshInterval = value;
              });
            },
            value: _refreshInterval,
          ),
          padding: EdgeInsets.all(16.0),
        )
      ],
    ));
    return Card(
        child: Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgetList,
      ),
      padding: EdgeInsets.all(10),
    ));
  }

  _notificationsSettings() {
    List<Widget> widgetList = [];
    widgetList.add(Text(
      "Notifications",
      style: TextStyle(fontSize: 20),
    ));

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
