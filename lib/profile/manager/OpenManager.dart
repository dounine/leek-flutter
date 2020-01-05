import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/store/UserStore.dart';
import 'package:leek/util/ScaffoldUtil.dart';
import 'package:provider/provider.dart';

class OpenManager extends StatefulWidget {
  const OpenManager({Key key}) : super(key: key);

  @override
  _OpenManagerState createState() {
    return _OpenManagerState();
  }
}

class OpenManagerItem {
  final String contractType;
  final bool buy;
  final bool sell;
  OpenManagerItem(this.contractType, this.buy, this.sell);
}

class OpenManagerInfo {
  final String phone;
  final Map<String, List<OpenManagerItem>> list;
  OpenManagerInfo(this.phone, this.list);
}

class OpenManagerOperation {
  final String title;
  final OpenManagerInfo info;
  OpenManagerOperation(this.title, this.info);
}

class _OpenManagerState extends State<OpenManager> {
  List<OpenManagerInfo> _listInfos;
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
      Response response = await Config.dio.get("/open/info/admin/all");
      Map<String, dynamic> data = response.data;
      if (data["status"] == "ok") {
        List<dynamic> ll = data["data"];
        List<OpenManagerInfo> infos = [];
        ll.forEach((item) {
          Map<String, List<OpenManagerItem>> l = new Map();
          Map<String, dynamic> maps = item["list"];
          maps.forEach((j, i) {
            (i as List<dynamic>).forEach((ci) {
              OpenManagerItem _item =
                  OpenManagerItem(ci["contractType"], ci["buy"], ci["sell"]);
              if (l[j] == null) {
                l[j] = [_item];
              } else {
                l[j].add(_item);
              }
            });
          });
          infos.add(OpenManagerInfo(item["phone"], l));
        });
        setState(() {
          _reqStatus = data["status"];
          _listInfos = infos;
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
          title: Text("用户合约管理"),
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
                                height: 40,
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
                                OpenManagerInfo info = _listInfos[index];
                                List<String> names = [];
                                info.list.forEach((item, i) {
                                  if (info.list[item]
                                          .where((citem) =>
                                              citem.buy || citem.sell)
                                          .length >
                                      0) {
                                    names.add(item);
                                  }
                                });
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                        margin: EdgeInsets.all(
                                            ScreenUtil.instance.setWidth(20)),
                                        child: Column(children: <Widget>[
                                          Text(info.phone,
                                              style: TextStyle(
                                                fontSize: 16,
                                              )),
                                          SizedBox(
                                              height: ScreenUtil.instance
                                                  .setWidth(18)),
                                          Row(
                                            children: names.length == 0
                                                ? [
                                                    Container(
                                                        margin: EdgeInsets.only(
                                                            left: 4),
                                                        child: Text(
                                                          "--",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey),
                                                        ))
                                                  ]
                                                : names
                                                    .asMap()
                                                    .map((index, symbol) {
                                                      return MapEntry(
                                                          index,
                                                          Row(
                                                            children: <Widget>[
                                                              Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              1),
                                                                  child: Text(
                                                                    symbol,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey),
                                                                  )),
                                                              (names.length !=
                                                                          1 &&
                                                                      index !=
                                                                          names.length -
                                                                              1)
                                                                  ? Container(
                                                                      margin: EdgeInsets.only(
                                                                          left:
                                                                              1,
                                                                          right:
                                                                              1),
                                                                      child:
                                                                          Text(
                                                                        "/",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.grey),
                                                                      ))
                                                                  : Container()
                                                            ],
                                                          ));
                                                    })
                                                    .values
                                                    .toList(),
                                          )
                                        ])),
                                    IconButton(
                                      color: Colors.blueGrey,
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                                context, '/open-manager-edit',
                                                arguments: OpenManagerOperation(
                                                    '修改信息', info))
                                            .then((result) {
                                          OpenManagerInfo backInfo = result;
                                          List<OpenManagerInfo> lis = [];
                                          _listInfos.forEach((item) {
                                            if (item.phone == backInfo.phone) {
                                              lis.add(backInfo);
                                            } else {
                                              lis.add(item);
                                            }
                                          });
                                          setState(() {
                                            _listInfos = lis;
                                          });
                                        });
                                      },
                                    )
                                  ],
                                );
                              }))));
        }));
  }
}
