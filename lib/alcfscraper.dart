import 'package:http/http.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart';
import 'dart:convert';

//initiate() async {
//  var client = Client();
//  Response response = await client.get('https://www.alcf.anl.gov/');
//  print(response.body);
//}

Future<NewsContent> scrape() async {
  var client = Client();
  Response response = await client.get('https://www.alcf.anl.gov/');
  if (response.statusCode == 200) {
    var doc = parse(response.body);
    List<Element> carouselItems =
        doc.querySelectorAll('.slide-inner .clearfix');
    return NewsContent(carouselItems);
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

  NewsContent(List<Element> carouselItems) {
    carouselItems.forEach((item) => {
          this.carouselItems.add(CarouselItem(
                item.querySelector('img').attributes['src'],
                item.querySelector('h2').querySelector('a').text.toString(),
                item.querySelector('p').text.toString(),
                item.querySelector('h2').querySelector('a').attributes['href'],
              ))
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
