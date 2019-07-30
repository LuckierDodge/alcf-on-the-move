import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

import 'noconnection.dart';
import 'settings.dart';
import 'status.dart';

class Machine extends StatefulWidget {
  final String name;
  Machine(this.name);
  @override
  MachineState createState() => MachineState(name);
}

class MachineState extends State<Machine> {
  final String name;
  final GlobalKey<StatusState> statusKey = new GlobalKey();
  String updatedTime;
  var numRacks;
  ConnectivityResult connectivity = ConnectivityResult.none;
  MachineState(this.name);

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    updatedTime = _getTime();
  }

  @override
  Widget build(BuildContext context) {
    if (connectivity == ConnectivityResult.none) {
      return Scaffold(
        appBar: AppBar(
          title: Text(name),
          actions: <Widget>[
            new IconButton(
                icon: const Icon(Icons.refresh), onPressed: _refreshStatus),
            new IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Settings()));
                }),
          ],
        ),
        body: RefreshIndicator(
          child: NoConnection(),
          onRefresh: _refreshStatus,
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(name),
          actions: <Widget>[
            new IconButton(
                icon: const Icon(Icons.refresh), onPressed: _refreshStatus),
            new IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Settings()));
                }),
          ],
        ),
        body: RefreshIndicator(
          child: _machineInfo(),
          onRefresh: _refreshStatus,
        ),
      );
    }
  }

  Widget _machineInfo() {
    return ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemBuilder: (context, i) {
          if (i == 0) {
            return Status(name, key: statusKey);
          } else {
            var numRacks = _getNumRacks();
            if (i <= numRacks) {
              return null;
            } else if (i == numRacks + 1) {
              return Card(
                child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Text("Last Updated: $updatedTime")),
              );
            } else {
              return null;
            }
          }
        });
  }

  int _getNumRacks() {
    return statusKey.currentState.activity.dimensions.racks;
  }

  Future<void> _refreshStatus() async {
    var tempCon = await Connectivity().checkConnectivity();
    this.setState(() {
      connectivity = tempCon;
      updatedTime = _getTime();
    });
  }

  Future<void> _checkConnectivity() async {
    var tempCon = await Connectivity().checkConnectivity();
    setState(() {
      connectivity = tempCon;
    });
  }

  String _getTime() {
    String month;
    DateTime now = DateTime.now();
    switch (now.month) {
      case 1:
        month = "January";
        break;
      case 2:
        month = "February";
        break;
      case 3:
        month = "March";
        break;
      case 4:
        month = "April";
        break;
      case 5:
        month = "May";
        break;
      case 6:
        month = "June";
        break;
      case 7:
        month = "July";
        break;
      case 8:
        month = "August";
        break;
      case 9:
        month = "September";
        break;
      case 10:
        month = "October";
        break;
      case 11:
        month = "November";
        break;
      case 12:
        month = "December";
        break;
    }
    return "$month ${now.day}, ${now.hour}:${(now.minute < 10) ? "0" + now.minute.toString() : now.minute}:${(now.second < 10) ? "0" + now.second.toString() : now.second}";
  }
}
