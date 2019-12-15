import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibrate/vibrate.dart';

class CustomliderWidget extends StatefulWidget {
  final Function onChange;
  final num defaultValue;
  final num minValue;
  final num maxValue;
  final num setup;
  final num fixed;

  const CustomliderWidget(
      {Key key,
      @required this.minValue,
      @required this.maxValue,
      @required this.defaultValue,
      @required this.setup,
      @required this.fixed,
      @required this.onChange
      })
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
          borderRadius: BorderRadius.circular(pointBorderRadius)),
      padding: EdgeInsets.symmetric(
          vertical: ScreenUtil.instance.setWidth(10.0),
          horizontal: ScreenUtil.instance.setWidth(16.0)),
      child: Text(
        (value).toStringAsFixed(valueFixed),
        style: TextStyle(
            fontSize: ScreenUtil.instance.setSp(36), color: Colors.white),
      ),
    );
  }
}

class _CustomliderState extends State<CustomliderWidget>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  CurvedAnimation curved;
  bool enableTouch = true; //是否允许触摸
  double value = 0.0; //默认值
  double incrmentValue = 0.0;
  int fixed = 0;
  double minValue = 0.0; //最小值
  double maxValue = 0.0; //最大值
  double setup = 0.0; //步进值

  double width = 840;
  double height = 60;
  double sliderHeight = 30;
  double left = 0.0;
  double _left = 0.0;
  double initial = 0.0;

  double pointWidth = 80;
  double pointHeight = 80;
  double pointBorderWidth = 6;
  double pointBorderRadius = 30;
  Color pointBorderColor = Colors.green;
  Color pointColor = Colors.white;
  double pointScale = 1.0;
  double baseWidth = 0.0;

  List<Widget> splits;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this); //动画控制器
    curved = new CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    fixed = widget.fixed;
    setup = widget.setup.toDouble();
    minValue = widget.minValue.toDouble();
    maxValue = widget.maxValue.toDouble();
    value = widget.defaultValue.toDouble();

    //基数、每个值占多少宽度
    baseWidth = width / maxValue;

    left = baseWidth * value + left;

    //分隔线
    splits = [
//      Container(
//        width: 2.0,
//        color: Colors.white,
//      )
    ];
  }

  void _onPanUpdate(DragUpdateDetails details) {
    double moveWidth = details.globalPosition.dx - this.initial;
    if (moveWidth != 0) {
      double nextLeft = _left + details.globalPosition.dx - this.initial;
      double boundaryLeft =
          nextLeft < minValue * ScreenUtil.instance.setWidth(baseWidth)
              ? minValue * ScreenUtil.instance.setWidth(baseWidth)
              : (nextLeft > ScreenUtil.instance.setWidth(width)
                  ? ScreenUtil.instance.setWidth(width)
                  : nextLeft);
      double nextValue = boundaryLeft /
          ScreenUtil.instance.setWidth(this.baseWidth) /
          this.setup;
      if (this.value != nextValue.round().toDouble()) {
        Vibrate.feedback(FeedbackType.selection);
      }
      widget.onChange(this.value, nextValue.round().toDouble());
      setState(() {
        value = nextValue.round().toDouble();
        left = boundaryLeft;
      });
    }
  }

  void _onPanStart(DragStartDetails details) {
    this.initial = details.globalPosition.dx;
    this._left = this.left;
    this.controller.forward();
    setState(() {
      pointScale = 1.2;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    this.initial = 0.0;
    this._left = 0.0;
    this.controller.reverse();
    double preValue =
        this.left / ScreenUtil.instance.setWidth(this.baseWidth) / this.setup;
    int latestLeft = preValue.round();
    setState(() {
      pointScale = 1.0;
      left = latestLeft *
          ScreenUtil.instance.setWidth(this.baseWidth) *
          this.setup;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    final textBox = TextSize(
        pointBorderRadius: pointBorderRadius,
        value: value + incrmentValue,
        valueFixed: fixed);
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        ScaleTransition(
            scale: new Tween(begin: 1.0, end: 1.05).animate(curved),
            child: Container(
                margin: EdgeInsets.only(
                    top: ScreenUtil.instance.setHeight(this.sliderHeight / 2)),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      width: ScreenUtil.instance.setWidth(this.width),
                      height: ScreenUtil.instance.setHeight(this.sliderHeight),
                      color: const Color(0xffcfcfc0),
                    )))),
        Container(
          width: ScreenUtil.instance.setWidth(this.width),
          height: ScreenUtil.instance.setHeight(this.height),
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
            width: ScreenUtil.instance.setWidth(this.width),
            height: ScreenUtil.instance.setHeight(this.height),
            color: Colors.transparent,
          ),
        ),
//        AnimatedPositioned(

        Positioned(
            left: left -
                ScreenUtil.instance.setWidth(pointWidth) / 2 -
                (value + incrmentValue).toStringAsFixed(fixed).length *
                    4.5 /
                    2,
            top: -(ScreenUtil.instance.setWidth(pointHeight) -
                        ScreenUtil.instance.setHeight(height)) /
                    2 -
                30,
            child: SlideTransition(
              position: new Tween(begin: Offset(0, 0), end: Offset(0, -0.3))
                  .animate(curved),
              child: ScaleTransition(
                scale: new Tween(begin: 1.0, end: 1.2).animate(curved),
                child: textBox,
              ),
            )),
        Positioned(
            height: ScreenUtil.instance.setWidth(this.pointHeight),
            width: ScreenUtil.instance.setWidth(this.pointWidth),
            left: left - ScreenUtil.instance.setWidth(pointWidth) / 2,
            top: -(ScreenUtil.instance.setWidth(pointHeight) -
                    ScreenUtil.instance.setHeight(height)) /
                2,
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
//                  height: this.pointHeight,
//                  width: this.pointWidth,
                      decoration: new BoxDecoration(
                          border: Border.all(
                              color: pointBorderColor, width: pointBorderWidth),
                          color: pointColor,
                          borderRadius:
                              BorderRadius.circular(pointBorderRadius)),
                    ),
                  ),
                ),
              ),
            ))
      ],
    );
  }
}
