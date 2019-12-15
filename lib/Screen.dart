import 'package:flutter/material.dart';

class Screen extends StatefulWidget {
  Screen({Key key}) : super(key: key);

  @override
  _ScreenState createState() {
    return _ScreenState();
  }
}

class _ScreenState extends State<Screen> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _doubleAnim;

  @override
  void initState() {
    super.initState();
    _animationController = new AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
    _doubleAnim = Tween(begin: 74.0, end: 80.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(top: 140),
                child: AnimatedBuilder(
                  animation: _doubleAnim,
                  builder: (context, _) {
                    return Column(
                      children: <Widget>[
                        Image.asset(
                          "images/leek.png",
                          width: _doubleAnim.value,
                        ),
                        Opacity(
                            opacity: 0.8,
                            child: Text(
                              "Leek",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.4,
                                  color: Colors.white),
                            ))
                      ],
                    );
                  },
                )),
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset("images/login-bottom.png"),
            )
          ],
        ),
      ),
    );
  }
}
