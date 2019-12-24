import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/profile/manager/User.dart';
import 'package:leek/store/UserStore.dart';
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
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    UserOperation userOperation = ModalRoute.of(context).settings.arguments;
    return new Scaffold(
        appBar: AppBar(
          title: Text(userOperation.title),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.save), onPressed: () {})
          ],
        ),
        body: Container(
            child: Column(children: <Widget>[
          Container(
              padding: EdgeInsets.all(10),
              child: Row(children: <Widget>[
                Expanded(
                    child: TextField(
                        keyboardType: TextInputType.phone,
                        controller: TextEditingController.fromValue(
                            TextEditingValue(
                                text: userOperation.userInfo.phone ?? "",
                                selection: TextSelection.fromPosition(
                                    TextPosition(
                                        affinity: TextAffinity.downstream,
                                        offset:
                                            (userOperation.userInfo.phone ?? "")
                                                .length)))),
                        decoration: InputDecoration(
                            labelText: "手机号",
                            suffixIcon: Icon(
                              Icons.phone,
                              color: Colors.blue[200],
                            ))))
              ])),
          Container(
              padding: EdgeInsets.all(10),
              child: Row(children: <Widget>[
                Expanded(
                    child: TextField(
                        obscureText: passwordHidden,
                        keyboardType: TextInputType.visiblePassword,
                        controller: TextEditingController.fromValue(
                            TextEditingValue(
                                text: userOperation.userInfo.password ?? "",
                                selection: TextSelection.fromPosition(
                                    TextPosition(
                                        affinity: TextAffinity.downstream,
                                        offset:
                                            (userOperation.userInfo.password ??
                                                    "")
                                                .length)))),
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
        ])));
  }
}
