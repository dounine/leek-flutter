import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/profile/manager/User.dart';
import 'package:leek/store/UserStore.dart';
import 'package:leek/util/ScaffoldUtil.dart';
import 'package:provider/provider.dart';

class UserEdit extends StatefulWidget {
  final String title;
  const UserEdit({this.title, Key key}) : super(key: key);

  @override
  _UserEditState createState() {
    return _UserEditState();
  }
}

class _UserEditState extends State<UserEdit> {
  bool passwordHidden = true;
  String _status = "normal";
  String _phone = "";
  String _password = "";
  String _reqStatus = "";

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      UserOperation userOperation = ModalRoute.of(context).settings.arguments;
      setState(() {
        _status = userOperation.userInfo.status;
        _phone = userOperation.userInfo.phone;
        _password = userOperation.userInfo.password;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void add() async {
    try {
      setState(() {
        _reqStatus = "request";
      });
      Response response = await Config.dio.post("/user/admin/info",
          data: {"phone": _phone, "password": _password});
      Map<String, dynamic> data = response.data;
      setState(() {
        _reqStatus = data["status"];
      });
      ScaffoldUtil.show(_context, data,
          msg: "添加${data['status'] == 'ok' ? '成功' : '失败'}");
    } catch (e) {
      setState(() {
        _reqStatus = "timeout";
      });
      ScaffoldUtil.show(_context, {"status": "timeout"});
    }
  }

  void edit() async {
    try {
      setState(() {
        _reqStatus = "request";
      });
      Response response = await Config.dio
          .patch("/user/admin/info/${_phone}", data: {"password": _password});
      Map<String, dynamic> data = response.data;
      setState(() {
        _reqStatus = data["status"];
      });
      ScaffoldUtil.show(_context, data,
          msg: "修改${data['status'] == 'ok' ? '成功' : '失败'}");
    } catch (e) {
      setState(() {
        _reqStatus = "timeout";
      });
      ScaffoldUtil.show(_context, {"status": "timeout"});
    }
  }

  void update() async {
    try {
      setState(() {
        _reqStatus = "request";
      });
      Response response = await Config.dio.patch(
          "/user/admin/${_status == 'normal' ? 'lock' : 'unlock'}/${_phone}");
      Map<String, dynamic> data = response.data;
      ScaffoldUtil.show(_context, data,
          msg: "${_status == 'normal' ? '锁定' : '解琐'}" +
              (data["status"] == "ok" ? "成功" : "失败"));
      if (data["status"] == "ok") {
        if (_status == "normal") {
          setState(() {
            _reqStatus = data["status"];
            _status = 'locked';
          });
        } else {
          setState(() {
            _reqStatus = data["status"];
            _status = 'normal';
          });
        }
      } else {
        ScaffoldUtil.show(_context, data);
      }
    } catch (e) {
      setState(() {
        _reqStatus = "timeout";
      });
      ScaffoldUtil.show(_context, {"status": "timeout"});
    }
  }

  BuildContext _context;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    UserOperation userOperation = ModalRoute.of(context).settings.arguments;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(
            context,
            UserInfo(
                _phone,
                _status,
                _password,
                userOperation.userInfo.isAdmin,
                userOperation.userInfo.createTime,
                userOperation.userInfo.add));
        return false;
      },
      child: new Scaffold(
          appBar: AppBar(
            title: Text(userOperation.title),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.save),
                  onPressed: _phone.length == 11 && _password.length >= 6
                      ? () {
                          if (userOperation.userInfo.add) {
                            add();
                          } else {
                            edit();
                          }
                        }
                      : null)
            ],
          ),
          body: new Builder(builder: (context) {
            _context = context;
            return Container(
                margin: EdgeInsets.all(10),
                child: Column(children: <Widget>[
                  Container(
                      child: Row(children: <Widget>[
                    Expanded(
                        child: TextField(
                            keyboardType: TextInputType.phone,
                            readOnly: !userOperation.userInfo.add,
                            onChanged: (value) {
                              setState(() {
                                _phone = value;
                              });
                            },
                            controller: TextEditingController.fromValue(
                                TextEditingValue(
                                    text: _phone,
                                    selection: TextSelection.fromPosition(
                                        TextPosition(
                                            affinity: TextAffinity.downstream,
                                            offset: _phone.length)))),
                            decoration: InputDecoration(
                                labelText: "手机号",
                                suffixIcon: Icon(
                                  Icons.phone,
                                  color: Colors.blue[200],
                                ))))
                  ])),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      child: Row(children: <Widget>[
                    Expanded(
                        child: TextField(
                            obscureText: passwordHidden,
                            keyboardType: TextInputType.visiblePassword,
                            onChanged: (value) {
                              setState(() {
                                _password = value;
                              });
                            },
                            controller: TextEditingController.fromValue(
                                TextEditingValue(
                                    text: _password,
                                    selection: TextSelection.fromPosition(
                                        TextPosition(
                                            affinity: TextAffinity.downstream,
                                            offset: _password.length)))),
                            decoration: InputDecoration(
                                labelText: "密码",
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      this.setState(() {
                                        passwordHidden = !passwordHidden;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.visibility,
                                      color: Colors.blue[200],
                                    )))))
                  ])),
                  SizedBox(
                    height: 20,
                  ),
                  userOperation.userInfo.add
                      ? (_reqStatus == "request"
                          ? CircularProgressIndicator()
                          : Container())
                      : (_reqStatus == "request"
                          ? CircularProgressIndicator()
                          : FractionallySizedBox(
                              widthFactor: 1,
                              child: MaterialButton(
                                  color: Colors.blue,
                                  textColor: Colors.white,
                                  child:
                                      Text(_status == "normal" ? "锁定" : "解琐"),
                                  onPressed: () {
                                    update();
                                  })))
                ]));
          })),
    );
  }
}
