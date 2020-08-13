import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:webfeed/domain/atom_category.dart';

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

class JobListState extends State<JobList> with SingleTickerProviderStateMixin {
  Activity activity;
  List<RunningJob> filteredRunningJobs;
  List<QueuedJob> filteredQueuedJobs;
  List<Reservation> filteredReservations;
  TextEditingController _textController = TextEditingController();
  TabController controller;
  int tabIndex = 0;

  num runningSortColumn = 0;
  bool runningSortAscending = false;
  num queuedSortColumn = 0;
  bool queuedSortAscending = false;
  num reservedSortColumn = 0;
  bool reservedSortAscending = false;

  static final List runningJobHeaders = [
    "Job ID",
    "Project",
    "Run Time",
    "Wall Time",
    "Nodes",
    "Mode",
    "Location",
  ];
  static final List queuedJobHeaders = [
    "Job ID",
    "Project",
    "Queue",
    "Queued Time",
    "Wall Time",
    "Score",
    "Nodes",
    "State",
    "Mode",
  ];
  static final List reservedJobHeaders = [
    "Name",
    "Start Time",
    "Duration",
    "Queue",
    "T-Minus",
  ];
  static final List headerListMaster = [
    runningJobHeaders,
    queuedJobHeaders,
    reservedJobHeaders
  ];

  JobListState(this.activity);

