import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import 'activity.dart';
import 'utils.dart';

/// Job List
///
/// Lists all of the running, queued, and reserved jobs for a machine
class JobList extends StatefulWidget {
  JobList(this.activity, {Key key}) : super(key: key);
  final Activity activity;
  @override
  JobListState createState() => JobListState(activity);
}

class JobListState extends State<JobList> {
  final Activity activity;

  JobListState(this.activity);

  /// Builds the widget
  @override
  Widget build(BuildContext context) {
    var runningJobs = activity.runningJobs.length;
    var queuedJobs = activity.queuedJobs.length;
    var reservations = activity.reservations.length;
    return ListView.builder(
        padding: const EdgeInsets.all(10.0),
        shrinkWrap: true,
        itemBuilder: (context, i) {
          if (i == 0) {
            return _listCard("$runningJobs Running Jobs", _runningJobs());
          } else if (i == 1) {
            return _listCard("$queuedJobs Queued Jobs", _queuedJobs());
          } else if (i == 2) {
            return _listCard("$reservations Reservations", _reservations());
          } else {
            return null;
          }
        });
  }

  _listCard(String title, Widget subWidget) {
    return Card(
      elevation: 10,
      borderOnForeground: true,
      child: Container(
        padding: EdgeInsets.all(2.0),
        child: ExpandableNotifier(
          child: Container(
            padding: EdgeInsets.all(2.0),
            child: ExpandablePanel(
              hasIcon: false,
              headerAlignment: ExpandablePanelHeaderAlignment.center,
              header: Container(
                padding: EdgeInsets.all(12.0),
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ),
              expanded: subWidget,
            ),
          ),
        ),
      ),
    );
  }

  /// Displays all the running jobs
  Widget _runningJobs() {
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
                  color: parseColor(job.color))),
        ]),
        collapsed: Container(
            padding: EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Project: "),
                Text(job.project.toString()),
              ],
            )),
        expanded: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Project: "),
                    Text(job.project.toString()),
                  ],
                )),
            Container(
              padding: EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[Text("Queue: "), Text(job.queue.toString())],
              ),
            ),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Run Time: "),
                    Text(job.runtimef.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Wall Time: "),
                    Text(job.walltimef.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Location: "),
                    Text(job.location.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Nodes Used: "),
                    Text(job.nodes.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[Text("Mode: "), Text(job.mode.toString())],
                )),
          ],
        ),
      )));
    });
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: widgetList,
      ),
    );
  }

  /// Displays all the queued jobs
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
        ]),
        collapsed: Container(
            padding: EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Project: "),
                Text(job.project.toString())
              ],
            )),
        expanded: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Project: "),
                    Text(job.project.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Queue: "),
                    Text(job.queue.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Queued Time: "),
                    Text(job.queuedtimef.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Wall Time: "),
                    Text(job.walltimef.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Score: "),
                    Text(job.score.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Nodes Requested: "),
                    Text(job.nodes.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  /// Displays all the reservations jobs
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
        ]),
        collapsed: Container(
            padding: EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[Text("Start: "), Text(job.startf.toString())],
            )),
        expanded: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Start: "),
                    Text(job.startf.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Queue: "),
                    Text(job.queue.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Duration: "),
                    Text(job.durationf.toString())
                  ],
                )),
            Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
