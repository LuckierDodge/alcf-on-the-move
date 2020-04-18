import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'newspage.dart';
import 'settings.dart';
import 'status.dart';
import 'utils.dart';

/// Dashboard
///
/// The main UI of the application.

class Dashboard extends StatefulWidget {
  Dashboard({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _DashboardState createState() => _DashboardState(title);
}

class _DashboardState extends State<Dashboard> {
  /// Use this to add or remove machines:
  static var machineNames = ["Cooley", "Theta"];
  List<Widget> machineStatuses = [];
  final String title;
  String updatedTime;
  ConnectivityResult connectivity = ConnectivityResult.none;
  _DashboardState(this.title);

  /// Runs before anything else
  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    updatedTime = getTime();
    machineStatuses = _getMachineStatuses();
  }

  /// Builds the widget, complete with Connectivity checking wrapper
  @override
  Widget build(BuildContext context) {
    Widget activeWidget;
    // Check to make sure the device is connected to the internet
    if (connectivity == ConnectivityResult.none) {
      activeWidget = NoConnection();
    } else {
      activeWidget = _machineList();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          // Refresh Button
          new IconButton(
              icon: const Icon(Icons.refresh), onPressed: _refreshStatus),
          // Settings Button
          new IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Settings()));
              }),
          // News Page Button
          new IconButton(
              icon: const Icon(Icons.bookmark),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            NewsPage(title: 'News & Announcements')));
              })
        ],
      ),
      body: RefreshIndicator(
        child: activeWidget,
        onRefresh: _refreshStatus,
      ),
    );
  }

  /// Create the list of machines, one card per machine.
  Widget _machineList() {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemBuilder: (context, i) {
            if (i < machineStatuses.length) {
              // Creates a Status card for the machine
              return machineStatuses[i];
            } else if (i == machineStatuses.length) {
              // Return the Last Updated time at the end
              return Card(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Align(
                      child: Text("Last Updated: $updatedTime"),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
              );
            } else {
              return null;
            }
          });
    } else {
      return ListView.builder(
          padding: const EdgeInsets.all(10.0),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, i) {
            if (i < machineStatuses.length) {
              // Creates a Status card for the machine
              return machineStatuses[i];
            } else if (i == machineStatuses.length) {
              // Return the Last Updated time at the end
              return Card(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Align(
                      child: Text("Last Updated: $updatedTime"),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
              );
            } else {
              return null;
            }
          });
    }
  }

  List<Widget> _getMachineStatuses() {
    List<Widget> newStatuses = [];
    machineNames.forEach((machine) {
      newStatuses.add(Status(machine));
    });
    return newStatuses;
  }

  ///
  /// Helper functions for refreshing and checking connectivity
  ///
  Future<void> _refreshStatus() async {
    emptyMachineStatuses();
    rebuildStatuses();
  }

  emptyMachineStatuses() {
    this.setState(() {
      machineStatuses = [];
    });
  }

  Future<void> rebuildStatuses() async {
    var tempCon = await Connectivity().checkConnectivity();
    this.setState(() {
      connectivity = tempCon;
      updatedTime = getTime();
      machineStatuses = _getMachineStatuses();
    });
  }

  Future<void> _checkConnectivity() async {
    var tempCon = await Connectivity().checkConnectivity();
    setState(() {
      connectivity = tempCon;
    });
  }
}
