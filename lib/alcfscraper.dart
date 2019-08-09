import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

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

Future<NewsContent> scrape() async {
  var client = Client();
  Response response = await client.get('https://www.alcf.anl.gov/');
  if (response.statusCode == 200) {
    // Scrape if statusCode is OK
    var doc = parse(response.body);
    // Grab elements from the carousel first
    List<Element> carouselItems = doc.querySelectorAll('.slide-inner.clearfix');
    // Also get the announcements
    List<Element> announcements = doc.querySelectorAll('.center-wrapper');
    return NewsContent(carouselItems, announcements);
  } else {
    // Fail softly if there's a problem
    throw Exception("Error when fetching data from https://www.alcf.anl.gov/");
  }
}

class NewsContent {
  List<CarouselItem> carouselItems;

  NewsContent(List<Element> carouselItems, List<Element> announcements) {
    this.carouselItems = [];
    carouselItems.forEach((item) {
      try {
        this.carouselItems.add(CarouselItem(
              item.querySelector('img').attributes['src'].toString(),
              item.querySelector('h2').querySelector('a').text.toString(),
              item.querySelector('p').text.toString().toString(),
              'https://www.alcf.anl.gov' +
                  item
                      .querySelector('h2')
                      .querySelector('a')
                      .attributes['href']
                      .toString(),
            ));
      } catch (exception) {
        // This should only crop up if they've changed the layout of the webpage
        print("Bad news item.");
      }
    });
    announcements.forEach((item) {
      try {
        this.carouselItems.add(CarouselItem(
              item.querySelector('img').attributes['src'].toString(),
              item.querySelectorAll('h3')[1].querySelector('a').text.toString(),
              item.querySelectorAll('p')[1].text.toString().toString(),
              item
                  .querySelectorAll('h3')[1]
                  .querySelector('a')
                  .attributes['href']
                  .toString(),
            ));
      } catch (exception) {
        // This should only crop up if they've changed the layout of the webpage
        print("Bad news item.");
      }
    });
  }
}
