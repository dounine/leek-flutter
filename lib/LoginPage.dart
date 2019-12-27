import 'package:flutter/material.dart';
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
                height: 240,
                child: Stack(
                  alignment: Alignment.topRight,
                  children: <Widget>[
                    Positioned(
                      right: 0,
                      child: Image.asset("images/login-top.png"),
                    ),
                    Positioned(
                        bottom: 10,
                        left: 20,
                        child: Image.asset(
                          "images/leek.png",
                          width: 60,
                        )),
                    Positioned(
                      left: 90,
                      bottom: 16,
                      child: Text(
                        "Leek",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                    ),
                    Positioned(
                      top: 80,
                      right: 40,
                      child: Image.asset(
                        "images/leek-white.png",
                        width: 60,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                width: 340,
                decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.greenAccent[100],
                        offset: Offset(10.0, 10.0),
                        blurRadius: 40.0)
                  ],
                ),
                child: Container(
                  padding: EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Login",
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
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
                        height: 10,
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
                      Container(
                        padding: EdgeInsets.only(top: 20, bottom: 20),
                        alignment: Alignment.center,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "忘记密码?",
                            style: TextStyle(
                                color: Colors.blue[300],
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 24,
              ),
              ScaleTransition(
                  scale: _scaleCurved,
                  child: Container(
                    height: 46,
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
                          height: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
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
                                    style: TextStyle(letterSpacing: 2.0),
                                  )
                                : SizedBox(
                                    width: 24,
                                    height: 24,
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
                                borderRadius: BorderRadius.circular(30.0)),
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
              // SizedBox(
              //   height: 172,
              // ),
              Container(
                alignment: Alignment.bottomCenter,
                child: Image.asset("images/login-bottom.png"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
