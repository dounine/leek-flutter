import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/store/UserStore.dart';
import 'package:provider/provider.dart';

class User extends StatefulWidget {
  const User({Key key}) : super(key: key);

  @override
  _UserState createState() {
    return _UserState();
  }
}

class UserInfo {
  final String phone;
  final String status;
  final String password;
  final String createTime;
  final bool isAdmin;
  UserInfo(
      this.phone, this.status, this.password, this.isAdmin, this.createTime);
}

class UserOperation {
  final String title;
  final UserInfo userInfo;
  UserOperation(this.title, this.userInfo);
}

class _UserState extends State<User> {
  List<UserInfo> _listInfos;
  @override
  void initState() {
    query();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void query() async {
    Response response = await Config.dio.get("/user/admin/list");
    Map<String, dynamic> data = response.data;
    if (data["status"] == "ok") {
      List<dynamic> ll = data["data"];
      List<UserInfo> list = ll.map((item) {
        return UserInfo(item["phone"], item["status"], item["password"],
            item["admin"], item["createTime"]);
      }).toList();
      setState(() {
        _listInfos = list;
      });
    }
  }

  Future<Null> _refresh() async {
    query();
    return;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    return new Scaffold(
        appBar: AppBar(
          title: Text("用户管理"),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.person_add),
                onPressed: () {
                  Navigator.pushNamed(context, '/user-edit',
                      arguments: UserOperation('添加', null));
                })
          ],
        ),
        body: RefreshIndicator(
            onRefresh: _refresh,
            child: _listInfos == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    child: new ListView.separated(
                        padding: EdgeInsets.all(5),
                        itemCount: _listInfos.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return new Container(
                              height: 1, color: Colors.grey[300]);
                        },
                        itemBuilder: (BuildContext context, int index) {
                          UserInfo userInfo = _listInfos[index];
                          return Container(
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                Container(
                                    margin: EdgeInsets.all(10),
                                    height: 50,
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(children: <Widget>[
                                            Text(userInfo.phone,
                                                style: TextStyle(
                                                    color: userInfo.status ==
                                                            "normal"
                                                        ? Colors.black
                                                        : Colors.grey,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            userInfo.isAdmin
                                                ? Icon(Icons.assignment_ind,
                                                    color: Colors.redAccent)
                                                : Container()
                                          ]),
                                          Text(userInfo.createTime,
                                              style:
                                                  TextStyle(color: Colors.grey))
                                        ])),
                                Container(
                                    child: Row(children: <Widget>[
                                  IconButton(
                                      color: Colors.blueGrey,
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/user-edit',
                                            arguments: UserOperation(
                                                '修改信息', userInfo));
                                      })
                                ]))
                              ]));
                        }))));
  }
}
