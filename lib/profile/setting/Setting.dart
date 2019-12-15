import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/store/UserStore.dart';
import 'package:provider/provider.dart';

class Setting extends StatelessWidget {
  const Setting({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    return new Scaffold(
        appBar: new AppBar(
          title: Text("设置"),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.white,
                child: new ListTile(
                    title: const Text("帐号与安全"),
                    onTap: () {
                      Navigator.pushNamed(context, "/session");
                    },
                    trailing: Icon(Icons.keyboard_arrow_right)),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                color: Colors.white,
                child: new ListTile(
                    title: const Text("消息通知"),
                    onTap: () {
                      Navigator.pushNamed(context, "/session");
                    },
                    trailing: Icon(Icons.keyboard_arrow_right)),
              ),
              SizedBox(
                height: 1,
                child: Container(
                  margin: EdgeInsets.only(left: 16),
                  color: Colors.grey[200],
                ),
              ),
              Container(
                color: Colors.white,
                child: new ListTile(
                    title: const Text("通用"),
                    onTap: () {
                      Navigator.pushNamed(context, "/api");
                    },
                    trailing: Icon(Icons.keyboard_arrow_right)),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                color: Colors.white,
                child: new ListTile(
                    title: const Text("帮助与反馈"),
                    onTap: () {
                      Navigator.pushNamed(context, "/api");
                    },
                    trailing: Icon(Icons.keyboard_arrow_right)),
              ),
              SizedBox(
                height: 1,
                child: Container(
                  margin: EdgeInsets.only(left: 16),
                  color: Colors.grey[200],
                ),
              ),
              Container(
                color: Colors.white,
                child: new ListTile(
                    title: const Text("关于Leek"),
                    onTap: () {
                      Navigator.pushNamed(context, "/api");
                    },
                    trailing: Container(
                        width: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              "版本1.0.0",
                              style: TextStyle(color: Colors.grey),
                            ),
                            Icon(Icons.keyboard_arrow_right),
                          ],
                        ))),
              ),
              SizedBox(
                height: 20,
              ),
              FractionallySizedBox(
                widthFactor: 0.96,
                child: Container(
                    color: Colors.white,
                    child: SizedBox(
                      width: double.infinity,
                      height: ScreenUtil.instance.setHeight(90),
                      child: RaisedButton(
                          child: Text("退出登录"),
                          onPressed: () {
                            Provider.of<UserStore>(context).logout();
                            Navigator.pop(context);
                          }),
                    )),
              ),
            ],
          ),
        ));
  }
}
