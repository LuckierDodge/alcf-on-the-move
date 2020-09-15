import 'dart:ffi';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'activity.dart';
import 'utils.dart';
import 'package:photo_view/photo_view.dart';

/// A simple encapsulation of everything we need to know about a node
class Node {
  String id;
  int jobid;
  String color;
  Node(this.id, this.jobid, this.color);
}

class TableVis extends StatefulWidget {
  TableVis(this.name, this.activity, {Key key}) : super(key: key);
  final String name;
  final Activity activity;
  @override
  TableVisState createState() => TableVisState(name, activity);
}

class CanvasSizeUtil {
  static const _WIDTH = 1000;
  static const _HEIGHT = 1000;

  static Size _logicSize;

  static get width {
    return _logicSize.width;
  }

  static get height {
    return _logicSize.height;
  }

  static set size(size) {
    _logicSize = size;
  }

  static double getAxisX(double w) {
    return (w * width) / _WIDTH;
  }

  static double getAxisY(double h) {
    return (h * height) / _HEIGHT;
  }

  static double getAxisBoth(double s) {
    return s *
        sqrt((width * width + height * height) /
            (_WIDTH * _WIDTH + _HEIGHT * _HEIGHT));
  }
}

class RackPainter extends CustomPainter {
  RackPainter(this.nodesX, this.nodesY, this.nodesList);
  int nodesX;
  int nodesY;
  List<Node> nodesList;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width > 1.0 && size.height > 1.0) {
      CanvasSizeUtil.size = size;
    }
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black
      ..isAntiAlias = true;
    for (int i = 0; i < nodesX; i++) {
      for (int j = 0; j < nodesY; j++) {
        paint.color = parseColor(nodesList[i + j * nodesX].color);
        canvas.drawRect(
            Rect.fromLTRB(
                CanvasSizeUtil.getAxisX(
                    (i * CanvasSizeUtil._WIDTH / nodesX).floorToDouble()),
                CanvasSizeUtil.getAxisY(
                    (j * CanvasSizeUtil._HEIGHT / nodesY).floorToDouble()),
                CanvasSizeUtil.getAxisX(
                    ((i + 1) * CanvasSizeUtil._WIDTH / nodesX).ceilToDouble()),
                CanvasSizeUtil.getAxisY(
                        ((j + 1) * CanvasSizeUtil._HEIGHT / nodesY))
                    .ceilToDouble()),
            paint);
      }
    }
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    for (int i = 0; i < nodesX; i++) {
      for (int j = 0; j < nodesY; j++) {
        canvas.drawRect(
            Rect.fromLTRB(
                CanvasSizeUtil.getAxisX(
                    (i * CanvasSizeUtil._WIDTH / nodesX).floorToDouble()),
                CanvasSizeUtil.getAxisY(
                    (j * CanvasSizeUtil._HEIGHT / nodesY).floorToDouble()),
                CanvasSizeUtil.getAxisX(
                    ((i + 1) * CanvasSizeUtil._WIDTH / nodesX).ceilToDouble()),
                CanvasSizeUtil.getAxisY(
                        ((j + 1) * CanvasSizeUtil._HEIGHT / nodesY))
                    .ceilToDouble()),
            paint);
      }
    }

    canvas.save();
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TableVisState extends State<TableVis> {
  final String name;
  Activity activity;
  int thetaRowOffset = 2304;

  TableVisState(this.name, this.activity);

  Future<void> _launchDialog(List<Node> nodes, int width, int height) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          // Find all of our running jobs based on the nodes provided
          List<RunningJob> runningJobs = [];
          nodes.forEach((node) {
            var index = activity.runningJobs
                .indexWhere((job) => job.jobid == node.jobid);
            if (index > 0 && index < activity.runningJobs.length) {
              runningJobs.add(activity.runningJobs[index]);
            }
          });
          runningJobs = runningJobs.toSet().toList();
          if (runningJobs.isEmpty)
            return AlertDialog(title: Text('No Jobs'), actions: <Widget>[
              FlatButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ]);
          List<Widget> widgetList = [];
          runningJobs.forEach((runningJob) {
            widgetList.addAll([
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("JobID: "),
                  Text(
                    runningJob.jobid.toString(),
                    softWrap: true,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Project: "),
                  Text(
                    runningJob.project.toString(),
                    softWrap: true,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Color: "),
                  Container(
                    padding: EdgeInsets.all(0),
                    margin: EdgeInsets.all(0),
                    child: Card(
                      color: parseColor(runningJob.color),
                      margin: EdgeInsets.all(0),
                    ),
                    width: 100,
                    height: 20,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Queue: "),
                  Text(
                    runningJob.queue.toString(),
                    softWrap: true,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Run Time: "),
                  Text(
                    runningJob.runtimef.toString(),
                    softWrap: true,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Wall Time: "),
                  Text(
                    runningJob.walltimef.toString(),
                    softWrap: true,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Nodes Used: "),
                  Text(
                    runningJob.nodes.toString(),
                    softWrap: true,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Mode: "),
                  Text(
                    runningJob.mode.toString(),
                    softWrap: true,
                  ),
                ],
              ),
              Divider(),
            ]);
          });
          return AlertDialog(
              title: Text("Rack Job View"),
              content: Builder(builder: (context) {
                var screenHeight = MediaQuery.of(context).size.height;
                var screenWidth = MediaQuery.of(context).size.width;
                return Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          // alignment: Alignment.centerLeft
                          child: CustomPaint(
                            painter: RackPainter(width, height, nodes),
                          ),
                          width: (screenWidth < screenHeight)
                              ? screenWidth * .2
                              : screenHeight / 8,
                          height: screenHeight / 2,
                        ),
                        Container(
                            // alignment: Alignment.center,
                            child: SingleChildScrollView(
                                child: Column(children: widgetList)),
                            width: screenWidth * .5)
                      ],
                    ),
                    width: screenWidth * .8);
              }),
              actions: <Widget>[
                FlatButton(
                    child: Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ]);
        });
  }

  /// Builds the widget depending on the machine in question
  @override
  Widget build(BuildContext context) {
    if (name == "Theta") {
      return _thetaVis();
    } else if (name == "Cooley") {
      return _cooleyVis();
    } else {
      return Container();
    }
  }

  /// Map vis for Theta
  /// Nodes are numbered, so we store them in one giant array that we group
  /// using known dimensions.
  _thetaVis() {
    List<Node> nodes = new List<Node>(4608);
    activity.runningJobs.forEach((job) {
      // Extract the nodes for each job and put a Node object in it's index
      List<int> nodeIds = hyphenRange((job.location as List)[0]);
      nodeIds.forEach((node) {
        nodes[node] = Node(node.toString(), job.jobid, job.color);
      });
    });
    // Go through all the nodes and fill in unused nodes with a blank node object
    for (int i = 0; i < 4608; i++) {
      if (nodes[i] == null) {
        nodes[i] = Node(i.toString(), 0, "#BBBBBB");
      }
    }

    List<Widget> widgetList = [];
    for (int j = 0; j < 6; j++) {
      widgetList.add(Column(
        children: [
          Row(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Container(
                  padding: EdgeInsets.all(1),
                  child: Text(
                    "c${11 - 2 * j}-0",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
                  ),
                ),
                _thetaRack(
                  nodes.sublist(
                    thetaRowOffset - (2 * j + 1) * 192,
                    thetaRowOffset - 2 * j * 192,
                  ),
                )
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Container(
                  padding: EdgeInsets.all(1),
                  child: Text(
                    "c${10 - 2 * j}-0",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
                  ),
                ),
                _thetaRack(
                  nodes.sublist(thetaRowOffset - (2 * j + 2) * 192,
                      thetaRowOffset - (2 * j + 1) * 192),
                )
              ])
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Divider(),
          Row(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Container(
                  padding: EdgeInsets.all(1),
                  child: Text(
                    "c${11 - 2 * j}-1",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
                  ),
                ),
                _thetaRack(
                  nodes.sublist(
                    2 * thetaRowOffset - (2 * j + 1) * 192,
                    2 * thetaRowOffset - 2 * j * 192,
                  ),
                )
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Container(
                  padding: EdgeInsets.all(1),
                  child: Text(
                    "c${10 - 2 * j}-1",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
                  ),
                ),
                _thetaRack(nodes.sublist(
                  2 * thetaRowOffset - (2 * j + 2) * 192,
                  2 * thetaRowOffset - (2 * j + 1) * 192,
                ))
              ])
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
      ));
    }

    // Add row visualizations
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(
        child: ClipRect(
            child: PhotoView.customChild(
                child: Container(
                    child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: widgetList,
        )))),
        height: (MediaQuery.of(context).orientation == Orientation.portrait)
            ? (MediaQuery.of(context).size.width / 2)
            : MediaQuery.of(context).size.height - 124,
      )
    ]);
  }

  /// Rack visualization for Theta
  _thetaRack(List nodeList) {
    List<Node> arrangedList = List();
    List segmentedList = List(6);
    for (int i = 0; i < 6; i++) {
      segmentedList[i] = nodeList.sublist(i * 32, (i + 1) * 32);
    }
    List column1 = List(24);
    List column2 = List(24);
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 8; j++) {
        column1[j + i * 8] = segmentedList[2 * i].sublist(j * 4, (j + 1) * 4);
      }
    }
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 8; j++) {
        column2[j + i * 8] =
            segmentedList[2 * i + 1].sublist(j * 4, (j + 1) * 4);
      }
    }
    var columns = [column1.reversed.toList(), column2.reversed.toList()];
    for (int i = 0; i < 24; i++) {
      arrangedList.insertAll(i * 8, columns[0][i]);
      arrangedList.insertAll(i * 8 + 4, columns[1][i]);
    }

    return InkWell(
        onTap: () => {_launchDialog(nodeList, 8, 24)},
        child: Container(
          width: (MediaQuery.of(context).size.width / 12 - 3),
          height: (MediaQuery.of(context).orientation == Orientation.portrait)
              ? (MediaQuery.of(context).size.width / 4 - 18)
              : MediaQuery.of(context).size.height / 2 - 80,
          padding: EdgeInsets.all(4),
          child: CustomPaint(
            painter: RackPainter(8, 24, arrangedList),
          ),
        ));
  }

  /// Map vis for Cooley
  /// Nodes are key based, but in a nice list like Theta, so we just iterate
  _cooleyVis() {
    List<Widget> widgetList = [];
    List<Node> nodes = new List<Node>();
    activity.nodeInfo.forEach((name, node) {
      // Extract the nodes for each job and put a Node object in the list
      if (node.state == "allocated") {
        nodes.add(Node(name, node.jobid, node.color));
      } else {
        nodes.add(Node(name, 0, "#FFFFFF"));
      }
    });

    // Add row visualizations
    for (int i = 0; i < 6; i++) {
      widgetList.add(Container(
        padding: EdgeInsets.all(1),
        child: Column(children: [
          Container(
            child: Text(
              "Rack $i",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
            ),
            padding: EdgeInsets.all(1),
          ),
          _cooleyRack(nodes.sublist(i * 21, (i + 1) * 21)),
        ]),
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(
        child: ClipRect(
            child: PhotoView.customChild(
                child: Container(
                    child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: widgetList,
        )))),
        height: (MediaQuery.of(context).orientation == Orientation.portrait)
            ? (MediaQuery.of(context).size.width / 2)
            : MediaQuery.of(context).size.height - 112,
      )
    ]);
  }

  /// Rack visualization for Cooley
  _cooleyRack(List nodes) {
    return InkWell(
      child: Container(
        width: (MediaQuery.of(context).size.width / 6 - 12),
        height: (MediaQuery.of(context).orientation == Orientation.portrait)
            ? (MediaQuery.of(context).size.width / 2 - 24)
            : MediaQuery.of(context).size.height - 124,
        padding: EdgeInsets.all(4),
        child: CustomPaint(
          painter: RackPainter(3, 7, nodes),
        ),
      ),
      onTap: () => _launchDialog(nodes, 3, 7),
    );
  }
}
