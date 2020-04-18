import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';

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

class TableVisState extends State<TableVis> {
  final String name;
  Activity activity;
  int thetaRowOffset = 2304;

  TableVisState(this.name, this.activity);

  Widget nodeCard(Node node) {
    if (node.color != '#FFFFFF') {
//      return Container(
      return InkWell(
        onTap: () {
          _launchDialog(node.color);
        },
        child: Card(color: parseColor(node.color)),
      );
    } else {
      return Container(
        child: Card(color: parseColor(node.color)),
      );
    }
  }

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
    }
  }

  /// Map vis for Theta
  /// Nodes are numbered, so we store them in one giant array that we group
  /// using known dimensions.
  _thetaVis() {
    List<Node> nodes = new List<Node>(4608);
    activity.runningJobs.forEach((job) {
      // Extract the nodes for each job and put a Node object in it's index
      List<int> nodeIds = hyphen_range((job.location as List)[0]);
      nodeIds.forEach((node) {
        nodes[node] = Node(node.toString(), job.jobid, job.color);
      });
    });
    // Go through all the nodes and fill in unused nodes with a blank node object
    for (int i = 0; i < 4608; i++) {
      if (nodes[i] == null) {
        nodes[i] = Node(i.toString(), 0, "#FFFFFF");
      }
    }

    List<Widget> widgetList = [];
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      for (int i = 0; i < 12; i++) {
        widgetList.add(Card(
            color: Colors.grey,
            child: Center(
              child: Text("$i",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              heightFactor: 2,
              widthFactor: 2,
            )));
      }
    } else {
      for (int i = 0; i < 6; i++) {
        widgetList.add(Card(
            color: Colors.grey,
            child: Center(
              child: Text("$i",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              heightFactor: 2,
              widthFactor: 2,
            )));
      }
    }
    // Add row visualizations
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
//      Row(
//        children: widgetList,
//        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//      ),
      Container(
        child: PageView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
//            physics: const CustomScrollPhysics(),
            pageSnapping: false,
//            allowImplicitScrolling: true,
            itemCount:
                (MediaQuery.of(context).orientation == Orientation.portrait)
                    ? 12
                    : 6,
            itemBuilder: (context, j) {
              if (MediaQuery.of(context).orientation == Orientation.portrait) {
                if (j < 12) {
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "c$j-0",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _thetaRack(nodes.sublist(j * 192, (j + 1) * 192),
                          Orientation.portrait),
                      Divider(),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "c$j-1",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _thetaRack(
                          nodes.sublist(j * 192 + thetaRowOffset,
                              (j + 1) * 192 + thetaRowOffset),
                          Orientation.portrait),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                  );
                } else {
                  return null;
                }
              } else {
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
                                    "c${2 * j}-0",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                _thetaRack(
                                    nodes.sublist(
                                        2 * j * 192, (2 * j + 1) * 192),
                                    Orientation.landscape)
                              ]),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    "c${2 * j + 1}-0",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                _thetaRack(
                                    nodes.sublist(
                                        (2 * j + 1) * 192, (2 * j + 2) * 192),
                                    Orientation.landscape)
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
                                    "c${2 * j}-1",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                _thetaRack(
                                    nodes.sublist(2 * j * 192 + thetaRowOffset,
                                        (2 * j + 1) * 192 + thetaRowOffset),
                                    Orientation.landscape)
                              ]),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    "c${2 * j + 1}-1",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                _thetaRack(
                                    nodes.sublist(
                                        (2 * j + 1) * 192 + thetaRowOffset,
                                        (2 * j + 2) * 192 + thetaRowOffset),
                                    Orientation.landscape)
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
              }
            }),
        height: MediaQuery.of(context).orientation == Orientation.portrait
            ? (MediaQuery.of(context).size.width - 48) * .75 * 2 + 100
            : (MediaQuery.of(context).size.width / 2 - 24) * .75 * 2 + 100,
      )
    ]);
  }

  /// Rack visualization for Theta
  _thetaRack(List nodeList, Orientation orientation) {
    return Container(
        width: orientation == Orientation.portrait
            ? (MediaQuery.of(context).size.width - 48)
            : (MediaQuery.of(context).size.width / 2 - 24),
        height: orientation == Orientation.portrait
            ? (MediaQuery.of(context).size.width - 48) * .75
            : (MediaQuery.of(context).size.width / 2 - 24) * .75,
        padding: EdgeInsets.all(4),
        child: GridView.count(
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 16,
            children: nodeList.map((node) {
              return GridTile(
                child: Container(child: nodeCard(node)),
              );
            }).toList()));
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
//    return ListView(
//      physics: NeverScrollableScrollPhysics(),
//      children: widgetList,
//      shrinkWrap: true,
//    );
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
//                    Container(
//                      padding: EdgeInsets.all(10),
//                      child: Text(
//                        "Rack $j",
//                        style: TextStyle(fontWeight: FontWeight.bold),
//                      ),
//                    ),
                    _cooleyRack(nodes.sublist(j * 21, (j + 1) * 21),
                        MediaQuery.of(context).orientation),
//                    Container(
//                      padding: EdgeInsets.all(10),
//                      child: Text(
//                        "Rack ${j + 1}",
//                        style: TextStyle(fontWeight: FontWeight.bold),
//                      ),
//                    ),
                    _cooleyRack(nodes.sublist((j + 1) * 21, ((j + 1) + 1) * 21),
                        MediaQuery.of(context).orientation),
//                    Container(
//                      padding: EdgeInsets.all(10),
//                      child: Text(
//                        "Rack ${j + 2}",
//                        style: TextStyle(fontWeight: FontWeight.bold),
//                      ),
//                    ),
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
//                    Container(
//                      padding: EdgeInsets.all(10),
//                      child: Text(
//                        "Rack $j",
//                        style: TextStyle(fontWeight: FontWeight.bold),
//                      ),
//                    ),
                    _cooleyRack(nodes.sublist(j * 21, (j + 1) * 21),
                        MediaQuery.of(context).orientation),
//                    Container(
//                      padding: EdgeInsets.all(10),
//                      child: Text(
//                        "Rack ${j + 1}",
//                        style: TextStyle(fontWeight: FontWeight.bold),
//                      ),
//                    ),
                    _cooleyRack(nodes.sublist((j + 1) * 21, ((j + 1) + 1) * 21),
                        MediaQuery.of(context).orientation),
//                    Container(
//                      padding: EdgeInsets.all(10),
//                      child: Text(
//                        "Rack ${j + 2}",
//                        style: TextStyle(fontWeight: FontWeight.bold),
//                      ),
//                    ),
                    _cooleyRack(nodes.sublist((j + 2) * 21, ((j + 2) + 1) * 21),
                        MediaQuery.of(context).orientation),
//                    Container(
//                      padding: EdgeInsets.all(10),
//                      child: Text(
//                        "Rack $j",
//                        style: TextStyle(fontWeight: FontWeight.bold),
//                      ),
//                    ),
                    _cooleyRack(nodes.sublist((j + 3) * 21, ((j + 3) + 1) * 21),
                        MediaQuery.of(context).orientation),
//                    Container(
//                      padding: EdgeInsets.all(10),
//                      child: Text(
//                        "Rack ${j + 1}",
//                        style: TextStyle(fontWeight: FontWeight.bold),
//                      ),
//                    ),
                    _cooleyRack(nodes.sublist((j + 4) * 21, ((j + 4) + 1) * 21),
                        MediaQuery.of(context).orientation),
//                    Container(
//                      padding: EdgeInsets.all(10),
//                      child: Text(
//                        "Rack ${j + 2}",
//                        style: TextStyle(fontWeight: FontWeight.bold),
//                      ),
//                    ),
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
        child: GridView.count(
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            children: nodes.map((node) {
              return GridTile(
                child: Container(child: nodeCard(node)),
              );
            }).toList()));
  }
}

class CustomScrollPhysics extends BouncingScrollPhysics {
  const CustomScrollPhysics({ScrollPhysics parent}) : super(parent: parent);

  @override
  Tolerance get tolerance => Tolerance(velocity: 0.0);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics ancestor) {
    return CustomScrollPhysics(parent: buildParent(ancestor));
  }
}
