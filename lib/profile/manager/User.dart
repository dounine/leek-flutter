import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/util/ScaffoldUtil.dart';
import 'package:vibrate/vibrate.dart';

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
  final bool add;
  UserInfo(this.phone, this.status, this.password, this.isAdmin,
      this.createTime, this.add);
}

class UserOperation {
  final String title;
  final UserInfo info;
  UserOperation(this.title, this.info);
}

class _UserState extends State<User> {
  List<UserInfo> _listInfos;
  String _reqStatus = "";
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
    try {
      setState(() {
        _reqStatus = "request";
      });
      Response response = await Config.dio.get("/user/admin/list");
      Map<String, dynamic> data = response.data;
      if (data["status"] == "ok") {
        List<dynamic> ll = data["data"];
        List<UserInfo> list = ll.map((item) {
          return UserInfo(item["phone"], item["status"], item["password"],
              item["admin"], item["createTime"], false);
        }).toList();
        Vibrate.feedback(FeedbackType.light);
        setState(() {
          _reqStatus = data["status"];
          _listInfos = list;
        });
      } else {
        setState(() {
          _reqStatus = data["status"];
        });
        Vibrate.feedback(FeedbackType.warning);
        ScaffoldUtil.show(_context, data);
      }
    } catch (e) {
      Vibrate.feedback(FeedbackType.warning);
      setState(() {
        _reqStatus = "timeout";
      });
      ScaffoldUtil.show(_context, {"status": "timeout"});
    }
  }

  Future<Null> _refresh() async {
    query();
    return;
  }

  BuildContext _context;

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
                      arguments: UserOperation(
                          '添加', UserInfo("", "normal", "", false, "", true)));
                })
          ],
        ),
        body: new Builder(builder: (context) {
          _context = context;
          return RefreshIndicator(
              onRefresh: _refresh,
              child: _listInfos == null
                  ? (_reqStatus == "timeout"
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                              Text("您的网络不给力、刷新重试"),
                              IconButton(
                                  icon: Icon(Icons.refresh, color: Colors.blue),
                                  onPressed: () {
                                    query();
                                  })
                            ])
                      : Center(
                          child: CircularProgressIndicator(),
                        ))
                  : (_listInfos.length == 0
                      ? Center(
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: ScreenUtil.instance.setHeight(80),
                              ),
                              Icon(
                                Icons.inbox,
                                size: 36,
                                color: Colors.black12,
                              ),
                              Text(
                                "没有数据显示",
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              )
                            ],
                          ),
                        )
                      : Container(
                          child: new ListView.separated(
                              padding: EdgeInsets.all(
                                  ScreenUtil.instance.setWidth(10)),
                              itemCount: _listInfos.length,
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return new Container(
                                    height: 1, color: Colors.grey[300]);
                              },
                              itemBuilder: (BuildContext context, int index) {
                                UserInfo info = _listInfos[index];
                                return Container(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                      Container(
                                          margin: EdgeInsets.all(
                                              ScreenUtil.instance.setWidth(20)),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Row(children: <Widget>[
                                                  Text(info.phone,
                                                      style: TextStyle(
                                                          color: info.status ==
                                                                  "normal"
                                                              ? Colors.black
                                                              : Colors.grey,
                                                          fontSize: 16)),
                                                  info.isAdmin
                                                      ? Icon(
                                                          Icons.assignment_ind,
                                                          color:
                                                              Colors.redAccent)
                                                      : Container()
                                                ]),
                                                SizedBox(
                                                  height: ScreenUtil.instance
                                                      .setHeight(18),
                                                ),
                                                Text(info.createTime,
                                                    style: TextStyle(
                                                        color: Colors.grey))
                                              ])),
                                      IconButton(
                                          color: Colors.blueGrey,
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                                    context, '/user-edit',
                                                    arguments: UserOperation(
                                                        '修改信息', info))
                                                .then((result) {
                                              UserInfo backInfo = result;
                                              setState(() {
                                                _listInfos =
                                                    _listInfos.map((item) {
                                                  if (item.phone ==
                                                      backInfo.phone) {
                                                    return UserInfo(
                                                        backInfo.phone,
                                                        backInfo.status,
                                                        backInfo.password,
                                                        backInfo.isAdmin,
                                                        item.createTime,
                                                        backInfo.add);
                                                  } else {
                                                    return item;
                                                  }
                                                }).toList();
                                              });
                                            });
                                          })
                                    ]));
                              }))));
        }));
  }
}
