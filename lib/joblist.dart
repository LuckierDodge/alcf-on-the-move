import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
  Activity activity;
  List<RunningJob> filteredRunningJobs;
  List<QueuedJob> filteredQueuedJobs;
  List<Reservation> filteredReservations;
  TextEditingController _textController = TextEditingController();

  JobListState(this.activity);

  @override
  void initState() {
    super.initState();
    filteredRunningJobs = activity.runningJobs;
    filteredQueuedJobs = activity.queuedJobs;
    filteredReservations = activity.reservations;
  }

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
        filterBar(),
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
              "State",
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
              "Duration",
              "Queue",
              "T-Minus",
            ],
            reservations[0],
            reservations[1]),
      ],
    );
  }

  Widget filterBar() {
    return TextField(
      controller: _textController,
      decoration: InputDecoration(hintText: "Filter Jobs or Reservations"),
      onChanged: _onChanged,
    );
  }

  _onChanged(String value) {
    if (value == "") {
      setState(() {
        filteredRunningJobs = activity.runningJobs;
        filteredQueuedJobs = activity.queuedJobs;
        filteredReservations = activity.reservations;
      });
    } else {
      setState(() {
        filteredRunningJobs = activity.runningJobs
            .where((runningJob) =>
                runningJob.jobid
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                runningJob.queue
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                runningJob.nodes
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                runningJob.mode
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                runningJob.location
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                runningJob.project
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()))
            .toList();
        filteredQueuedJobs = activity.queuedJobs
            .where((queuedJob) =>
                queuedJob.jobid
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                queuedJob.queue
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                queuedJob.mode
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                queuedJob.nodes
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                queuedJob.state
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                queuedJob.project
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()))
            .toList();
        filteredReservations = activity.reservations
            .where((reservation) =>
                reservation.name
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                reservation.startf
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                reservation.duration
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                reservation.queue
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()))
            .toList();
      });
    }
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
    filteredRunningJobs.forEach((job) {
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
    filteredQueuedJobs.forEach((job) {
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
          textCell(job.state.toString()),
          textCell(job.mode.toString()),
        ],
      ));
    });
    return [idColumn, jobTable];
  }

  /// Displays all the reservations
  List _reservations() {
    List<TableRow> nameColumn = [];
    List<TableRow> jobTable = [];
    filteredReservations.forEach((reservation) {
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
          textCell(reservation.durationf.toString()),
          textCell(reservation.queue.toString()),
          textCell(reservation.tminus.toString()),
        ],
      ));
    });
    return [nameColumn, jobTable];
  }
}
