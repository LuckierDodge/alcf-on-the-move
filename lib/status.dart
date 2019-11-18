import 'package:conditional_builder/conditional_builder.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

import 'activity.dart';
import 'joblist.dart';
import 'mapvisualization.dart';

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

class StatusState extends State<Status> with SingleTickerProviderStateMixin {
  final String name;
  static var coresPerNode = {
    "Mira": 16,
    "Cetus": 16,
    "Vesta": 16,
    "Cooley": 12,
    "Theta": 64
  };
  Activity activity;
  int nodesUsed = 0;
  int nodesTotal = 0;
  TabController controller;
  int tabIndex = 0;
  ExpandableController _expandableController = new ExpandableController();
  bool isExpanded = false;
  // Key used to update the Circular Charts
  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();
  num coreHoursScheduled = 0;

  StatusState(this.name);

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this, initialIndex: 0);
    controller.addListener(() => {
          if (controller.indexIsChanging)
            setState(() {
              tabIndex = controller.index;
            })
        });
    _expandableController.addListener(() => {
          if (_expandableController.expanded)
            {
              setState(() {
                isExpanded = _expandableController.expanded;
              })
            }
        });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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
            _calculateNodesUsed();
            coreHoursScheduled = 0;
            activity.queuedJobs.forEach((job) => {
                  coreHoursScheduled +=
                      job.walltime / 60 / 60 * job.nodes * coresPerNode[name]
                });
            return _statusWidget();
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
      child: ExpandablePanel(
        header: _statusCardHeader(),
        controller: _expandableController,
        expanded: ConditionalBuilder(
          condition: isExpanded,
          builder: (context) => Column(
            children: <Widget>[
              Divider(),
              Container(
                height: 40,
                child: TabBar(
                  tabs: [
                    Icon(Icons.grid_on),
                    Icon(Icons.list),
                  ],
                  controller: controller,
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 400),
                child: [
                  MapVis(name, activity),
                  JobList(activity),
                ][tabIndex],
              ),
            ],
          ),
        ),
        tapHeaderToExpand: true,
        tapBodyToCollapse: false,
        hasIcon: false,
      ),
    );
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
                          "Running Jobs:",
                          textScaleFactor: 1.1,
                        ),
                        Text(
                          "Queued Jobs:",
                          textScaleFactor: 1.1,
                        ),
                        Text(
                          "Core Hours Scheduled:",
                          textScaleFactor: 1.1,
                        ),
                        Text(
                          "Reservations:",
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
                      "${coreHoursScheduled.round().toString()}",
                      textScaleFactor: 1.1,
                    ),
                    Text(
                      "${activity.reservations.length}",
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
