import 'package:flutter/material.dart';

class Swatch {
  MaterialColor materialColor;
  Map<int, Color> color;

  Swatch(int colorCode) {
    Color color = Color(colorCode);
    this.color = {
      50: Color.fromRGBO(color.red, color.green, color.blue, .1),
      100: Color.fromRGBO(color.red, color.green, color.blue, .2),
      200: Color.fromRGBO(color.red, color.green, color.blue, .3),
      300: Color.fromRGBO(color.red, color.green, color.blue, .4),
      400: Color.fromRGBO(color.red, color.green, color.blue, .5),
      500: Color.fromRGBO(color.red, color.green, color.blue, .6),
      600: Color.fromRGBO(color.red, color.green, color.blue, .7),
      700: Color.fromRGBO(color.red, color.green, color.blue, .8),
      800: Color.fromRGBO(color.red, color.green, color.blue, .9),
      900: Color.fromRGBO(color.red, color.green, color.blue, 1),
    };

    this.materialColor = MaterialColor(colorCode, this.color);
  }
}

Map<String, Swatch> ALCFSwatch = {
  "lightestBlue": Swatch(0xFFE7F6FD),
  "lightBlue": Swatch(0xFFBADEF5),
  "Blue": Swatch(0xFF5D88C6),
  "darkBlue": Swatch(0xFF0061af),
  "darkestBlue": Swatch(0xFF1D1651),
  "lightestGreen": Swatch(0xFFF2F9F8),
  "lightGreen": Swatch(0xFFB8E2DE),
  "Green": Swatch(0xFF007B70),
  "darkGreen": Swatch(0xFF002A41),
  "darkestGreen": Swatch(0xFF003A41),
  "lightestRed": Swatch(0xFFFFF6F4),
  "lightRed": Swatch(0xFFFCD9D5),
  "Red": Swatch(0xFFEE6254),
  "darkRed": Swatch(0xFFD23C51),
  "darkestRed": Swatch(0xFF640033),
  "White": Swatch(0xFFFFFFFF),
  "lightGray": Swatch(0xFFEDF1F5),
  "Gray": Swatch(0xFFD8DCE1),
  "darkGray": Swatch(0xFF6E6E78),
  "Black": Swatch(0xFF080812),
};
