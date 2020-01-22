import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';

/// ALCF Scraper
///
/// Contains a CarouselItem class that represents a single news item from
/// alcf.anl.gov, a scrape() function which queries alcf.anl.gov and uses the
/// data to populate a NewsContent class which then is displayed in the NewsPage
/// widget defined in newspage.dart

class CarouselItem {
  String imageURL;
  String title;
  String text;
  String link;

  CarouselItem(this.imageURL, this.title, this.text, this.link);
}

class ALCFRSS {
  final _targetUrl = 'https://www.alcf.anl.gov/news/rss.xml';

  Future<List<CarouselItem>> getFeed() async {
    RssFeed rssFeed = await http
        .read(_targetUrl)
        .then((xmlString) => RssFeed.parse(xmlString));
    List<CarouselItem> carouselList = new List();
    rssFeed.items.forEach((item) async {
      var client = http.Client();
      http.Response response = await client.get(item.link);
      var imageURL;
      if (response.statusCode == 200) {
        var doc = parse(response.body);
        Element firstImage = doc.querySelectorAll('img')[3];
        imageURL = firstImage.attributes['src'].toString();
      } else {
        // Fail softly if there's a problem
        throw Exception(
            "Error when fetching data from https://www.alcf.anl.gov/");
      }
      carouselList.add(CarouselItem('https://www.alcf.anl.gov' + imageURL,
          item.title, item.description, item.link));
    });
    return carouselList;
  }
}
