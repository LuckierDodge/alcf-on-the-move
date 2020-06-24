import 'package:flutter/material.dart';

/// Utils
///
/// A collection of useful functions and widgets that might be needed in more
/// than one place

/// Generates a list of ints from a "1-5,10" style list
hyphenRange(String s) {
  List<int> r = [];
  s.split(",").forEach((x) {
    List<String> t = x.split('-');
    (t.length == 1)
        ? r.add(int.parse(t[0]))
        : r.addAll(Iterable<int>.generate(
            int.parse(t[1]) - int.parse(t[0]) + 1, (i) => i + int.parse(t[0])));
  });
  r.sort();
  return r;
}

/// Pulls a Color out of a #000000 style hex string
parseColor(String c) {
  try {
    return Color.fromARGB(
      255,
      int.parse(c.toString().substring(1, 3), radix: 16),
      int.parse(c.toString().substring(3, 5), radix: 16),
      int.parse(c.toString().substring(5, 7), radix: 16),
    );
  } catch (exception) {
    print(c);
    return Color.fromARGB(255, 255, 255, 255);
  }
}

/// Widget displayed when the device is disconnected from the internet
class NoConnection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(10.0),
      child: Card(
        child: Center(
          heightFactor: 100,
          widthFactor: 100,
          child: Text("You're Offline!"),
        ),
      ),
    );
  }
}

/// Returns a month string given its number
const List<String> _months = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];
String getTime() {
  DateTime now = DateTime.now();
  String month = _months[now.month - 1];
  return "$month ${now.day}, ${now.hour}:${(now.minute < 10) ? "0" + now.minute.toString() : now.minute}:${(now.second < 10) ? "0" + now.second.toString() : now.second}";
}
