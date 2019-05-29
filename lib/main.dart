import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'dataManager.dart';

var machineNames = ["Mira", "Cetus", "Vesta", "Cooley", "Theta"];
Map<String, Activity> machineActivity;

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ALCF On the Move"),
      ),
      body: _machineList(),
    );
  }

  Widget _machineList() {
    return ListView.builder(
        padding: const EdgeInsets.all(32.0),
        itemBuilder: (context, i) {
          machineActivity = Map();
          //if (i < machineNames.length) return _machineStatus(machineNames[i]);
          if (i < machineNames.length) {
            return FutureBuilder<Activity>(
                future: fetchActivity(machineNames[i]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    machineActivity[machineNames[i]] = snapshot.data;
                    return Container(child: _machineStatus(machineNames[i]));
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }

                  // By default, show a loading spinner
                  return CircularProgressIndicator();
                });
          }
        });
  }

  Widget _machineStatus(String name) {
    List<num> usage = usageCalc(name);

    List<CircularStackEntry> data = <CircularStackEntry>[
      new CircularStackEntry(
        <CircularSegmentEntry>[
          new CircularSegmentEntry(usage[0].toDouble(), Colors.lightGreen,
              rankKey: 'Active'),
          new CircularSegmentEntry(usage[1].toDouble(), Colors.grey[200],
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
                  Container(
                    child: Text(name),
                  ),
                  Container(
                    child: Text(machineActivity[name].updated.toString()),
                  ),
                  Container(
                      child:
                          Text(machineActivity[name].runningJobs[0].starttime))
                ],
              ),
            ],
          ),
          Divider(),
        ],
      ),
    );
  }

  List<num> usageCalc(String machine) {
    num inactive = 0;
    num active = machineActivity[machine].nodeInfo.length;
    num total = machineActivity[machine].dimensions.midplanes *
        machineActivity[machine].dimensions.nodecards *
        machineActivity[machine].dimensions.racks *
        machineActivity[machine].dimensions.rows *
        machineActivity[machine].dimensions.subdivisions;
    inactive = total - active;
    return [active, inactive];
  }
}
