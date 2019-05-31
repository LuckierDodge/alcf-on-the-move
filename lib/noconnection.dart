import 'package:flutter/material.dart';

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
