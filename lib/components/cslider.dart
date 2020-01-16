import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';

class CustomliderWidget extends StatefulWidget {
  final double width;
  final Function onChange;
  final num defaultValue;
  final num minValue;
  final num maxValue;
  final num setup;
  final num fixed;
  final String eventName;
  final bool animation;
  final int splits;

  const CustomliderWidget(
      {Key key,
      @required this.width,
      @required this.minValue,
      @required this.maxValue,
      @required this.defaultValue,
      @required this.setup,
      @required this.fixed,
      @required this.onChange,
      @required this.splits,
      this.eventName,
      this.animation})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomliderState();
}

class TextSize extends StatelessWidget {
  final double pointBorderRadius;
  final double value;
  final int valueFixed;

  TextSize(
      {Key key,
      @required this.pointBorderRadius,
      @required this.value,
      @required this.valueFixed})
      : super(key: key);

  BuildContext context;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    return Container(
      decoration: new BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(
              ScreenUtil.instance.setWidth(pointBorderRadius))),
      padding: EdgeInsets.symmetric(
          vertical: ScreenUtil.instance.setWidth(10),
          horizontal: ScreenUtil.instance.setWidth(16)),
      child: Text(
        (value).toStringAsFixed(valueFixed),
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class _CustomliderState extends State<CustomliderWidget>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  CurvedAnimation curved;
  bool animation = false;
  bool enableTouch = true; //是否允许触摸
  double value = 0.0; //默认值
  double incrmentValue = 0.0;
  int fixed = 0;
  double minValue = 0.0; //最小值
  double maxValue = 0.0; //最大值
  double setup = 0.0; //步进值

  double width = 0;
  double height = 50;
  double sliderHeight = 50;
  double left = 0.0;
  double _left = 0.0;
  double initial = 0.0;

  double pointWidth = 80;
  double pointHeight = 80;
  double pointBorderWidth = 16;
  double pointBorderRadius = 60;
  Color pointBorderColor = Colors.green;
  Color pointColor = Colors.white;
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
    width = widget.width;
    animation = widget.animation;
    setup = widget.setup.toDouble();
    minValue = widget.minValue.toDouble();
    maxValue = widget.maxValue.toDouble();
    value = widget.defaultValue.toDouble();

    //基数、每个值占多少宽度
    baseWidth = width / maxValue;

    left = baseWidth * value;
    if (widget.eventName != null) {
      subEvent = Config.eventBus.on<PushEvent>().listen((event) {
        if (event.name == widget.eventName) {
          setState(() {
            value = event.value * 1.0;
            left = baseWidth * value;
          });
        }
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

  void _onPanStart(DragStartDetails details) {
    this.initial = details.globalPosition.dx;
    this._left = this.left;
    if (animation) {
      this.controller.forward();
    }
    setState(() {
      pointScale = 1.2;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    double moveWidth = details.globalPosition.dx + this.initial;
    if (moveWidth != 0) {
      double nextLeft = _left + details.globalPosition.dx - this.initial;
      double boundaryLeft = nextLeft < (minValue * baseWidth)
          ? minValue * baseWidth
          : (nextLeft > width ? width : nextLeft);
      double nextValue = boundaryLeft / this.baseWidth / this.setup;
      if (this.value != nextValue.round().toDouble()) {
        HapticFeedback.lightImpact();
        widget.onChange(this.value, double.parse(nextValue.toStringAsFixed(fixed)));
      }
      setState(() {
        value = nextValue.round().toDouble();
        left = boundaryLeft;
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    this.initial = 0.0;
    this._left = 0.0;
    if (animation) {
      this.controller.reverse();
    }
    double preValue = this.left / this.baseWidth / this.setup;
    int latestLeft = preValue.round();
    setState(() {
      pointScale = 1.0;
      left = latestLeft * this.baseWidth * this.setup;
    });
  }

  @override
  void dispose() {
    subEvent?.cancel();
    controller?.stop();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        ScaleTransition(
            scale: new Tween(begin: 1.0, end: 1.05).animate(curved),
            child: Container(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        ScreenUtil.instance.setWidth(this.height / 2)),
                    child: Container(
                      width: this.width,
                      height: ScreenUtil.instance.setWidth(this.sliderHeight),
                      color: const Color(0xffcfcfc0),
                    )))),
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
        Positioned(
            left: left -
                ScreenUtil.instance.setWidth(pointWidth) / 2 -
                (value + incrmentValue).toStringAsFixed(fixed).length *
                    4.5 /
                    2 +
                5,
            top: ScreenUtil.instance
                .setWidth(-(pointHeight - height) / 2 - pointHeight),
            child: SlideTransition(
              position: new Tween(begin: Offset(0, 0), end: Offset(0, -0.3))
                  .animate(curved),
              child: ScaleTransition(
                scale: new Tween(begin: 1.0, end: 1.2).animate(curved),
                child: TextSize(
                    pointBorderRadius:
                        ScreenUtil.instance.setWidth(pointBorderRadius),
                    value: value + incrmentValue,
                    valueFixed: fixed),
              ),
            )),
        Positioned(
            height: ScreenUtil.instance.setWidth(this.pointHeight),
            width: ScreenUtil.instance.setWidth(this.pointWidth),
            left: left - (ScreenUtil.instance.setWidth(pointWidth) / 2),
            top: ScreenUtil.instance.setWidth(-(pointHeight - height) / 2),
            child: GestureDetector(
              onPanUpdate: this._onPanUpdate,
              onPanStart: this._onPanStart,
              onPanEnd: this._onPanEnd,
              child: FadeTransition(
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
                              color: pointBorderColor,
                              width: ScreenUtil.instance
                                  .setWidth(pointBorderWidth)),
                          color: pointColor,
                          borderRadius: BorderRadius.circular(
                              ScreenUtil.instance.setWidth(pointBorderRadius))),
                    ),
                  ),
                ),
              ),
            ))
      ],
    );
  }
}