  @override
  void initState() {
    super.initState();
    filteredRunningJobs = activity.runningJobs;
    filteredQueuedJobs = activity.queuedJobs;
    filteredReservations = activity.reservations;
    controller = TabController(length: 3, vsync: this, initialIndex: 0);
    controller.addListener(() => {
          if (controller.indexIsChanging)
            setState(() {
              tabIndex = controller.index;
            })
        });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// Builds the widget
  @override
  Widget build(BuildContext context) {
    var runningJobs = _runningJobs();
    var queuedJobs = _queuedJobs();
    var reservations = _reservations();
    return Column(children: [
      Container(
        height: 60,
        child: TabBar(
          tabs: [
            Icon(Icons.directions_run),
            Icon(Icons.list),
            Icon(Icons.access_time)
          ],
          controller: controller,
        ),
      ),
      ListView(
        children: [
          filterBar(),
          [
            jobTable("Running Jobs", runningJobs[0], runningJobs[1], 0),
            jobTable("Queued Jobs", queuedJobs[0], queuedJobs[1], 1),
            jobTable("Reservations", reservations[0], reservations[1], 2),
          ][tabIndex]
        ],
        padding: EdgeInsets.all(10),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
      ),
    ]);
  }

  Widget filterBar() {
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
          hintText: "Filter Jobs or Reservations",
          icon: const Icon(Icons.search)),
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

  changeSort(index, tableNumber) {
    if (index == -1) return; //TODO: Sort by notification subscription
    switch (tableNumber) {
      case 0:
        _sortRunning(index);
        break;
      case 1:
        _sortQueued(index);
        break;
      case 2:
        _sortReserved(index);
        break;
    }
  }

  _sortRunning(columnNumber) {
    setState(() {
      if (columnNumber == runningSortColumn) {
        runningSortAscending = !runningSortAscending;
      } else {
        runningSortAscending = false;
      }
      switch (columnNumber) {
        case 0:
          filteredRunningJobs.sort((a, b) => (runningSortAscending)
              ? b.jobid.compareTo(a.jobid)
              : a.jobid.compareTo(b.jobid));
          break;
        case 1:
          filteredRunningJobs.sort((a, b) => (runningSortAscending)
              ? b.project.compareTo(a.project)
              : a.project.compareTo(b.project));
          break;
        case 2:
          // TODO: Sort on time instead of alphabetical
          filteredRunningJobs.sort((a, b) => (runningSortAscending)
              ? b.runtimef.compareTo(a.runtimef)
              : a.runtimef.compareTo(b.runtimef));
          break;
        case 3:
          filteredRunningJobs.sort((a, b) => (runningSortAscending)
              ? b.walltime.compareTo(a.walltime)
              : a.walltime.compareTo(b.walltime));
          break;
        case 4:
          filteredRunningJobs.sort((a, b) => (runningSortAscending)
              ? b.nodes.compareTo(a.nodes)
              : a.nodes.compareTo(b.nodes));
          break;
        case 4:
          filteredRunningJobs.sort((a, b) => (runningSortAscending)
              ? b.mode.compareTo(a.mode)
              : a.mode.compareTo(b.mode));
          break;
        case 5:
        default:
          break;
      }
      runningSortColumn = columnNumber;
    });
  }

  _sortQueued(columnNumber) {
    setState(() {
      if (columnNumber == queuedSortColumn) {
        queuedSortAscending = !queuedSortAscending;
      } else {
        queuedSortAscending = false;
      }
      switch (columnNumber) {
        case 0:
          filteredQueuedJobs.sort((a, b) => (queuedSortAscending)
              ? b.jobid.compareTo(a.jobid)
              : a.jobid.compareTo(b.jobid));
          break;
        case 1:
          filteredQueuedJobs.sort((a, b) => (queuedSortAscending)
              ? b.project.compareTo(a.project)
              : a.project.compareTo(b.project));
          break;
        case 2:
          filteredQueuedJobs.sort((a, b) => (queuedSortAscending)
              ? b.queue.compareTo(a.queue)
              : a.queue.compareTo(b.queue));
          break;
        case 3:
          // TODO: Sort on time instead of alphabetical
          filteredQueuedJobs.sort((a, b) => (queuedSortAscending)
              ? b.queuedtimef.compareTo(a.queuedtimef)
              : a.queuedtimef.compareTo(b.queuedtimef));
          break;
        case 4:
          filteredQueuedJobs.sort((a, b) => (queuedSortAscending)
              ? b.walltime.compareTo(a.walltime)
              : a.walltime.compareTo(b.walltime));
          break;
        case 5:
          filteredQueuedJobs.sort((a, b) => (queuedSortAscending)
              ? b.score.compareTo(a.score)
              : a.score.compareTo(b.score));
          break;
        case 6:
          filteredQueuedJobs.sort((a, b) => (queuedSortAscending)
              ? b.nodes.compareTo(a.nodes)
              : a.nodes.compareTo(b.nodes));
          break;
        case 7:
          filteredQueuedJobs.sort((a, b) => (queuedSortAscending)
              ? b.state.compareTo(a.state)
              : a.state.compareTo(b.state));
          break;
        case 8:
          filteredQueuedJobs.sort((a, b) => (queuedSortAscending)
              ? b.mode.compareTo(a.mode)
              : a.mode.compareTo(b.mode));
          break;
        default:
          break;
      }
      queuedSortColumn = columnNumber;
    });
  }

  _sortReserved(columnNumber) {
    setState(() {
      if (columnNumber == reservedSortColumn) {
        reservedSortAscending = !reservedSortAscending;
      } else {
        reservedSortAscending = false;
      }
      switch (columnNumber) {
        case 0:
          filteredReservations.sort((a, b) => (reservedSortAscending)
              ? b.name.compareTo(a.name)
              : a.name.compareTo(b.name));
          break;
        case 1:
          filteredReservations.sort((a, b) => (reservedSortAscending)
              ? b.start.compareTo(a.start)
              : a.start.compareTo(b.start));
          break;
        case 2:
          filteredReservations.sort((a, b) => (reservedSortAscending)
              ? b.duration.compareTo(a.duration)
              : a.duration.compareTo(b.duration));
          break;
        case 3:
          filteredReservations.sort((a, b) => (reservedSortAscending)
              ? b.queue.compareTo(a.queue)
              : a.queue.compareTo(b.queue));
          break;
        case 4:
          filteredReservations.sort((a, b) => (reservedSortAscending)
              ? b.tminus.compareTo(a.tminus)
              : a.tminus.compareTo(b.tminus));
          break;
        default:
          break;
      }
      reservedSortColumn = columnNumber;
    });
  }

  Widget jobTable(title, ids, jobTable, tableNumber) {
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
          children: _tableChildren(ids, jobTable, tableNumber),
          columnWidths: columnWidthMap,
        )
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  List<TableRow> _tableChildren(ids, jobTable, tableNumber) {
    List<TableRow> idColumn = [];
    List<TableRow> otherColumn = [];
    idColumn.add(
      TableRow(children: [
        headerCell(-1, tableNumber),
        headerCell(0, tableNumber),
      ]),
    );
    otherColumn.add(TableRow(
      children: columnHeader(tableNumber),
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

  List<Widget> columnHeader(tableNumber) {
    List<Widget> widgetList = [];
    for (int i = 1; i < headerListMaster[tableNumber].length; i++)
      widgetList.add(headerCell(i, tableNumber));
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
      child: Text(text,
          style: TextStyle(
              // Color chosen based on:
              // https://stackoverflow.com/questions/3942878/how-to-decide-font-color-in-white-or-black-depending-on-background-color
              color: ((color.red * 0.299 +
                          color.green * 0.587 +
                          color.blue * 0.114) >
                      160)
                  ? Colors.black
                  : Colors.white)),
      padding: EdgeInsets.fromLTRB(5, 20, 5, 20),
      color: color,
    );
  }

  headerCell(index, tableNumber) {
    return InkWell(
      child: Container(
        child: Text(
            (index >= 0) ? headerListMaster[tableNumber][index] : "Notify",
            style: TextStyle(fontWeight: FontWeight.bold)),
        padding: EdgeInsets.fromLTRB(5, 20, 5, 20),
      ),
      onTap: () => {changeSort(index, tableNumber)},
    );
  }

  /// Displays all the running jobs
  List _runningJobs() {
    List<TableRow> idColumn = [];
    List<TableRow> jobTable = [];
    filteredRunningJobs.forEach((job) {
      var color = parseColor(job.color);
      idColumn.add(TableRow(children: [
        Container(
          child: IconButton(
              icon: Icon(Icons.notifications_none),
              onPressed: () => {},
              color: Colors.white),
        ),
        textCellColored(job.jobid.toString(), color),
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
