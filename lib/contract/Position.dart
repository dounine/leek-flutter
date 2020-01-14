import 'package:flutter/material.dart';

class Position extends StatefulWidget {
  Position({Key key}) : super(key: key);

  @override
  _PositionState createState() {
    return _PositionState();
  }
}

class _PositionState extends State<Position> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Text("position"),
    );
  }
}
