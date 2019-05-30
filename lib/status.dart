import 'activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

class Status extends StatefulWidget {
  Status(this.name, {Key key}) : super(key: key);
  final String name;
  @override
  StatusState createState() => StatusState(name);
}

class StatusState extends State<Status> {
  final String name;
  Activity activity;
  num nodesUsed = 0;
  num nodesUnused = 0;
  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();

  StatusState(this.name);

  Future<void> updateStatus() async {
    try {
      Activity newActivity = await fetchActivity(name);

      setState(() {
        activity = newActivity;
        nodesUsed = activity.nodeInfo.length.toDouble();
        nodesUnused = activity.dimensions.midplanes *
                activity.dimensions.nodecards *
                activity.dimensions.racks *
                activity.dimensions.rows *
                activity.dimensions.subdivisions.toDouble() -
            activity.nodeInfo.length.toDouble();
        _chartKey.currentState.updateData(_updateUsageData());
      });
    } catch (exception) {
      throw Exception(
          "Error while updating  status for machine ${name}: ${exception.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Activity>(
        future: fetchActivity(name),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            activity = snapshot.data;
            nodesUsed = activity.nodeInfo.length.toDouble();
            nodesUnused = activity.dimensions.midplanes *
                activity.dimensions.nodecards *
                activity.dimensions.racks *
                activity.dimensions.rows *
                activity.dimensions.subdivisions.toDouble() -
                activity.nodeInfo.length.toDouble();
            return _statusCard();
          } else if (snapshot.hasError) {
            return Card(
              child: Text("${snapshot.error}"),
            );
          }
          // By default, show a loading spinner
          return CircularProgressIndicator();
        });
  }

  Widget _statusCard() {
    return Card(
      child: Container(
        child: Column(
          children: [
            Row(
              children: [
                Center(
                  child: AnimatedCircularChart(
                    key: _chartKey,
                    size: const Size(300.0, 300.0),
                    initialChartData: _updateUsageData(),
                    holeLabel: name,
                    chartType: CircularChartType.Radial,
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      Text(name),
                      Text(activity.updated.toString()),
                      Text(activity.runningJobs.length.toString()),
                    ],
                  ),
                ),
              ],
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  List<CircularStackEntry> _updateUsageData() {
    return <CircularStackEntry>[
      new CircularStackEntry(
        <CircularSegmentEntry>[
          new CircularSegmentEntry(nodesUsed, Colors.lightGreen,
              rankKey: 'Active'),
          new CircularSegmentEntry(nodesUnused, Colors.grey[200],
              rankKey: 'Unused')
        ],
        rankKey: 'Resource Usage',
      ),
    ];
  }
}
