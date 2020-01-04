import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/store/LoginStore.dart';
import 'package:leek/store/UserStore.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  AnimationController _loginButtonController;
  Animation<double> _scaleCurved;
  Animation<double> buttonSqueezeAnimation;
  Animation<double> buttonZoomout;

  @override
  void initState() {
    _loginButtonController = new AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeAnimation = Tween(
      begin: 340.0,
      end: 60.0,
    ).animate(CurvedAnimation(
        parent: _loginButtonController, curve: new Interval(0.0, 0.25)));

    _scaleCurved = Tween(
      begin: 1.0,
      end: 34.0,
    ).animate(CurvedAnimation(
        parent: _loginButtonController,
        curve: new Interval(0.4, 1.0, curve: Curves.easeInOut)));
    super.initState();
  }

  @override
  void dispose() {
    _loginButtonController.stop();
    _loginButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    final LoginStore loginStore = Provider.of<LoginStore>(context);
    final UserStore userStore = Provider.of<UserStore>(context);
    loginStore.nextAnimation((String status, String msg) {
      if (status == "ok") {
        loginStore.status = "ok";
        _loginButtonController.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            print("已经完成");
            userStore.phone = loginStore.phone;
            userStore.init();
            _loginButtonController.reset();
            loginStore.status = "";
          }
        });
        _loginButtonController.forward();
        FocusScope.of(context).requestFocus(FocusNode());
      } else {
        _loginButtonController.reset();
        loginStore.status = "";
        showDialog<void>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text('登录提示'),
              content: Text(msg),
              actions: <Widget>[
                FlatButton(
                  child: Text('确认'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Dismiss alert dialog
                  },
                ),
              ],
            );
          },
        );
      }
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
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
                  padding: EdgeInsets.all(ScreenUtil.instance.setWidth(40)),
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
                        child: Consumer<LoginStore>(
                          builder: (_, login, child) {
                            return TextField(
                              keyboardType: TextInputType.phone,
                              controller: TextEditingController.fromValue(
                                  TextEditingValue(
                                      text: login.phone,
                                      selection: TextSelection.fromPosition(
                                          TextPosition(
                                              affinity: TextAffinity.downstream,
                                              offset: login.phone.length)))),
                              onChanged: (value) {
                                login.change("phone", value);
                              },
                              decoration: InputDecoration(
                                  labelText: "Phone",
                                  suffixIcon: Icon(
                                    Icons.phone,
                                    color: Colors.blue[200],
                                  )),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil.instance.setHeight(20),
                      ),
                      Container(child: Consumer<LoginStore>(
                        builder: (_, login, child) {
                          return TextField(
                            obscureText: login.passwordHidden,
                            keyboardType: TextInputType.visiblePassword,
                            controller: TextEditingController.fromValue(
                                TextEditingValue(
                                    text: login.password,
                                    selection: TextSelection.fromPosition(
                                        TextPosition(
                                            affinity: TextAffinity.downstream,
                                            offset: login.password.length)))),
                            onChanged: (value) {
                              login.change("password", value);
                            },
                            decoration: InputDecoration(
                                labelText: "Password",
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      login.passwordHidden =
                                          !login.passwordHidden;
                                    },
                                    icon: Icon(
                                      Icons.visibility,
                                      color: Colors.blue[200],
                                    ))),
                          );
                        },
                      )),
                      SizedBox(
                        height: ScreenUtil.instance.setHeight(20),
                      ),
                      Container(
                        padding:
                            EdgeInsets.all(ScreenUtil.instance.setWidth(20)),
                        alignment: Alignment.center,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "忘记密码?",
                            style: TextStyle(
                                color: Colors.blue[300]),
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
                            loginStore.status == "") {
                          _loginButtonController.stop();
                          loginStore.login();
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
                                    style: TextStyle(letterSpacing: 2.0,color: Colors.white),
                                  )
                                : SizedBox(
                                    width: ScreenUtil.instance.setWidth(50),
                                    height: ScreenUtil.instance.setWidth(50),
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
                            onPressed: loginStore.isValid
                                ? () {
                                    _loginButtonController.forward();
                                  }
                                : null,
                          ),
                        );
                      },
                    ),
                  )),
              ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: ScreenUtil.instance.setHeight(540)),
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset("images/login-bottom.png"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
