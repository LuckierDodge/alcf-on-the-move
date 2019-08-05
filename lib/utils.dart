import 'package:flutter/material.dart';

hyphen_range(String s) {
  List<int> r = [];
  s.split(",").forEach((x) {
    List<String> t = x.split('-');
    r.add((t.length == 1)
        ? int.parse(t[0])
        : Iterable<int>.generate(
                int.parse(t[1]) - int.parse(t[0]), (i) => i + int.parse(t[0]))
            .toList());
  });
  r.sort();
  return r;
}

parseColor(String c) {
  return Color.fromARGB(
    255,
    int.parse(c.toString().substring(1, 3), radix: 16),
    int.parse(c.toString().substring(3, 5), radix: 16),
    int.parse(c.toString().substring(5, 7), radix: 16),
  );
}
