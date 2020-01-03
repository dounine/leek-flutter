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
  final String direction;
  final String symbol;
  OpenManagerItem(this.symbol, this.contractType, this.direction);
}

class OpenManagerInfo {
  final String phone;
  final List<OpenManagerItem> list;
  OpenManagerInfo(this.phone, this.list);
}

class OpenManagerOperation {
  final String title;
  final OpenManagerInfo openManagerInfo;
  OpenManagerOperation(this.title, this.openManagerInfo);
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
        List<OpenManagerInfo> list = ll.map((item) {
          List<OpenManagerItem> items = [];
          item["list"].forEach((j) {
            items.add(OpenManagerItem(
                j["symbol"], j["contractType"], j["direction"]));
          });
          return OpenManagerInfo(item["phone"], items);
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
                              padding: EdgeInsets.all(5),
                              itemCount: _listInfos.length,
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return new Container(
                                    height: 1, color: Colors.grey[300]);
                              },
                              itemBuilder: (BuildContext context, int index) {
                                OpenManagerInfo info = _listInfos[index];
                                List<String> names = info.list
                                    .map((item) {
                                      return item.symbol;
                                    })
                                    .toSet()
                                    .toList();
                                return Container(
                                    margin: EdgeInsets.all(10),
                                    child: Column(children: <Widget>[
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(info.phone,
                                            style: TextStyle(
                                              fontSize: 18,
                                            )),
                                      ),
                                      SizedBox(height: 6),
                                      Row(
                                        children: names.length == 0
                                            ? [
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        left: 4),
                                                    child: Text(
                                                      "--",
                                                      style: TextStyle(
                                                          color: Colors.grey),
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
                                                                      left: 4),
                                                              child: Text(
                                                                symbol,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .grey),
                                                              )),
                                                          (names.length != 1 &&
                                                                  index !=
                                                                      names.length -
                                                                          1)
                                                              ? Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              2,
                                                                          right:
                                                                              2),
                                                                  child: Text(
                                                                    "/",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey),
                                                                  ))
                                                              : Container()
                                                        ],
                                                      ));
                                                })
                                                .values
                                                .toList(),
                                      )
                                    ]));
                              }))));
        }));
  }
}
