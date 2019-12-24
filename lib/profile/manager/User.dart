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
  final bool isAdmin;
  UserInfo(this.phone, this.status, this.isAdmin);
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
        return UserInfo(item["phone"], item["status"], item["admin"]);
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
            IconButton(icon: Icon(Icons.person_add), onPressed: () {})
          ],
        ),
        body: RefreshIndicator(
            onRefresh: _refresh,
            child: _listInfos == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    child: new ListView.builder(
                        padding: EdgeInsets.all(5),
                        itemCount: _listInfos.length,
                        itemBuilder: (BuildContext context, int index) {
                          return new Text(_listInfos[index].phone);
                        }))));
  }
}
