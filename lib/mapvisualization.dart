import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import 'activity.dart';
import 'utils.dart';

/// Map Visualization
///
/// Displays a series of nested collapsible visualizations showing the breakdown
/// of jobs running on each row, rack, midplane, and node.
///
/// Unfortunately, there's a frustrating amount of machine specific code thanks
/// to the way the data comes in.

class MapVis extends StatefulWidget {
  MapVis(this.name, this.activity, {Key key}) : super(key: key);
  final String name;
  final Activity activity;
  @override
  MapVisState createState() => MapVisState(name, activity);
}

/// A simple encapsulation of everything we need to know about a node
class Node {
  String id;
  int jobid;
  String color;
  Node(this.id, this.jobid, this.color);
}

class MapVisState extends State<MapVis> {
  final String name;
  final Activity activity;

  MapVisState(this.name, this.activity);

  /// Builds the widget depending on the machine in question
  @override
  Widget build(BuildContext context) {
    if (name == "Mira" || name == "Cetus" || name == "Vesta") {
      return _miraCetusVestaVis();
    } else if (name == "Theta") {
      return _thetaVis();
    } else if (name == "Cooley") {
      return _cooleyVis();
    }
  }

  /// Map vis for Mira, Cetus, and Vesta
  /// Nodes are nested into rows, racks, and midplanes because we extract them
  /// using a String based key that we have to build programmatically.
  _miraCetusVestaVis() {
    var rowList = [];
    for (var row = 0; row < activity.dimensions.rows; row++) {
      var rackList = [];
      for (var rack = 0 + activity.dimensions.racks * row;
          rack < activity.dimensions.racks + activity.dimensions.racks * row;
          rack++) {
        String rackPrefix =
            "R" + rack.toRadixString(16).toUpperCase().padLeft(2, '0');
        var mpList = [];
        for (var mp = 0; mp < activity.dimensions.midplanes; mp++) {
          String mpPrefix = "M" + mp.toString();
          var nodeList = [];
          for (var node = 0; node < activity.dimensions.nodecards; node++) {
            String nodePostfix = "N" + node.toString().padLeft(2, '0');
            String nodeKey = rackPrefix + '-' + mpPrefix + '-' + nodePostfix;
            if (activity.nodeInfo.containsKey(nodeKey)) {
              nodeList.add(Node(nodeKey, activity.nodeInfo[nodeKey].jobid,
                  activity.nodeInfo[nodeKey].color));
            } else {
              // Add an "empty" node
              nodeList.add(Node(nodeKey, 0, "#FFFFFF"));
            }
          }
          mpList.add(nodeList);
        }
        rackList.add(mpList);
      }
      rowList.add(rackList);
    }

    // Add each row for the machine
    List<Widget> widgetList = [];
    var i = 0;
    rowList.forEach((row) {
      widgetList.add(ExpandableNotifier(
          child: ExpandablePanel(
        collapsed: _mcvRow(false, row, i),
        expanded: _mcvRow(true, row, i),
        tapHeaderToExpand: true,
        tapBodyToCollapse: true,
        hasIcon: false,
      )));
      i++;
    });

    return Column(
      children: widgetList,
    );
  }

