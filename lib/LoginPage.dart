import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/store/LoginStore.dart';
import 'package:leek/store/SocketStore.dart';
import 'package:leek/store/UserStore.dart';
import 'package:leek/util/ScaffoldUtil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _scaleCurved;
  Animation<double> buttonSqueezeAnimation;
  String _phone = "";
  String _password = "";
  String _reqStatus = "";
  bool _passwordHidden = true;

  @override
  void initState() {
    readDbAccount();
    _controller = new AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);

    buttonSqueezeAnimation = Tween(
      begin: 340.0,
      end: 60.0,
    ).animate(
        CurvedAnimation(parent: _controller, curve: new Interval(0.0, 0.25)));

    _scaleCurved = Tween(
      begin: 1.0,
      end: 34.0,
    ).animate(CurvedAnimation(
        parent: _controller,
        curve: new Interval(0.5, 0.9, curve: Curves.easeInOut)));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration.zero, () {
          UserStore userStore = Provider.of<UserStore>(context);
          userStore.phone = _phone;
          userStore.init();
          Provider.of<SocketStore>(context).login();
        });
      }
    });
    super.initState();
  }

  void readDbAccount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String phone = sharedPreferences.getString("phone") ?? "";
    String password = sharedPreferences.getString("password") ?? "";
    setState(() {
      _phone = phone;
      _password = password;
    });
  }

  void writeDbAccount(String type, String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(type, value);
  }

  @override
  void dispose() {
    try {
      _controller?.stop();
    } catch (e) {}
    try {
      _controller?.dispose();
    } catch (e) {}
    super.dispose();
  }

  bool get isValid {
    return RegExp(
                r"^1([38][0-9]|4[579]|5[0-3,5-9]|6[6]|7[0135678]|9[89])\d{8}$")
            .hasMatch(_phone) &&
        _password.length >= 6;
  }

  void login() async {
    if (this.isValid) {
      try {
        FocusScope.of(context).requestFocus(FocusNode());
        _reqStatus = "request";
        Map<String, String> loginData = {
          "phone": _phone,
          "password": _password
        };
        print(loginData);
        Response response = await Config.dio.post("/user/login",
            data: loginData);
        Map<String, dynamic> data = response.data;
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        if (data["status"] == "ok") {
          HapticFeedback.lightImpact();
          String token = data["data"]["token"];
          await sharedPreferences.setString("token", token);
          Config.setDioHeaderToken(token);
          HapticFeedback.lightImpact();
          _controller.forward();
        } else {
          _controller.stop();
          _controller.reset();
          HapticFeedback.mediumImpact();
          await sharedPreferences.remove("token");
          ScaffoldUtil.show(_context, data);
        }
        _reqStatus = data["status"];
      } catch (e) {
        _reqStatus = "timeout";
        HapticFeedback.heavyImpact();
        ScaffoldUtil.show(_context, {"status": "timeout"});
      }
    }
  }

  BuildContext _context;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: new Builder(
          builder: (c) {
            _context = c;
            return SingleChildScrollView(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      height: ScreenUtil.instance.setHeight(540),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: <Widget>[
                          Positioned(
                            right: 0,
                            child: Image.asset("images/login-top.png"),
                          ),
                          Positioned(
                              bottom: ScreenUtil.instance.setHeight(20),
                              left: ScreenUtil.instance.setWidth(40),
                              child: Image.asset(
                                "images/leek.png",
                                width: ScreenUtil.instance.setWidth(120),
                              )),
                          Positioned(
                            left: ScreenUtil.instance.setWidth(180),
                            bottom: ScreenUtil.instance.setHeight(32),
                            child: Text(
                              "Leek",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54),
                            ),
                          ),
                          Positioned(
                            top: ScreenUtil.instance.setHeight(160),
                            right: ScreenUtil.instance.setWidth(80),
                            child: Image.asset(
                              "images/leek-white.png",
                              width: ScreenUtil.instance.setWidth(120),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil.instance.setHeight(60),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: ScreenUtil.instance.setWidth(50)),
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.greenAccent[100],
                              offset: Offset(10.0, 10.0),
                              blurRadius: ScreenUtil.instance.setWidth(80))
                        ],
                      ),
                      child: Container(
                        padding:
                            EdgeInsets.all(ScreenUtil.instance.setWidth(40)),
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil.instance.setHeight(20),
                            ),
                            Container(
                              child: TextField(
                                keyboardType: TextInputType.phone,
                                controller: TextEditingController.fromValue(
                                    TextEditingValue(
                                        text: _phone,
                                        selection: TextSelection.fromPosition(
                                            TextPosition(
                                                affinity:
                                                    TextAffinity.downstream,
                                                offset: _phone.length)))),
                                onChanged: (value) {
                                  setState(() {
                                    _phone = value;
                                  });
                                  writeDbAccount("phone", value);
                                },
                                decoration: InputDecoration(
                                    labelText: "Phone",
                                    suffixIcon: Icon(
                                      Icons.phone,
                                      color: Colors.blue[200],
                                    )),
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil.instance.setHeight(20),
                            ),
                            Container(
                                child: TextField(
                              obscureText: _passwordHidden,
                              keyboardType: TextInputType.visiblePassword,
                              controller: TextEditingController.fromValue(
                                  TextEditingValue(
                                      text: _password,
                                      selection: TextSelection.fromPosition(
                                          TextPosition(
                                              affinity: TextAffinity.downstream,
                                              offset: _password.length)))),
                              onChanged: (value) {
                                setState(() {
                                  _password = value;
                                });
                                writeDbAccount("password", value);
                              },
                              decoration: InputDecoration(
                                  labelText: "Password",
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _passwordHidden = _passwordHidden;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.visibility,
                                        color: Colors.blue[200],
                                      ))),
                            )),
                            SizedBox(
                              height: ScreenUtil.instance.setHeight(20),
                            ),
                            Container(
                              padding: EdgeInsets.all(
                                  ScreenUtil.instance.setWidth(20)),
                              alignment: Alignment.center,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "忘记密码?",
                                  style: TextStyle(color: Colors.blue[300]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil.instance.setHeight(50),
                    ),
                    ScaleTransition(
                        scale: _scaleCurved,
                        child: Container(
                          height: ScreenUtil.instance.setHeight(100),
                          child: AnimatedBuilder(
                            animation: buttonSqueezeAnimation,
                            builder: (context, _) {
                              if (buttonSqueezeAnimation.value == 60.0 &&
                                  (_reqStatus == "" || _reqStatus == "fail")) {
                                _controller.stop();
                                login();
                              }
                              return Container(
                                width: buttonSqueezeAnimation.value,
                                height: ScreenUtil.instance.setHeight(100),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      ScreenUtil.instance.setWidth(60)),
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white,
                                        Colors.blue,
                                      ]),
                                ),
                                child: RaisedButton(
                                  color: Colors.transparent,
                                  child: buttonSqueezeAnimation.value > 80
                                      ? Text(
                                          "登录",
                                          style: TextStyle(
                                              letterSpacing: 2.0,
                                              color: Colors.white),
                                        )
                                      : SizedBox(
                                          width:
                                              ScreenUtil.instance.setWidth(50),
                                          height:
                                              ScreenUtil.instance.setWidth(50),
                                          child: _scaleCurved.value < 2
                                              ? new CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      new AlwaysStoppedAnimation(
                                                          Colors.white))
                                              : null,
                                        ),
                                  textColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          ScreenUtil.instance.setWidth(60))),
                                  onPressed: isValid
                                      ? () {
                                          _controller.reset();
                                          _controller.forward();
                                        }
                                      : null,
                                ),
                              );
                            },
                          ),
                        )),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          minHeight: ScreenUtil.instance.setHeight(670)),
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        child: Image.asset("images/login-bottom.png"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }
}
