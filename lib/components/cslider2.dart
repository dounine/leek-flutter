import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/components/cslider.dart';

class CustomliderWidget2 extends StatefulWidget {
  final double width;
  final Function onChange;
  final num defaultValue1;
  final num defaultValue2;
  final num minValue;
  final num maxValue;
  final num setup;
  final num fixed;
  final String eventName;
  final int splits;

  const CustomliderWidget2(
      {Key key,
      @required this.width,
      @required this.minValue,
      @required this.maxValue,
      @required this.defaultValue1,
      @required this.defaultValue2,
      @required this.setup,
      @required this.fixed,
      @required this.onChange,
      @required this.splits,
      this.eventName})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomliderState2();
}

class _CustomliderState2 extends State<CustomliderWidget2> {
  bool enableTouch = true; //是否允许触摸
  double value1 = -1; //默认值1
  double value2 = -1; //默认值2
  int fixed = 0;
  double minValue = 0.0; //最小值
  double maxValue = 0.0; //最大值
  double setup = 0.0; //步进值

  double width = 0;
  double height = 50;
  double sliderHeight = 50;
  double left1 = 0.0;
  double _left1 = 0.0;
  double left2 = 0.0;
  double _left2 = 0.0;
  double initial = 0.0;

  double pointWidth1 = 30;
  double pointHeight1 = 80;
  double pointBorderWidth1 = 8;
  double pointBorderRadius1 = 60;

  double pointWidth2 = 30;
  double pointHeight2 = 80;
  double pointBorderWidth2 = 8;
  double pointBorderRadius2 = 60;

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
    fixed = widget.fixed;
    width = widget.width;
    setup = widget.setup.toDouble();
    minValue = widget.minValue.toDouble();
    maxValue = widget.maxValue.toDouble();
    value1 = widget.defaultValue1.toDouble();
    value2 = widget.defaultValue2.toDouble();

    //基数、每个值占多少宽度
    baseWidth = width / maxValue;

    if (value1 != -1) {
      left1 = baseWidth * value1;
    }
    if (value2 != -1) {
      left2 = baseWidth * value2;
    }
    if (widget.eventName != null) {
      subEvent = Config.eventBus.on<PushEvent>().listen((event) {
        var i = 1;
        widget.eventName.split(",").forEach((eventName) {
          if (event.name == eventName) {
            if (i == 1) {
              setState(() {
                value1 = event.value * 1.0;
                left1 = baseWidth * value1;
              });
            } else {
              setState(() {
                value2 = event.value * 1.0;
                left2 = baseWidth * value2;
              });
            }
          }
          i = i + 1;
        });
      });
    }

    //分隔线
    splits = [for (var i = 0; i < 3; i += 1) i].map((i) {
      return Container(
        width: 1,
        color: Colors.white54,
      );
    }).toList();

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
        HapticFeedback.selectionClick();
        widget.onChange(this.value1, double.parse(nextValue.toStringAsFixed(fixed)));
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
    setState(() {
      pointScale = 1.2;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    this.initial = 0.0;
    this._left1 = 0.0;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        Container(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    ScreenUtil.instance.setWidth(this.height / 2)),
                child: Container(
                  width: this.width,
                  height: ScreenUtil.instance.setWidth(this.sliderHeight),
                  color: const Color(0xffcfcfc0),
                ))),
        Container(
          width: this.width,
          height: ScreenUtil.instance.setWidth(this.height),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: splits,
          ),
        ),
        GestureDetector(
          onPanUpdate: this._onPanUpdate,
          onPanStart: this._onPanStart,
          onPanEnd: this._onPanEnd,
          child: Container(
            width: this.width,
            height: ScreenUtil.instance.setWidth(this.height),
            color: Colors.transparent,
          ),
        ),
        value1 != -1
            ? Positioned(
                left: left1 -
                    ScreenUtil.instance.setWidth(pointWidth1) / 2 -
                    value1.toStringAsFixed(fixed).length *
                        ScreenUtil.instance.setWidth(20) /
                        2,
                top: ScreenUtil.instance
                    .setWidth(-(pointHeight1 - height) / 2 - pointHeight1),
                child: TextSize(
                    pointBorderRadius: pointBorderRadius1,
                    value: value1,
                    valueFixed: fixed),
              )
            : Container(),
        value2 != -1
            ? Positioned(
                left: left2 -
                    ScreenUtil.instance.setWidth(pointWidth2) / 2 -
                    value2.toStringAsFixed(fixed).length *
                        ScreenUtil.instance.setWidth(20) /
                        2,
                top: ScreenUtil.instance
                    .setWidth(-(pointHeight2 - height) / 2 - pointHeight2),
                child: TextSize(
                    pointBorderRadius: pointBorderRadius2,
                    value: value2,
                    valueFixed: fixed),
              )
            : Container(),
        value1 != -1
            ? Positioned(
                height: ScreenUtil.instance.setWidth(this.pointHeight1),
                width: ScreenUtil.instance.setWidth(this.pointWidth1),
                left: left1 - (ScreenUtil.instance.setWidth(pointWidth1) / 2),
                top: ScreenUtil.instance.setWidth(-(pointHeight1 - height) / 2),
                child: GestureDetector(
                  onPanUpdate: this._onPanUpdate,
                  onPanStart: this._onPanStart,
                  onPanEnd: this._onPanEnd,
                  child: Container(
                    decoration: new BoxDecoration(
                        border: Border.all(
                            color: pointBorderColor1,
                            width: ScreenUtil.instance
                                .setWidth(pointBorderWidth1)),
                        color: pointColor1,
                        borderRadius: BorderRadius.circular(
                            ScreenUtil.instance.setWidth(pointBorderRadius1))),
                  ),
                ),
              )
            : Container(),
        value2 != -1
            ? Positioned(
                height: ScreenUtil.instance.setWidth(this.pointHeight2),
                width: ScreenUtil.instance.setWidth(this.pointWidth2),
                left: left2 - (ScreenUtil.instance.setWidth(pointWidth2) / 2),
                top: ScreenUtil.instance.setWidth(-(pointHeight2 - height) / 2),
                child: Container(
                  decoration: new BoxDecoration(
                      border: Border.all(
                          color: pointBorderColor2,
                          width:
                              ScreenUtil.instance.setWidth(pointBorderWidth2)),
                      color: pointColor2,
                      borderRadius: BorderRadius.circular(
                          ScreenUtil.instance.setWidth(pointBorderRadius2))),
                ),
              )
            : Container()
      ],
    );
  }
}
