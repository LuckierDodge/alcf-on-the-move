import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import 'activity.dart';

class JobList extends StatefulWidget {
  JobList(this.activity, {Key key}) : super(key: key);
  final Activity activity;
  @override
  JobListState createState() => JobListState(activity);
}

class JobListState extends State<JobList> {
  final Activity activity;

  JobListState(this.activity);

  @override
  Widget build(BuildContext context) {
    var runningJobs = activity.runningJobs.length;
    var queuedJobs = activity.queuedJobs.length;
    var reservations = activity.reservations.length;

    return Container(
        padding: EdgeInsets.all(5),
        child: Column(
          children: <Widget>[
            ExpandableNotifier(
              child: ExpandablePanel(
                header: Text(
                  "$runningJobs Running Jobs",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                expanded: _runningJobs(),
              ),
            ),
            ExpandableNotifier(
              child: ExpandablePanel(
                header: Text(
                  "$queuedJobs Queued Jobs",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                expanded: _queuedJobs(),
              ),
            ),
            ExpandableNotifier(
              child: ExpandablePanel(
                  header: Text(
                    "$reservations Reservations",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  expanded: _reservations()),
            ),
          ],
        ));
  }

  _runningJobs() {
    List<Widget> widgetList = [];
    activity.runningJobs.forEach((job) {
      widgetList.add(Divider());
      widgetList.add(ExpandableNotifier(
          child: ExpandablePanel(
        header: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: EdgeInsets.all(5.0),
              child: Card(
                  child: Text(job.jobid.toString()),
                  color: Color.fromARGB(
                    255,
                    int.parse(job.color.toString().substring(1, 3), radix: 16),
                    int.parse(job.color.toString().substring(3, 5), radix: 16),
                    int.parse(job.color.toString().substring(5, 7), radix: 16),
                  ))),
          Row(
            children: <Widget>[Text("Project: "), Text(job.project.toString())],
          ),
        ]),
        expanded: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(5.0),
              child: Row(
                children: <Widget>[Text("Queue: "), Text(job.queue.toString())],
              ),
            ),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[
                    Text("Run Time: "),
                    Text(job.runtimef.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[
                    Text("Wall Time: "),
                    Text(job.walltimef.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[
                    Text("Location: "),
                    Text(job.location.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[
                    Text("Nodes Used: "),
                    Text(job.nodes.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[Text("Mode: "), Text(job.mode.toString())],
                )),
          ],
        ),
      )));
    });
    return Column(
      children: widgetList,
    );
  }

  _queuedJobs() {
    List<Widget> widgetList = [];
    activity.queuedJobs.forEach((job) {
      widgetList.add(Divider());
      widgetList.add(ExpandableNotifier(
          child: ExpandablePanel(
        header: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: EdgeInsets.all(5.0),
              child: Card(
                child: Text(
                  job.jobid.toString(),
                ),
              )),
          Container(
              padding: EdgeInsets.all(5.0),
              child: Row(
                children: <Widget>[
                  Text("Project: "),
                  Text(job.project.toString())
                ],
              )),
        ]),
        expanded: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[
                    Text("Queue: "),
                    Text(job.queue.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[
                    Text("Queued Time: "),
                    Text(job.queuedtimef.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[
                    Text("Wall Time: "),
                    Text(job.walltimef.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[
                    Text("Score: "),
                    Text(job.score.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[
                    Text("Nodes Requested: "),
                    Text(job.nodes.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[Text("Mode: "), Text(job.mode.toString())],
                )),
          ],
        ),
      )));
    });
    return Column(
      children: widgetList,
    );
  }

  _reservations() {
    List<Widget> widgetList = [];
    activity.reservations.forEach((job) {
      widgetList.add(Divider());
      widgetList.add(ExpandableNotifier(
          child: ExpandablePanel(
        header: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: EdgeInsets.all(5.0),
              child: Card(
                child: Text(
                  job.name.toString(),
                ),
              )),
          Container(
              padding: EdgeInsets.all(5.0),
              child: Row(
                children: <Widget>[
                  Text("Start: "),
                  Text(job.startf.toString())
                ],
              )),
        ]),
        expanded: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[
                    Text("Queue: "),
                    Text(job.queue.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[
                    Text("Duration: "),
                    Text(job.durationf.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[Text("T-: "), Text(job.tminus.toString())],
                )),
          ],
        ),
      )));
    });
    return Column(
      children: widgetList,
    );
  }
}
