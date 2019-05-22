import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

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
  final List<String> machineNames = [
    "Mira",
    "Cetus",
    "Vesta",
    "Cooley",
    "Theta"
  ];
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
          if (i < machineNames.length) return _machineStatus(machineNames[i]);
        });
  }

  Widget _machineStatus(String name) {
    List<CircularStackEntry> data = <CircularStackEntry>[
      new CircularStackEntry(
        <CircularSegmentEntry>[
          new CircularSegmentEntry(500.0, Colors.lightGreen, rankKey: 'Active'),
          new CircularSegmentEntry(1000.0, Colors.grey[200], rankKey: 'Unused')
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
                size: const Size(150.0, 150.0),
                initialChartData: data,
                holeLabel: name,
                chartType: CircularChartType.Radial,
              ),
              Column(
                children: [
                  Container(
                    child: Text(name),
                  ),
                ],
              ),
            ],
          ),
          Divider(),
        ],
      ),
    );
  }
}