  /// Row visualization for Mira/Cetus/Vesta
  _mcvRow(bool expanded, List rackList, int i) {
    List<Widget> widgetList = [];
    widgetList.add(Text(
      "Row " + i.toString(),
      textScaleFactor: 1.2,
      style: TextStyle(fontWeight: FontWeight.bold),
    ));
    // When expanded, show the Rack Visualizations
    if (expanded) {
      rackList.forEach((rack) {
        widgetList.add(ExpandableNotifier(
            child: ExpandablePanel(
          collapsed: _mcvRack(false, rack),
          expanded: _mcvRack(true, rack),
          tapHeaderToExpand: true,
          tapBodyToCollapse: true,
          hasIcon: false,
        )));
      });
      // When collapsed, show the Bar visualization
    } else {
      var nodeColors = {};
      rackList.forEach((rack) {
        rack.forEach((mp) {
          mp.forEach((node) {
            if (!nodeColors.containsKey(node.color)) {
              nodeColors[node.color] = 1;
            } else {
              nodeColors[node.color]++;
            }
          });
        });
      });
      var nodeTotals = activity.dimensions.midplanes *
          activity.dimensions.nodecards *
          activity.dimensions.racks;
      List<Widget> barList = [];
      nodeColors.forEach((key, value) {
        barList.add(Container(
            width: MediaQuery.of(context).size.width * .9 * value / nodeTotals,
            height: 40,
            child: Card(color: parseColor(key))));
      });
      widgetList.add(Row(
        children: barList,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
      ));
    }
    widgetList.add(Divider());
    return Column(
      children: widgetList,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  /// Rack visualization for Mira/Cetus/Vesta
  _mcvRack(bool expanded, List mpList) {
    List<Widget> widgetList = [];
    List<Widget> subList = [];
    widgetList.add(Text("Rack R" + mpList[0][0].id.toString().substring(1, 3)));
    // When expanded, show the Midplanes Visualization
    if (expanded) {
      mpList.forEach((mp) {
        subList.add(_mcvMP(mp));
      });
      // When collapsed, show the Bar visualization
    } else {
      var nodeColors = {};
      mpList.forEach((mp) {
        mp.forEach((node) {
          if (!nodeColors.containsKey(node.color)) {
            nodeColors[node.color] = 1;
          } else {
            nodeColors[node.color]++;
          }
        });
      });
      var nodeTotals =
          activity.dimensions.midplanes * activity.dimensions.nodecards;
      nodeColors.forEach((key, value) {
        subList.add(Container(
            width: MediaQuery.of(context).size.width * .9 * value / nodeTotals,
            height: 40,
            child: Card(color: parseColor(key))));
      });
    }
    widgetList.add(Row(
      children: subList,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
    ));
    widgetList.add(Divider());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widgetList,
    );
  }

  /// Midplanes visualization for Mira/Cetus/Vesta
  _mcvMP(List nodeList) {
    return Container(
        width: MediaQuery.of(context).size.width * .45,
        height: MediaQuery.of(context).size.width * .45,
        padding: EdgeInsets.all(4),
        child: GridView.count(
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            children: nodeList.map((node) {
              return GridTile(
                child: Container(child: Card(color: parseColor(node.color))),
              );
            }).toList()));
  }

  /// Map vis for Theta
  /// Nodes are numbered, so we store them in one giant array that we group
  /// using known dimensions.
  _thetaVis() {
    List<Widget> widgetList = [];
    List<Node> nodes = new List<Node>(4608);
    activity.runningJobs.forEach((job) {
      // Extract the nodes for each job and put a Node object in it's index
      List<int> nodeIds = hyphen_range((job.location as List)[0]);
      nodeIds.forEach((node) {
        nodes[node - 1] = Node(node.toString(), job.jobid, job.color);
      });
    });
    // Go through all the nodes and fill in unused nodes with a blank node object
    for (int i = 0; i < 4608; i++) {
      if (nodes[i] == null) {
        nodes[i] = Node(i.toString(), 0, "#FFFFFF");
      }
    }

    // Add row visualizations
    for (int i = 0; i < 2; i++) {
      widgetList.add(ExpandableNotifier(
          child: ExpandablePanel(
        collapsed: _thetaRow(false, nodes.sublist(i * 2304, (i + 1) * 2304), i),
        expanded: _thetaRow(true, nodes.sublist(i * 2304, (i + 1) * 2304), i),
        tapHeaderToExpand: true,
        tapBodyToCollapse: true,
        hasIcon: false,
      )));
    }

    return Column(children: widgetList);
  }

  /// Row visualization for Theta
  _thetaRow(bool expanded, List nodes, int i) {
    List<Widget> widgetList = [];
    widgetList.add(Text(
      "Row " + i.toString(),
      textScaleFactor: 1.2,
      style: TextStyle(fontWeight: FontWeight.bold),
    ));
    // If expanded, add Rack visualizations
    if (expanded) {
      for (int j = 0; j < 12; j++) {
        widgetList.add(ExpandableNotifier(
            child: ExpandablePanel(
          collapsed:
              _thetaRack(false, nodes.sublist(j * 192, (j + 1) * 192), i, j),
          expanded:
              _thetaRack(true, nodes.sublist(j * 192, (j + 1) * 192), i, j),
          tapHeaderToExpand: true,
          tapBodyToCollapse: true,
          hasIcon: false,
        )));
      }
      // If collapsed, show bar vis
    } else {
      var nodeColors = _getNodeColors(nodes);
      var nodeTotals = 4608 / 2;
      List<Widget> barList = [];
      nodeColors.forEach((key, value) {
        barList.add(Container(
            width: MediaQuery.of(context).size.width * .9 * value / nodeTotals,
            height: 40,
            child: Card(color: parseColor(key))));
      });
      widgetList.add(Row(
        children: barList,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
      ));
    }
    widgetList.add(Divider());
    return Column(
      children: widgetList,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  /// Rack visualization for Theta
  _thetaRack(bool expanded, List nodes, int i, int j) {
    List<Widget> widgetList = [];
    widgetList.add(Text("c$j-$i"));
    // If expanded, add node grid
    if (expanded) {
      widgetList.add(_thetaGrid(nodes));
      // If collapsed, add bar vis
    } else {
      var nodeColors = _getNodeColors(nodes);
      var nodeTotals = 192;
      List<Widget> barList = [];
      nodeColors.forEach((key, value) {
        barList.add(Container(
            width: MediaQuery.of(context).size.width * .9 * value / nodeTotals,
            height: 40,
            child: Card(color: parseColor(key))));
      });
      widgetList.add(Row(
        children: barList,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
      ));
    }
    widgetList.add(Divider());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widgetList,
    );
  }

  /// Node Grid visualization for Theta
  _thetaGrid(List nodeList) {
    return Container(
        width: MediaQuery.of(context).size.width * .9,
        height: MediaQuery.of(context).size.width * .9 * .75,
        padding: EdgeInsets.all(4),
        child: GridView.count(
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 16,
            children: nodeList.map((node) {
              return GridTile(
                child: Container(child: Card(color: parseColor(node.color))),
              );
            }).toList()));
  }

  /// TODO: Make a vis for Cooley
  _cooleyVis() {}

  /// Gets color distribution for a list of nodes
  _getNodeColors(List<Node> nodes) {
    var nodeColors = {};
    nodes.forEach((node) {
      if (!nodeColors.containsKey(node.color)) {
        nodeColors[node.color] = 1;
      } else {
        nodeColors[node.color]++;
      }
    });
    return nodeColors;
  }
}
