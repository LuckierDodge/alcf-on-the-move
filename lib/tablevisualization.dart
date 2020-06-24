import 'dart:ffi';
import 'dart:math';
import 'package:flutter/material.dart';

import 'activity.dart';
import 'utils.dart';

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
  static const _WIDTH = 500;
  static const _HEIGHT = 500;

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
      ..color = Colors.blue
      ..isAntiAlias = true;
    for (int i = 0; i < nodesX; i++) {
      for (int j = 0; j < nodesY; j++) {
        paint.color = parseColor(nodesList[i + j * nodesX].color);
        canvas.drawRect(
            Rect.fromLTRB(
                CanvasSizeUtil.getAxisX((i * 500 / nodesX).floorToDouble()),
                CanvasSizeUtil.getAxisY((j * 500 / nodesY).floorToDouble()),
                CanvasSizeUtil.getAxisX(
                    ((i + 1) * 500 / nodesX).ceilToDouble()),
                CanvasSizeUtil.getAxisY(((j + 1) * 500 / nodesY))
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

  Future<void> _launchDialog(String color) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          RunningJob runningJob;
          activity.runningJobs.forEach((job) {
            if (job.color == color) runningJob = job;
          });
          if (runningJob == null)
            return AlertDialog(title: Text('Missing Job'), actions: <Widget>[
              FlatButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ]);
          return AlertDialog(
              title: Text(runningJob.project),
              content: SingleChildScrollView(
                child: Column(children: [
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
                      Text("Color: "),
                      Container(
                        padding: EdgeInsets.all(0),
                        margin: EdgeInsets.all(0),
                        child: Card(
                          color: parseColor(color),
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
                ]),
              ),
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
        nodes[i] = Node(i.toString(), 0, "#888888");
      }
    }

    // Reverse the list to match Gronkulator
//    nodes = nodes.reversed.toList();

    // Add row visualizations
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(
        child: PageView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            pageSnapping: false,
            itemCount: 6,
            itemBuilder: (context, j) {
              if (j < 6) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "c${11 - 2 * j}-0",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              _thetaRack(
                                nodes.sublist(
                                  thetaRowOffset - (2 * j + 1) * 192,
                                  thetaRowOffset - 2 * j * 192,
                                ),
                              )
                            ]),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "c${10 - 2 * j}-0",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              _thetaRack(
                                nodes.sublist(
                                    thetaRowOffset - (2 * j + 2) * 192,
                                    thetaRowOffset - (2 * j + 1) * 192),
                              )
                            ])
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    ),
                    Divider(),
                    Row(
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "c${11 - 2 * j}-1",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              _thetaRack(
                                nodes.sublist(
                                  2 * thetaRowOffset - (2 * j + 1) * 192,
                                  2 * thetaRowOffset - 2 * j * 192,
                                ),
                              )
                            ]),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "c${10 - 2 * j}-1",
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
                );
              } else {
                return null;
              }
            }),
        height: (MediaQuery.of(context).size.width / 2 - 24) * 2 + 100,
      )
    ]);
  }

  /// Rack visualization for Theta
  _thetaRack(List nodeList) {
    List<Node> arrangedList = List();
//    for (int i = 16; i < 208; i++) {
//      nodeList[i - 16] = Node("0", 0,
//          "#${(i).toRadixString(16)}${(i).toRadixString(16)}${(i).toRadixString(16)}");
////          "#FFFFFF");
//    }
////    nodeList[32] = Node("0", 0, "#000000");
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

    return Container(
      width: (MediaQuery.of(context).size.width / 2 - 24),
      height: (MediaQuery.of(context).size.width / 2 - 24),
      padding: EdgeInsets.all(4),
      child: CustomPaint(
        painter: RackPainter(8, 24, arrangedList),
      ),
    );
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
        padding: EdgeInsets.all(10),
        child: Column(children: [
          Container(
            child: Text(
              "Rack $i",
              textScaleFactor: 1.2,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            padding: EdgeInsets.all(10),
          ),
          _cooleyRack(nodes.sublist(i * 21, (i + 1) * 21),
              MediaQuery.of(context).orientation),
        ]),
      ));
    }
    return Container(
      child: PageView.builder(
          pageSnapping: false,
          itemCount:
              (MediaQuery.of(context).orientation == Orientation.portrait)
                  ? 3
                  : 2,
          itemBuilder: (context, j) {
            if (MediaQuery.of(context).orientation == Orientation.portrait) {
              if (j < 2) {
                return Row(
                  children: [
                    _cooleyRack(nodes.sublist(j * 21, (j + 1) * 21),
                        MediaQuery.of(context).orientation),
                    _cooleyRack(nodes.sublist((j + 1) * 21, ((j + 1) + 1) * 21),
                        MediaQuery.of(context).orientation),
                    _cooleyRack(nodes.sublist((j + 2) * 21, ((j + 2) + 1) * 21),
                        MediaQuery.of(context).orientation),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                );
              } else {
                return null;
              }
            } else {
              if (j == 0) {
                return Row(
                  children: [
                    _cooleyRack(nodes.sublist(j * 21, (j + 1) * 21),
                        MediaQuery.of(context).orientation),
                    _cooleyRack(nodes.sublist((j + 1) * 21, ((j + 1) + 1) * 21),
                        MediaQuery.of(context).orientation),
                    _cooleyRack(nodes.sublist((j + 2) * 21, ((j + 2) + 1) * 21),
                        MediaQuery.of(context).orientation),
                    _cooleyRack(nodes.sublist((j + 3) * 21, ((j + 3) + 1) * 21),
                        MediaQuery.of(context).orientation),
                    _cooleyRack(nodes.sublist((j + 4) * 21, ((j + 4) + 1) * 21),
                        MediaQuery.of(context).orientation),
                    _cooleyRack(nodes.sublist((j + 5) * 21, ((j + 5) + 1) * 21),
                        MediaQuery.of(context).orientation),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                );
              } else {
                return null;
              }
            }
          }),
      height: MediaQuery.of(context).orientation == Orientation.portrait
          ? (MediaQuery.of(context).size.width - 48) * .75
          : (MediaQuery.of(context).size.width / 2 - 24) * .75,
    );
  }

  /// Rack visualization for Cooley
  _cooleyRack(List nodes, orientation) {
    return Container(
      width: orientation == Orientation.portrait
          ? (MediaQuery.of(context).size.width / 3 - 24)
          : (MediaQuery.of(context).size.width / 6 - 24),
      height: orientation == Orientation.portrait
          ? (MediaQuery.of(context).size.width - 48)
          : (MediaQuery.of(context).size.width - 48),
      padding: EdgeInsets.all(4),
      child: CustomPaint(
        painter: RackPainter(3, 7, nodes),
      ),
    );
  }
}
