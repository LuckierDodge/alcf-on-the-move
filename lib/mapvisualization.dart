import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import 'activity.dart';

class MapVis extends StatefulWidget {
  MapVis(this.name, this.activity, {Key key}) : super(key: key);
  final String name;
  final Activity activity;
  @override
  MapVisState createState() => MapVisState(name, activity);
}

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

  @override
  Widget build(BuildContext context) {
    if (name == "Mira" || name == "Cetus" || name == "Vesta") {
      return _miraCetusVestaVis();
//    } else if (name == "Theta" || name == "Cooley") {
    } else {
      return _thetaCooleyVis();
    }
  }

  _miraCetusVestaVis() {
    var rowList = [];
    for (var row = 0; row < activity.dimensions.rows; row++) {
      var rackList = [];
      for (var rack = 0; rack < activity.dimensions.racks; rack++) {
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
              nodeList.add(Node(nodeKey, 0, "#FFFFFF"));
            }
          }
          mpList.add(nodeList);
        }
        rackList.add(mpList);
      }
      rowList.add(rackList);
    }

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

  _mcvRow(bool expanded, List rackList, int i) {
    if (expanded) {
      List<Widget> widgetList = [];
      widgetList.add(Text(
        "Row " + i.toString(),
        textScaleFactor: 2.0,
      ));
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
      widgetList.add(Divider());
      return Column(children: widgetList);
    } else {
      List<Widget> widgetList = [];
      widgetList.add(Text(
        "Row " + i.toString(),
        textScaleFactor: 2.0,
      ));
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
            child: Card(
                color: Color.fromARGB(
              255,
              int.parse(key.toString().substring(1, 3), radix: 16),
              int.parse(key.toString().substring(3, 5), radix: 16),
              int.parse(key.toString().substring(5, 7), radix: 16),
            ))));
      });
      widgetList.add(Row(children: barList));
      widgetList.add(Divider());
      return Column(
        children: widgetList,
      );
    }
  }

  _mcvRack(bool expanded, List mpList) {
    if (expanded) {
      List<Widget> widgetList = [];
      mpList.forEach((mp) {
        widgetList.add(_mcvMP(mp));
      });
      return Column(children: [
        Text("Rack R" + mpList[0][0].id.toString().substring(1, 3)),
        Row(children: widgetList),
        Divider()
      ]);
    } else {
      List<Widget> widgetList = [];
      widgetList
          .add(Text("Rack R" + mpList[0][0].id.toString().substring(1, 3)));
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
      List<Widget> barList = [];
      nodeColors.forEach((key, value) {
        barList.add(Container(
            width: MediaQuery.of(context).size.width * .9 * value / nodeTotals,
            height: 40,
            child: Card(
                color: Color.fromARGB(
              255,
              int.parse(key.toString().substring(1, 3), radix: 16),
              int.parse(key.toString().substring(3, 5), radix: 16),
              int.parse(key.toString().substring(5, 7), radix: 16),
            ))));
      });
      widgetList.add(Row(children: barList));
      widgetList.add(Divider());
      return Column(
        children: widgetList,
      );
    }
  }

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
                child: Container(
                    child: Card(
                  color: Color.fromARGB(
                    255,
                    int.parse(node.color.toString().substring(1, 3), radix: 16),
                    int.parse(node.color.toString().substring(3, 5), radix: 16),
                    int.parse(node.color.toString().substring(5, 7), radix: 16),
                  ),
                )),
              );
            }).toList()));
  }

  _thetaCooleyVis() {}
}
