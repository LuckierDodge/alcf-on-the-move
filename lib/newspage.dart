import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'alcfscraper.dart';
import 'noconnection.dart';
import 'settings.dart';

class NewsPage extends StatefulWidget {
  NewsPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _NewsPageState createState() => _NewsPageState(title);
}

class _NewsPageState extends State<NewsPage> {
  final String title;
  String updatedTime;
  ConnectivityResult connectivity = ConnectivityResult.none;

  _NewsPageState(this.title);

  @override
  void initState() {
    super.initState();
    updatedTime = _getTime();
    _checkConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    if (connectivity == ConnectivityResult.none) {
      return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(title),
          ),
          actions: <Widget>[
            new IconButton(
                icon: const Icon(Icons.refresh), onPressed: _refreshStatus)
          ],
        ),
        body: RefreshIndicator(
          child: NoConnection(),
          onRefresh: _refreshStatus,
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(title),
          ),
          actions: <Widget>[
            new IconButton(
                icon: const Icon(Icons.refresh), onPressed: _refreshStatus),
            new IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Settings()));
                }),
          ],
        ),
        body: RefreshIndicator(
          child: _newsFeed(),
          onRefresh: _refreshStatus,
        ),
      );
    }
  }

  Widget _newsFeed() {
    return FutureBuilder<NewsContent>(
        future: scrape(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var items = snapshot.data.carouselItems;
            return ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemBuilder: (context, i) {
                  if (items == null && i == 0) {
                    return Card(
                        child: Center(child: Text("No Announcements!")));
                  } else if (i < items.length) {
                    return _announcement(items[i]);
                  } else if (i == items.length) {
                    return Card(
                      child: Container(
                          padding: EdgeInsets.all(10.0),
                          child: Text("Last Updated: $updatedTime")),
                    );
                  } else {
                    return null;
                  }
                });
          } else if (snapshot.hasError) {
            return Card(
              child: Center(
                heightFactor: 10,
                widthFactor: 10,
                child: Text(
//                    "Sorry, there was a problem loading the news feed."),
                  "Error: ${snapshot.error}",
                ),
              ),
            );
          }
          // By default, show a loading spinner
          return Card(
            child: Center(
              heightFactor: 10,
              widthFactor: 10,
              child: CircularProgressIndicator(),
            ),
          );
        });
  }

  Future<void> _refreshStatus() async {
    var tempCon = await Connectivity().checkConnectivity();
    this.setState(() {
      connectivity = tempCon;
      updatedTime = _getTime();
    });
  }

  Future<void> _checkConnectivity() async {
    var tempCon = await Connectivity().checkConnectivity();
    setState(() {
      connectivity = tempCon;
    });
  }

  Card _announcement(CarouselItem item) {
    return Card(
        child: FlatButton(
            onPressed: () {
              _openLink(item.link);
            },
            child: Column(
              children: [
                Image.network(item.imageURL),
                Center(
                    child: Text(
                  item.title.toString(),
                  style: TextStyle(fontSize: 20),
                )),
                Center(child: Text(item.text.toString()))
              ],
            )));
  }

  _openLink(String url) async {
//    const url =
//        'https://www.alcf.anl.gov/articles/us-department-energy-and-intel-deliver-first-exascale-supercomputer';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  String _getTime() {
    String month;
    DateTime now = DateTime.now();
    switch (now.month) {
      case 1:
        month = "January";
        break;
      case 2:
        month = "February";
        break;
      case 3:
        month = "March";
        break;
      case 4:
        month = "April";
        break;
      case 5:
        month = "May";
        break;
      case 6:
        month = "June";
        break;
      case 7:
        month = "July";
        break;
      case 8:
        month = "August";
        break;
      case 9:
        month = "September";
        break;
      case 10:
        month = "October";
        break;
      case 11:
        month = "November";
        break;
      case 12:
        month = "December";
        break;
    }
    return "$month ${now.day}, ${now.hour}:${(now.minute < 10) ? "0" + now.minute.toString() : now.minute}:${(now.second < 10) ? "0" + now.second.toString() : now.second}";
  }
}
