import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

import 'activity.dart';
import 'statuspage.dart';

/// Status
///
/// Returns an expandable widget which displays the status of a given machine,
/// using activity data generated via the Activity json deserializer class

class Status extends StatefulWidget {
  Status(this.name, {Key key}) : super(key: key);
  final String name;
  @override
  StatusState createState() => StatusState(name);
}

class StatusState extends State<Status> {
  final String name;
  static var coresPerNode = {"Cooley": 12, "Theta": 64};
  Activity activity;
  int nodesUsed = 0;
  int nodesTotal = 0;
  int tabIndex = 0;
  // Key used to update the Circular Charts
  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();
  num coreHoursScheduled = 0;

  StatusState(this.name);

  /// Grabs the latest activity data from status.alcf.anl.gov
  Future<void> updateStatus() async {
    try {
//      Activity newActivity = await fetchActivity(name);
      Activity newActivity = await fetchActivityDummy(name);
      var coreHours = 0.0;
      newActivity.queuedJobs.forEach((job) => {
            coreHours += job.walltime / 60 / 60 * job.nodes * coresPerNode[name]
          });
      setState(() {
        activity = newActivity;
        _calculateNodesUsed();
        coreHoursScheduled = coreHours;
        _chartKey.currentState.updateData(_updateUsageData());
      });
    } catch (exception) {
      throw Exception(
          "Error while updating  status for machine $name: ${exception.toString()}");
    }
  }

  /// Builds the widget
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Activity>(
        future: fetchActivity(name),
//        future: fetchActivityDummy(name),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            activity = snapshot.data;
            // Check for maintenance!
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
            try {
              _calculateNodesUsed();
              coreHoursScheduled = 0;
              activity.queuedJobs.forEach((job) => {
                    coreHoursScheduled +=
                        job.walltime / 60 / 60 * job.nodes * coresPerNode[name]
                  });
              return _statusWidget();
            } catch (exception) {
              return Card(
                  child: Center(
                      widthFactor: 10,
                      heightFactor: 10,
                      child: Text(
                          "Something went wrong displaying the status of $name.")));
            }
          } else if (snapshot.hasError) {
            return Card(
              child: Center(
                heightFactor: 10,
                widthFactor: 10,
                child: Text(
                  "Error: ${snapshot.error}",
                ),
              ),
            );
          }
          // By default, show a loading spinner
          return Card(
            child: Center(
              heightFactor: 2,
              child: CircularProgressIndicator(),
            ),
          );
        });
  }

  /// Expandable Status widget
  Widget _statusWidget() {
    return Card(
        child: InkWell(
            child: _statusCardHeader(),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => StatusPage(name)));
            }));
  }

  /// Creates a Circular chart and Summary statistics
  _statusCardHeader() {
    return Row(
      children: [
        // Circular Chart of Percentage Used
        AnimatedCircularChart(
          key: _chartKey,
          size: Size(MediaQuery.of(context).size.width / 3,
              MediaQuery.of(context).size.width / 3),
          initialChartData: _updateUsageData(),
          holeLabel: "${(nodesUsed / nodesTotal * 100).round()}%",
          chartType: CircularChartType.Radial,
          labelStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width / 1.8,
          child: Column(
            children: [
              Text(
                "$name",
                textScaleFactor: 1.5,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Divider(),
              // Summary Statistics
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Jobs",
                          textScaleFactor: 1.1,
                        ),
                        Text(
                          "Queued",
                          textScaleFactor: 1.1,
                        ),
                        Text(
                          "Reserved",
                          textScaleFactor: 1.1,
                        ),
                        Text(
                          "Nodes",
                          textScaleFactor: 1.1,
                        ),
//                        Text(
//                          "Usage",
//                          textScaleFactor: 1.1,
//                        ),
                        Text(
                          "Core Hours",
                          textScaleFactor: 1.1,
                        ),
                      ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(
                      "${activity.runningJobs.length.toString()}",
                      textScaleFactor: 1.1,
                    ),
                    Text(
                      "${activity.queuedJobs.length.toString()}",
                      textScaleFactor: 1.1,
                    ),
                    Text(
                      "${activity.reservations.length}",
                      textScaleFactor: 1.1,
                    ),
                    Text(
                      "${nodesUsed}",
                      textScaleFactor: 1.1,
                    ),
//                    Text(
//                      "${(nodesUsed / nodesTotal * 100).round()}%",
//                      textScaleFactor: 1.1,
//                    ),
                    Text(
                      "${coreHoursScheduled.round().toString()}",
                      textScaleFactor: 1.1,
                    ),
                  ])
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Figures out how many nodes are in use and how many are possible
  /// Unfortunately, this is machine specific in some cases :(
  void _calculateNodesUsed() {
    if (name == "Cooley") {
      var used = 0;
      var unused = 0;
      activity.nodeInfo.forEach(
          (key, node) => {(node.state == "allocated") ? used++ : unused++});
      nodesUsed = used;
      nodesTotal = used + unused;
    } else if (name == "Theta") {
      nodesUsed = 0;
      activity.runningJobs.forEach((job) => {nodesUsed += job.nodes});
      nodesTotal = 4608;
    } else {
      nodesUsed = activity.nodeInfo.length;
      nodesTotal = activity.dimensions.midplanes *
          activity.dimensions.nodecards *
          activity.dimensions.racks *
          activity.dimensions.rows *
          activity.dimensions.subdivisions;
    }
  }

  /// Update the Circular Chart
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
