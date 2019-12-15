import 'package:flutter/material.dart';

class MultiSlider2 extends StatefulWidget {
  final Function onChange1;
  final Function onChange2;
  final num defaultValue1;
  final num defaultValue2;
  final num minValue;
  final num maxValue;
  final num setup;

  MultiSlider2(
      {Key key,
      @required this.minValue,
      @required this.maxValue,
      @required this.defaultValue1,
      @required this.defaultValue2,
      @required this.setup,
      @required this.onChange1,
      @required this.onChange2
      })
      : super(key: key);

  @override
  _MultiSlider2State createState() {
    return _MultiSlider2State();
  }
}

class _MultiSlider2State extends State<MultiSlider2> with SingleTickerProviderStateMixin {
  AnimationController controller;
  CurvedAnimation curved;
  bool enableTouch1 = true; //是否允许触摸
  bool enableTouch2 = true; //是否允许触摸
  double value1 = 0.0; //默认值
  double value2 = 0.0; //默认值
  int valueFixed = 2;
  double minValue = 0.0; //最小值
  double maxValue = 0.0; //最大值
  double setup = 0.0; //步进值

  double width = 300;
  double height = 10;
  double left1 = 0.0;
  double left2 = 0.0;
  double _left1 = 0.0;
  double _left2 = 0.0;
  double initial = 0.0;

  double pointWidth = 26;
  double pointHeight = 26;
  double pointBorderWidth = 6;
  double pointBorderRadius = 26;
  Color pointBorderColor = Colors.green;
  Color pointColor = Colors.white;
  double pointScale = 1.0;
  double baseWidth = 0.0;

  List<Widget> splits;

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
    // TODO: implement build
    return null;
  }
}
