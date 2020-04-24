import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'alcf_rss.dart';
import 'settings.dart';
import 'utils.dart';
import 'news_feed_icons.dart';

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
    return FutureBuilder<List<CarouselItem>>(
        future: ALCFRSS().getFeed(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return announcementList(snapshot.data);
          } else if (snapshot.hasError) {
            return Card(
              child: Center(
                child: Text(
                  "Error: ${snapshot.error}",
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Card(
              child: Center(
                heightFactor: 10,
                widthFactor: 10,
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

  ListView announcementList(items) {
    return ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemBuilder: (context, i) {
          if (i == 0) {
            return Card(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Wrap(
                      direction: Axis.horizontal,
                      spacing: 15,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(NewsFeedIcons.facebook),
                              onPressed: () {
                                _openLink(
                                    'https://www.facebook.com/pages/Argonne-Leadership-Computing-Facility/33428102469');
                              },
                            ),
                            Text("Facebook"),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(NewsFeedIcons.twitter),
                              onPressed: () {
                                _openLink('https://twitter.com/argonne_lcf');
                              },
                            ),
                            Text("Twitter"),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(NewsFeedIcons.linkedin),
                              onPressed: () {
                                _openLink(
                                    'https://www.linkedin.com/company/argonne-leadership-computing-facility/');
                              },
                            ),
                            Text("LinkedIn"),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(NewsFeedIcons.youtube_play),
                              onPressed: () {
                                _openLink(
                                    'https://www.youtube.com/channel/UCFJAl2p722-FJ-ojxxYyrrw');
                              },
                            ),
                            Text("YouTube"),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.help),
                              onPressed: () {
                                _openLink('mailto:helpdesk@cels.anl.gov');
                              },
                            ),
                            Text("Helpdesk"),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.open_in_browser),
                              onPressed: () {
                                _openLink('https://www.alcf.anl.gov');
                              },
                            ),
                            Text("On the Web"),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          } else if (items == null && i == 1) {
            return Card(
                // Probably a problem with the scraper, but the user doesn't need to know
                child: Center(child: Text("No Announcements!")));
          } else if (i > 0 && i <= items.length) {
            // Display each announcement
            return _announcement(items[i - 1]);
          } else if (i == items.length + 1 && i != 0) {
            // Return the Last Updated time at the end
            return Card(
              child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Last Updated: $updatedTime")),
            );
          }
          // Appease the linter
          return null;
        });
  }

  /// Displays an individual announcement on the page
  Card _announcement(CarouselItem item) {
    return Card(
        child: InkWell(
            onTap: () {
              // Open a link when clicked
              _openLink(item.link);
            },
            child: Container(
                padding: EdgeInsets.all(10.0),
                child: Column(children: [
                  Container(
                    child: Text(
                      item.title.toString(),
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.left,
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  Divider(),
                  Row(
                    children: [
                      FutureBuilder(
                          future: item.getImage(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Image.network(
                                snapshot.data,
                                width:
                                    MediaQuery.of(context).size.width / 2 - 30,
                                fit: BoxFit.fitWidth,
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                heightFactor: 10,
                                widthFactor: 10,
                                child: Text(
                                  "Error: ${snapshot.error}",
                                ),
                              );
                            } else {
                              return Container(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  width: MediaQuery.of(context).size.width / 2 -
                                      30);
                            }
                          }),
                      Container(
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
                            child: Center(
                                child: Text(item.text.toString().replaceAll(
                                    RegExp(r"<[^>]*>",
                                        multiLine: true, caseSensitive: true),
                                    ''))),
                          ),
//                          ],
//                        ),
                          width: MediaQuery.of(context).size.width / 2 - 30),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  )
                ]))));
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
