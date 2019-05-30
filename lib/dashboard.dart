import 'package:flutter/material.dart';
import 'status.dart';
import 'package:connectivity/connectivity.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _DashboardState createState() => _DashboardState(title);
}

class _DashboardState extends State<Dashboard> {
  static var machineNames = ["Mira", "Cetus", "Vesta", "Cooley", "Theta"];
  List<GlobalKey<StatusState>> statusKeys =
      new List<GlobalKey<StatusState>>(machineNames.length);
  final String title;
  DateTime updatedTime = DateTime.now();
  _DashboardState(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(title),
        ),
        actions: <Widget>[
          new IconButton(
              icon: const Icon(Icons.refresh), onPressed: _refreshStatus)
        ],
      ),
      body: RefreshIndicator(
        child: _machineList(),
        onRefresh: _refreshStatus,
      ),
    );
  }

  Widget _machineList() {
    return ListView.builder(
        padding: const EdgeInsets.all(32.0),
        itemBuilder: (context, i) {
          if (i < machineNames.length) {
            GlobalKey<StatusState> machineKey = new GlobalKey();
            statusKeys[i] = machineKey;
            return Status(machineNames[i], key: statusKeys[i]);
          } else if (i == machineNames.length) {
            return Card(
              child: Container(
                padding: EdgeInsets.all(10.0),
                  child: Text(
                      "Last Updated: ${updatedTime.hour}:${updatedTime.minute}:${updatedTime.second}")),
            );
          }
        });
  }

  Future<void> _refreshStatus() async {
//    statusKeys.forEach((status) =>
//        {if (status.currentState != null) status.currentState.updateStatus()});
    this.setState(() {
      updatedTime = DateTime.now();
    });
  }
}
