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
  int nodesUsed = 0;
  int nodesTotal = 0;
  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();
  num coreHoursScheduled = 0;

  StatusState(this.name);

  Future<void> updateStatus() async {
    try {
      Activity newActivity = await fetchActivity(name);
      var coreHours = 0.0;
      newActivity.reservations
          .forEach((res) => {coreHours += res.duration / 60 / 60});
      setState(() {
        activity = newActivity;
        nodesUsed = activity.nodeInfo.length;
        nodesTotal = activity.dimensions.midplanes *
            activity.dimensions.nodecards *
            activity.dimensions.racks *
            activity.dimensions.rows *
            activity.dimensions.subdivisions;
        coreHoursScheduled = coreHours;
        _chartKey.currentState.updateData(_updateUsageData());
      });
    } catch (exception) {
      throw Exception(
          "Error while updating  status for machine $name: ${exception.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Activity>(
        future: fetchActivity(name),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            activity = snapshot.data;
            if (activity.maint != null && activity.maint) {
              return Card(
                  child: Center(
                    widthFactor: 10,
                    heightFactor: 10,
                    child: Text(
                      "$name is down for maintenance!",
                    ),
                  ),
              );
            }
            nodesUsed = activity.nodeInfo.length;
            nodesTotal = activity.dimensions.midplanes *
                activity.dimensions.nodecards *
                activity.dimensions.racks *
                activity.dimensions.rows *
                activity.dimensions.subdivisions;
            coreHoursScheduled = 0;
            activity.reservations.forEach(
                (res) => {coreHoursScheduled += res.duration / 60 / 60});
            return _statusCard();
          } else if (snapshot.hasError) {
            return Card(
              child: Center(
                heightFactor: 10,
                widthFactor: 10,
                child: Text(
//                    "Sorry, there was a problem loading the status for $name!\nYou can try refreshing."),
                  "Error: ${snapshot.error}",
                ),
              ),
            );
          }
          // By default, show a loading spinner
          return Card(
            child: Center(
              heightFactor: 5,
              widthFactor: 5,
              child: CircularProgressIndicator(),
            ),
          );
        });
  }

  Widget _statusCard() {
    return Card(
      child: Container(
        child: Row(
          children: [
            AnimatedCircularChart(
              key: _chartKey,
              size: Size(MediaQuery.of(context).size.width / 3,
                  MediaQuery.of(context).size.width / 3),
              initialChartData: _updateUsageData(),
              holeLabel: "$name\n${(nodesUsed / nodesTotal * 100).round()}%",
              chartType: CircularChartType.Radial,
              labelStyle: TextStyle(
                fontSize: 18,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 2,
              child: Column(
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    "Running Jobs: ${activity.runningJobs.length.toString()}",
                  ),
                  Text(
                    "Queued Jobs: ${activity.queuedJobs.length.toString()}",
                  ),
                  Text(
                    "Core Hours Scheduled: ${coreHoursScheduled.round().toString()}",
                  ),
                  Text(
                    "Reservations: ${activity.reservations.length}",
                  ),
                  Text(
                    "Nodes in Use: $nodesUsed",
                  ),
                  Text(
                    "Nodes Total: $nodesTotal",
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CircularStackEntry> _updateUsageData() {
    return <CircularStackEntry>[
      new CircularStackEntry(
        <CircularSegmentEntry>[
          new CircularSegmentEntry(nodesUsed.toDouble(), Colors.lightGreen,
              rankKey: 'Active'),
          new CircularSegmentEntry(
              (nodesTotal - nodesUsed).toDouble(), Colors.grey[200],
              rankKey: 'Unused')
        ],
        rankKey: 'Resource Usage',
      ),
    ];
  }
}
