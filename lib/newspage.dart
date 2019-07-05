import 'package:flutter/material.dart';
import 'status.dart';
import 'noconnection.dart';
import 'settings.dart';
import 'package:connectivity/connectivity.dart';
import 'alcfscraper.dart';

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
        future: scrape(), builder: (context, snapshot) {});
//    return ListView.builder(
//        padding: const EdgeInsets.all(10.0), itemBuilder: (context, i) {});
  }

  Future<void> _refreshStatus() async {
    var tempCon = await Connectivity().checkConnectivity();
    this.setState(() {
      connectivity = tempCon;
    });
  }

  Future<void> _checkConnectivity() async {
    var tempCon = await Connectivity().checkConnectivity();
    setState(() {
      connectivity = tempCon;
    });
  }
}
