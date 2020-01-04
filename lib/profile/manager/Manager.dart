import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Manager extends StatelessWidget {
  const Manager({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    return new Scaffold(
        appBar: new AppBar(
          title: Text("管理"),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: ScreenUtil.instance.setHeight(20),
              ),
              Container(
                color: Colors.white,
                child: new ListTile(
                    title: const Text("用户管理"),
                    onTap: () {
                      Navigator.pushNamed(context, "/user");
                    },
                    trailing: Icon(Icons.keyboard_arrow_right)),
              ),
              SizedBox(
                height: ScreenUtil.instance.setHeight(40),
              ),
              Container(
                color: Colors.white,
                child: new ListTile(
                    title: const Text("合约管理"),
                    onTap: () {
                      Navigator.pushNamed(context, "/contract-manager");
                    },
                    trailing: Icon(Icons.keyboard_arrow_right)),
              ),
              new Divider(height: 1, indent: 10),
              Container(
                color: Colors.white,
                child: new ListTile(
                    title: const Text("用户合约"),
                    onTap: () {
                      Navigator.pushNamed(context, "/open-manager");
                    },
                    trailing: Icon(Icons.keyboard_arrow_right)),
              ),
              new Divider(height: 1, indent: 10),
              Container(
                color: Colors.white,
                child: new ListTile(
                    title: const Text("合约申请"),
                    onTap: () {
                      Navigator.pushNamed(context, "/open-request");
                    },
                    trailing: Icon(Icons.keyboard_arrow_right)),
              ),
              SizedBox(
                height: ScreenUtil.instance.setHeight(40),
              ),
              Container(
                color: Colors.white,
                child: new ListTile(
                    title: const Text("程序健康状态"),
                    onTap: () {
                      Navigator.pushNamed(context, "/api");
                    },
                    trailing: Icon(Icons.keyboard_arrow_right)),
              ),
            ],
          ),
        ));
  }
}
