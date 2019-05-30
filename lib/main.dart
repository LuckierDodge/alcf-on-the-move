import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'dataManager.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALCF On The Move',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Dashboard(title: 'Dashboard'),
    );
  }
}

class Dashboard extends StatefulWidget {
  Dashboard({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  num _updates = 0;
  var machineNames = ["Mira", "Cetus", "Vesta", "Cooley", "Theta"];
  Map<String, Activity> machineActivity;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ALCF On the Move"),
      ),
      body:
          RefreshIndicator(child: _machineList(), onRefresh: _refreshActivity),
    );
  }

  Widget _machineList() {
    return ListView.builder(
        padding: const EdgeInsets.all(32.0),
        itemBuilder: (context, i) {
          machineActivity = Map();
          if (i < machineNames.length) {
            return FutureBuilder<Activity>(
                future: fetchActivity(machineNames[i]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    machineActivity[machineNames[i]] = snapshot.data;
                    return Container(
                        child: _machineStatus(
                            machineNames[i], machineActivity[machineNames[i]]));
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }

                  // By default, show a loading spinner
                  return CircularProgressIndicator();
                });
          }
        });
  }

  Widget _machineStatus(String name, Activity activity) {
    List<CircularStackEntry> data = <CircularStackEntry>[
      new CircularStackEntry(
        <CircularSegmentEntry>[
          new CircularSegmentEntry(
              activity.nodeInfo.length.toDouble(),
              Colors.lightGreen,
              rankKey: 'Active'),
          new CircularSegmentEntry(
              activity.dimensions.midplanes *
                      activity.dimensions.nodecards *
                      activity.dimensions.racks *
                      activity.dimensions.rows *
                      activity.dimensions.subdivisions.toDouble() -
                  activity.nodeInfo.length.toDouble(),
              Colors.grey[200],
              rankKey: 'Unused')
        ],
        rankKey: 'Resource Usage',
      ),
    ];
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              AnimatedCircularChart(
                size: const Size(200.0, 200.0),
                initialChartData: data,
                holeLabel: name,
                chartType: CircularChartType.Radial,
              ),
              Column(
                children: [
                  Text(name),
                  Text(activity.updated.toString()),
                  Text(activity.runningJobs.length.toString()),
                  Text(_updates.toString()),
                ],
              ),
            ],
          ),
          Divider(),
        ],
      ),
    );
  }

  Future<void> _refreshActivity() async {
    Map<String, Activity> tempActivity = Map();
    machineNames.forEach((name) async {
      tempActivity[name] = await fetchActivity(name);
    });
    setState(() {
      machineActivity.addAll(tempActivity);
      _updates++;
    });
  }
}
