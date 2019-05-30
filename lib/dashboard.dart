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
  List<GlobalKey<StatusState>> statusKeys = new List<GlobalKey<StatusState>>(machineNames.length);
  final String title;
  _DashboardState(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(title),
        ),
      ),
      body: RefreshIndicator(
        child: _machineList(),
        onRefresh: _refreshActivity,
      ),
    );
  }

  Widget _machineList() {
    return ListView.builder(
        padding: const EdgeInsets.all(32.0),
        itemBuilder: (context, i) {
          if ( i < machineNames.length ) {
            GlobalKey<StatusState> machineKey = new GlobalKey();
            statusKeys[i] = machineKey;
            return Status(machineNames[i], key: statusKeys[i]);
          }
        });
  }

  Future<void> _refreshActivity() async {
    statusKeys.forEach((status) => status.currentState.updateStatus());
  }
}
