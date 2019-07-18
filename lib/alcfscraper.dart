import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

Future<NewsContent> scrape() async {
  var client = Client();
  Response response = await client.get('https://www.alcf.anl.gov/');
  if (response.statusCode == 200) {
    var doc = parse(response.body);
    List<Element> carouselItems = doc.querySelectorAll('.slide-inner.clearfix');
    List<Element> announcements = doc.querySelectorAll('.center-wrapper');
    return NewsContent(carouselItems, announcements);
//    List<Element> newsItems =
//        doc.querySelectorAll('.view .view-inthenews-homepage');
//    newsItems.addAll(doc.querySelectorAll('.view-content'));
//    newsItems.addAll(doc.querySelectorAll('.views-row'));
//    List<Element> eventItems =
//        doc.querySelectorAll('.view .view-events-homepage');
  } else {
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
        print("Bad news item.");
      }
    });
  }
}

class CarouselItem {
  String imageURL;
  String title;
  String text;
  String link;

  CarouselItem(this.imageURL, this.title, this.text, this.link);
}
