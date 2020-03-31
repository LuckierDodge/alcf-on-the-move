import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'activity.dart';
import 'utils.dart';

/// Job List
///
/// Lists all of the running, queued, and reserved jobs for a machine
class JobList extends StatefulWidget {
  JobList(this.activity, {Key key}) : super(key: key);
  Activity activity;
  @override
  JobListState createState() => JobListState(activity);
}

class JobListState extends State<JobList> {
  Activity activity;
  Activity filteredActivity;

  JobListState(this.activity);

  /// Builds the widget
  @override
  Widget build(BuildContext context) {
    var runningJobs = _runningJobs();
    var queuedJobs = _queuedJobs();
    var reservations = _reservations();
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(10.0),
      children: <Widget>[
        jobTable(
            "Running Jobs",
            [
              "Job ID",
              "Project",
              "Run Time",
              "Wall Time",
              "Nodes Used",
              "Mode",
              "Location",
            ],
            runningJobs[0],
            runningJobs[1]),
        Divider(),
        jobTable(
            "Queued Jobs",
            [
              "Job ID",
              "Project",
              "Queue",
              "Queued Time",
              "Wall Time",
              "Score",
              "Nodes Requested",
              "Mode",
            ],
            queuedJobs[0],
            queuedJobs[1]),
        Divider(),
        jobTable(
            "Reservations",
            [
              "Name",
              "Start Time",
              "Queue",
              "T-Minus",
            ],
            reservations[0],
            reservations[1]),
      ],
    );
  }

  Widget jobTable(title, columnList, ids, jobTable) {
    var columnWidthMap = Map<int, TableColumnWidth>();
    columnWidthMap[0] = IntrinsicColumnWidth();
    return Column(
      children: [
        Container(
            child: Text(
              title,
              textScaleFactor: 1.5,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            padding: EdgeInsets.fromLTRB(5, 10, 5, 10)),
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: _tableChildren(columnList, ids, jobTable),
          columnWidths: columnWidthMap,
        )
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  List<TableRow> _tableChildren(columnList, ids, jobTable) {
    List<TableRow> idColumn = [];
    List<TableRow> otherColumn = [];
    idColumn.add(
      TableRow(children: [
        headerCell("Notify"),
//        headerCell("Color"),
        headerCell(columnList[0]),
      ]),
    );
    otherColumn.add(TableRow(
      children: columnHeader(columnList),
    ));
    ids.forEach((id) => {idColumn.add(id)});
    jobTable.forEach((job) => {otherColumn.add(job)});
    return [
      TableRow(children: [
        Table(
          children: idColumn,
          defaultColumnWidth: IntrinsicColumnWidth(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder.all(color: Colors.grey),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            children: otherColumn,
            defaultColumnWidth: IntrinsicColumnWidth(),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder(
              verticalInside: BorderSide(color: Colors.grey),
              horizontalInside: BorderSide(color: Colors.grey),
              right: BorderSide(color: Colors.grey),
              top: BorderSide(color: Colors.grey),
              bottom: BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ])
    ];
  }

  List<Widget> columnHeader(columnList) {
    List<Widget> widgetList = [];
    columnList.forEach((column) => {
          if (column != columnList[0])
            {
              widgetList.add(
                headerCell(column),
              )
            }
        });
    return widgetList;
  }

  textCell(text) {
    return Container(
      child: Text(text),
      padding: EdgeInsets.fromLTRB(5, 20, 5, 20),
    );
  }

  textCellColored(text, color) {
    return Container(
      child: Text(text, style: TextStyle(backgroundColor: parseColor(color))),
      padding: EdgeInsets.fromLTRB(5, 20, 5, 20),
    );
  }

  headerCell(text) {
    return Container(
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
      padding: EdgeInsets.fromLTRB(5, 20, 5, 20),
    );
  }

  /// Displays all the running jobs
  List _runningJobs() {
    List<TableRow> idColumn = [];
    List<TableRow> jobTable = [];
    activity.runningJobs.forEach((job) {
      idColumn.add(TableRow(children: [
        IconButton(
          icon: Icon(Icons.notifications_none),
          onPressed: () => {},
//          color: parseColor(job.color),
        ),
        textCellColored(job.jobid.toString(), job.color),
      ]));
      jobTable.add(TableRow(
        children: [
          textCell(job.project.toString()),
          textCell(job.runtimef.toString()),
          textCell(job.walltimef.toString()),
          textCell(job.nodes.toString()),
          textCell(job.mode.toString()),
          textCell(job.location.toString()),
        ],
      ));
    });
    return [idColumn, jobTable];
  }

  /// Displays all the queued jobs
  List _queuedJobs() {
    List<TableRow> idColumn = [];
    List<TableRow> jobTable = [];
    activity.queuedJobs.forEach((job) {
      idColumn.add(TableRow(children: [
        IconButton(
          icon: Icon(Icons.notifications_none),
          onPressed: () => {},
        ),
        textCell(job.jobid.toString())
      ]));
      jobTable.add(TableRow(
        children: [
          textCell(job.project.toString()),
          textCell(job.queue.toString()),
          textCell(job.queuedtimef.toString()),
          textCell(job.walltimef.toString()),
          textCell(job.score.toString()),
          textCell(job.nodes.toString()),
          textCell(job.mode.toString()),
        ],
      ));
    });
    return [idColumn, jobTable];
  }

  /// Displays all the reservations jobs
  List _reservations() {
    List<TableRow> nameColumn = [];
    List<TableRow> jobTable = [];
    activity.reservations.forEach((reservation) {
      nameColumn.add(TableRow(children: [
        IconButton(
          icon: Icon(Icons.notifications_none),
          onPressed: () => {},
        ),
        textCell(reservation.name.toString())
      ]));
      jobTable.add(TableRow(
        children: [
          textCell(reservation.startf.toString()),
          textCell(reservation.queue.toString()),
          textCell(reservation.tminus.toString()),
        ],
      ));
    });
    return [nameColumn, jobTable];
  }
}
