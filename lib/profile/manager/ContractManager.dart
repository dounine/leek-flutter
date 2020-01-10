import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/profile/manager/ContractManagerEdit.dart';
import 'package:leek/store/UserStore.dart';
import 'package:leek/util/ScaffoldUtil.dart';
import 'package:provider/provider.dart';

class ContractManager extends StatefulWidget {
  const ContractManager({Key key}) : super(key: key);

  @override
  _ContractManagerState createState() {
    return _ContractManagerState();
  }
}

class ContractManagerInfo {
  final String symbol;
  final bool quarter;
  final bool thisWeek;
  final bool nextWeek;
  final bool add;
  final List<ConfigInfo> configs;
  ContractManagerInfo(this.symbol, this.quarter, this.thisWeek, this.nextWeek,
      this.configs, this.add);
}

class ContractManagerOperation {
  final String title;
  final ContractManagerInfo info;
  ContractManagerOperation(this.title, this.info);
}

class _ContractManagerState extends State<ContractManager> {
  List<ContractManagerInfo> _listInfos;
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
      Response response = await Config.dio.get("/contract/admin/list");
      Map<String, dynamic> data = response.data;
      if (data["status"] == "ok") {
        List<dynamic> ll = data["data"];
        List<ContractManagerInfo> list = ll.map((item) {
          List<dynamic> configs = item["configs"];
          List<ConfigInfo> igs = configs.map((it) {
            return ConfigInfo(
                it["name"],
                it["symbol"],
                it["keyName"],
                it["minValue"],
                it["maxValue"],
                it["defaultValue"],
                it["fixed"],
                it["setup"]);
          }).toList();
          return ContractManagerInfo(item["symbol"], item["quarter"],
              item["thisWeek"], item["nextWeek"], igs, false);
        }).toList();
        setState(() {
          _reqStatus = data["status"];
          _listInfos = list;
        });
      } else {
        setState(() {
          _reqStatus = data["status"];
        });
        ScaffoldUtil.show(_context, data);
      }
    } catch (e) {
      print(e);
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
          title: Text("合约管理"),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.pushNamed(context, '/contract-edit',
                      arguments: ContractManagerOperation(
                          '添加',
                          ContractManagerInfo(
                              "", false, false, false, [], true)));
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
                              padding: EdgeInsets.all(5),
                              itemCount: _listInfos.length,
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return new Container(
                                    height: 1, color: Colors.grey[300]);
                              },
                              itemBuilder: (BuildContext context, int index) {
                                ContractManagerInfo info = _listInfos[index];
                                return Container(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                      Container(
                                          margin: EdgeInsets.all(
                                              ScreenUtil.instance.setWidth(20)),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Row(children: <Widget>[
                                                  Text(info.symbol,
                                                      style: TextStyle(
                                                          fontSize: 16)),
                                                ]),
                                                SizedBox(
                                                  height: ScreenUtil.instance
                                                      .setHeight(18),
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Text("季度",
                                                        style: TextStyle(
                                                            color: info.quarter
                                                                ? Colors.black
                                                                : Colors.grey)),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: Text("/",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey)),
                                                    ),
                                                    Text("本周",
                                                        style: TextStyle(
                                                            color: info.thisWeek
                                                                ? Colors.black
                                                                : Colors.grey)),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: Text(
                                                        "/",
                                                        style: TextStyle(
                                                            color: Colors.grey),
                                                      ),
                                                    ),
                                                    Text("下周",
                                                        style: TextStyle(
                                                            color: info.nextWeek
                                                                ? Colors.black
                                                                : Colors.grey)),
                                                  ],
                                                )
                                              ])),
                                      Container(
                                          child: Row(children: <Widget>[
                                        IconButton(
                                            color: Colors.blueGrey,
                                            icon: Icon(Icons.edit),
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                      context, '/contract-edit',
                                                      arguments:
                                                          ContractManagerOperation(
                                                              '修改信息', info))
                                                  .then((result) {
                                                ContractManagerInfo backInfo =
                                                    result;
                                                setState(() {
                                                  _listInfos =
                                                      _listInfos.map((item) {
                                                    if (item.symbol ==
                                                        backInfo.symbol) {
                                                      return ContractManagerInfo(
                                                          backInfo.symbol,
                                                          backInfo.quarter,
                                                          backInfo.thisWeek,
                                                          backInfo.nextWeek,
                                                          backInfo.configs,
                                                          backInfo.add);
                                                    } else {
                                                      return item;
                                                    }
                                                  }).toList();
                                                });
                                              });
                                            })
                                      ]))
                                    ]));
                              }))));
        }));
  }
}
