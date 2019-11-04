import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'alcfscraper.dart';
import 'settings.dart';
import 'utils.dart';

/// News Page
///
/// Defines a NewsPage stateful widget and its NewsPageState class, for
/// displaying info scraped from alcf.anl.gov

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

  /// Runs before anything else
  @override
  void initState() {
    super.initState();
    updatedTime = getTime();
    _checkConnectivity();
  }

  /// Builds the widget, complete with Connectivity checking wrapper
  @override
  Widget build(BuildContext context) {
    Widget activeWidget;
    // Make sure the device is online
    if (connectivity == ConnectivityResult.none) {
      activeWidget = NoConnection();
    } else {
      activeWidget = _newsFeed();
    }
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(title),
        ),
        actions: <Widget>[
          //Refresh Button
          new IconButton(
              icon: const Icon(Icons.refresh), onPressed: _refreshStatus),
          // Settings Button
          new IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Settings()));
              }),
        ],
      ),
      body: RefreshIndicator(
        child: activeWidget,
        onRefresh: _refreshStatus,
      ),
    );
  }

  /// The actual list of announcements
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
                        // Probably a problem with the scraper, but the user doesn't need to know
                        child: Center(child: Text("No Announcements!")));
                  } else if (i < items.length) {
                    // Display each announcement
                    return _announcement(items[i]);
                  } else if (i == items.length) {
                    // Return the Last Updated time at the end
                    return Card(
                      child: Container(
                          padding: EdgeInsets.all(10.0),
                          child: Text("Last Updated: $updatedTime")),
                    );
                  } else {
                    // Appease the linter
                    return null;
                  }
                });
          } else if (snapshot.hasError) {
            return Card(
              child: Center(
                child: Text(
                  "Error: ${snapshot.error}",
                ),
              ),
            );
          }
          // By default, show a loading spinner
          return Card(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }

  /// Displays an individual announcement on the page
  Card _announcement(CarouselItem item) {
    return Card(
        child: FlatButton(
            onPressed: () {
              // Open a link when clicked
              _openLink(item.link);
            },
            child: Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Image.network(item.imageURL),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 4.0),
                      child: Center(
                          child: Text(
                        item.title.toString(),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
                      child: Center(child: Text(item.text.toString())),
                    )
                  ],
                ))));
  }

  /// Opens a link in a browser
  _openLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  ///
  /// Helper functions for refreshing and checking connectivity
  ///
  Future<void> _refreshStatus() async {
    var tempCon = await Connectivity().checkConnectivity();
    this.setState(() {
      connectivity = tempCon;
      updatedTime = getTime();
    });
  }

  Future<void> _checkConnectivity() async {
    var tempCon = await Connectivity().checkConnectivity();
    setState(() {
      connectivity = tempCon;
    });
  }
}
