import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/components/cslider.dart';
import 'package:vibrate/vibrate.dart';

class CustomliderWidget2 extends StatefulWidget {
  final Function onChange;
  final num defaultValue1;
  final num defaultValue2;
  final num minValue;
  final num maxValue;
  final num setup;
  final num fixed;
  final String eventName;

  CustomliderWidget2(
      {Key key,
      @required this.minValue,
      @required this.maxValue,
      @required this.defaultValue1,
      @required this.defaultValue2,
      @required this.setup,
      @required this.fixed,
      @required this.onChange,
      this.eventName})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomliderState2();
}

class _CustomliderState2 extends State<CustomliderWidget2>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  CurvedAnimation curved;
  bool enableTouch = true; //是否允许触摸
  double value1 = -1; //默认值1
  double value2 = -1; //默认值2
  int fixed = 0;
  double minValue = 0.0; //最小值
  double maxValue = 0.0; //最大值
  double setup = 0.0; //步进值

  double width = 300;
  double height = 15;
  double sliderHeight = 15;
  double left1 = 0.0;
  double _left1 = 0.0;
  double left2 = 0.0;
  double _left2 = 0.0;
  double initial = 0.0;

  double pointWidth1 = 16;
  double pointHeight1 = 30;
  double pointBorderWidth1 = 4;
  double pointBorderRadius1 = 10;

  double pointWidth2 = 16;
  double pointHeight2 = 30;
  double pointBorderWidth2 = 4;
  double pointBorderRadius2 = 10;

  Color pointBorderColor1 = Colors.green;
  Color pointColor1 = Colors.white;

  Color pointBorderColor2 = Colors.grey;
  Color pointColor2 = Colors.white;

  double pointScale = 1.0;
  double baseWidth = 0.0;

  List<Widget> splits;
  StreamSubscription subEvent;

  @override
  void initState() {
    controller = new AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this); //动画控制器
    curved = new CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    fixed = widget.fixed;
    setup = widget.setup.toDouble();
    minValue = widget.minValue.toDouble();
    maxValue = widget.maxValue.toDouble();
    value1 = widget.defaultValue1.toDouble();
    value2 = widget.defaultValue2.toDouble();

    //基数、每个值占多少宽度
    baseWidth = width / maxValue;

    left1 = baseWidth * value1;
    left2 = baseWidth * value2;
    if (widget.eventName != null) {
      subEvent = Config.eventBus.on<PushEvent>().listen((event) {
        var i = 1;
        widget.eventName.split(",").forEach((eventName) {
          if (event.name == eventName) {
            if (i == 1) {
              setState(() {
                value1 = event.value;
                left1 = baseWidth * value1;
              });
            } else {
              setState(() {
                value2 = event.value;
                left2 = baseWidth * value2;
              });
            }
          }
          i = i + 1;
        });
      });
    }

    //分隔线
    splits = [
//      Container(
//        width: 2.0,
//        color: Colors.white,
//      )
    ];

    super.initState();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    double moveWidth = details.globalPosition.dx + this.initial;
    if (moveWidth != 0) {
      double nextLeft = _left1 + details.globalPosition.dx - this.initial;
      double boundaryLeft = nextLeft < minValue * baseWidth
          ? minValue * baseWidth
          : (nextLeft > width ? width : nextLeft);
      double nextValue = boundaryLeft / this.baseWidth / this.setup;
      if (this.value1 != nextValue.round().toDouble()) {
        Vibrate.feedback(FeedbackType.selection);
        widget.onChange(this.value1, nextValue.round());
      }
      setState(() {
        value1 = nextValue.round().toDouble();
        left1 = boundaryLeft;
      });
    }
  }

  void _onPanStart(DragStartDetails details) {
    this.initial = details.globalPosition.dx;
    this._left1 = this.left1;
    this.controller.forward();
    setState(() {
      pointScale = 1.2;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    this.initial = 0.0;
    this._left1 = 0.0;
    this.controller.reverse();
    double preValue = this.left1 / this.baseWidth / this.setup;
    int latestLeft = preValue.round();
    setState(() {
      pointScale = 1.0;
      left1 = latestLeft * this.baseWidth * this.setup;
    });
  }

  @override
  void dispose() {
    subEvent?.cancel();
    controller?.stop();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        ScaleTransition(
            scale: new Tween(begin: 1.0, end: 1.05).animate(curved),
            child: Container(
                margin: EdgeInsets.only(top: this.sliderHeight / 2),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      width: this.width,
                      height: this.sliderHeight,
                      color: const Color(0xffcfcfc0),
                    )))),
        Container(
          width: this.width,
          height: this.height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: splits,
          ),
        ),
        GestureDetector(
          onPanUpdate: this._onPanUpdate,
          onPanStart: this._onPanStart,
          onPanEnd: this._onPanEnd,
          child: Container(
            width: this.width,
            height: this.height,
            color: Colors.transparent,
          ),
        ),
        Positioned(
            left: left1 -
                pointWidth1 / 2 -
                value1.toStringAsFixed(fixed).length * 4.5 / 2,
            top: -(pointHeight1 - height) / 2 - 30,
            child: SlideTransition(
              position: new Tween(begin: Offset(0, 0), end: Offset(0, -0.3))
                  .animate(curved),
              child: ScaleTransition(
                scale: new Tween(begin: 1.0, end: 1.2).animate(curved),
                child: value1 == -1
                    ? Container()
                    : TextSize(
                        pointBorderRadius: pointBorderRadius1,
                        value: value1,
                        valueFixed: fixed),
              ),
            )),
        Positioned(
            left: left2 -
                pointWidth2 / 2 -
                value2.toStringAsFixed(fixed).length * 4.5 / 2,
            top: -(pointHeight2 - height) / 2 - 30,
            child: SlideTransition(
              position: new Tween(begin: Offset(0, 0), end: Offset(0, -0.3))
                  .animate(curved),
              child: ScaleTransition(
                scale: new Tween(begin: 1.0, end: 1.2).animate(curved),
                child: value2 == -1
                    ? Container()
                    : TextSize(
                        pointBorderRadius: pointBorderRadius2,
                        value: value2,
                        valueFixed: fixed),
              ),
            )),
        Positioned(
            height: this.pointHeight1,
            width: this.pointWidth1,
            left: left1 - (pointWidth1 / 2),
            child: GestureDetector(
              onPanUpdate: this._onPanUpdate,
              onPanStart: this._onPanStart,
              onPanEnd: this._onPanEnd,
              child: value1 == -1
                  ? Container()
                  : FadeTransition(
                      opacity: new Tween(begin: 1.0, end: 0.9).animate(curved),
                      child: ScaleTransition(
                        scale: new Tween(begin: 1.0, end: 1.2).animate(curved),
                        child: PhysicalModel(
                          shape: BoxShape.circle,
                          elevation: 4.0,
                          color: Colors.transparent,
                          shadowColor: Colors.green,
                          child: Container(
                            decoration: new BoxDecoration(
                                border: Border.all(
                                    color: pointBorderColor1,
                                    width: pointBorderWidth1),
                                color: pointColor1,
                                borderRadius:
                                    BorderRadius.circular(pointBorderRadius1)),
                          ),
                        ),
                      ),
                    ),
            )),
        Positioned(
          height: this.pointHeight2,
          width: this.pointWidth2,
          left: left2 - (pointWidth2 / 2),
          child: value2 == -1
              ? Container()
              : FadeTransition(
                  opacity: new Tween(begin: 1.0, end: 0.9).animate(curved),
                  child: ScaleTransition(
                    scale: new Tween(begin: 1.0, end: 1.2).animate(curved),
                    child: Container(
                      decoration: new BoxDecoration(
                          border: Border.all(
                              color: pointBorderColor2,
                              width: pointBorderWidth2),
                          color: pointColor2,
                          borderRadius:
                              BorderRadius.circular(pointBorderRadius2)),
                    ),
                  ),
                ),
        )
      ],
    );
  }
}
