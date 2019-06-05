import 'package:flutter/material.dart';
import 'status.dart';
import 'noconnection.dart';
import 'settings.dart';
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
  String updatedTime;
  ConnectivityResult connectivity = ConnectivityResult.none;
  _DashboardState(this.title);

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
          title: Center(
            child: Text(title),
          ),
          actions: <Widget>[
            new IconButton(
                icon: const Icon(Icons.refresh), onPressed: _refreshStatus)
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
          title: Center(
            child: Text(title),
          ),
          actions: <Widget>[
            new IconButton(
                icon: const Icon(Icons.refresh), onPressed: _refreshStatus),
                new IconButton(icon: const Icon(Icons.settings), onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
                }),
          ],
        ),
        body: RefreshIndicator(
          child: _machineList(),
          onRefresh: _refreshStatus,
        ),
      );
    }
  }

  Widget _machineList() {
    return ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemBuilder: (context, i) {
          if (i < machineNames.length) {
            GlobalKey<StatusState> machineKey = new GlobalKey();
            statusKeys[i] = machineKey;
            return Status(machineNames[i], key: statusKeys[i]);
          } else if (i == machineNames.length) {
            return Card(
              child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Last Updated: $updatedTime")),
            );
          }
        });
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
