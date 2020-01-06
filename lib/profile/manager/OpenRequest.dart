import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/store/UserStore.dart';
import 'package:leek/util/ScaffoldUtil.dart';
import 'package:provider/provider.dart';

class OpenRequest extends StatefulWidget {
  const OpenRequest({Key key}) : super(key: key);

  @override
  _OpenRequestState createState() {
    return _OpenRequestState();
  }
}

class OpenRequestInfo {
  final String phone;
  final String symbol;
  final String direction;
  final String contractType;
  final String createTime;
  final bool agree;
  OpenRequestInfo(this.phone, this.symbol, this.direction, this.contractType,
      this.createTime, this.agree);
}

class OpenRequestOperation {
  final String title;
  final OpenRequestInfo openRequestInfo;
  OpenRequestOperation(this.title, this.openRequestInfo);
}

class _OpenRequestState extends State<OpenRequest> {
  List<OpenRequestInfo> _listInfos;
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

  void agree(String phone, String symbol, String contractType, String direction,
      bool value) async {
    try {
      setState(() {
        _reqStatus = "request";
      });
      Response response = await Config.dio.patch(
          "/open/request/info/admin/${phone}/${symbol}/${contractType}/${direction}/${value}");
      Map<String, dynamic> data = response.data;
      if (data["status"] == "ok") {
        List<OpenRequestInfo> list = _listInfos.map((item) {
          if (item.phone == phone &&
              item.symbol == symbol &&
              item.contractType == contractType &&
              item.direction == direction) {
            return OpenRequestInfo(
                phone, symbol, direction, contractType, item.createTime, value);
          } else {
            return item;
          }
        }).toList();

        setState(() {
          _reqStatus = data["status"];
          _listInfos = list;
        });
      } else {
        print(data);
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

  void query() async {
    try {
      setState(() {
        _reqStatus = "request";
      });
      Response response = await Config.dio.get("/open/request/admin/list");
      Map<String, dynamic> data = response.data;
      if (data["status"] == "ok") {
        List<dynamic> ll = data["data"];
        List<OpenRequestInfo> list = ll.map((item) {
          return OpenRequestInfo(
              item["phone"],
              item["symbol"],
              item["direction"],
              item["contractType"],
              item["createTime"],
              item["agree"]);
        }).toList();
        setState(() {
          _reqStatus = data["status"];
          _listInfos = list;
        });
      } else {
        print(data);
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
          title: Text("合约申请管理"),
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
                              itemCount: _listInfos.length,
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      new Divider(
                                        height: 1,
                                      ),
                              itemBuilder: (BuildContext context, int index) {
                                OpenRequestInfo info = _listInfos[index];
                                return Container(
                                    margin: EdgeInsets.all(
                                        ScreenUtil.instance.setWidth(30)),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                Row(children: <Widget>[
                                                  Text(info.phone,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      )),
                                                ]),
                                                SizedBox(
                                                  height: 6,
                                                ),
                                                Text(info.createTime,
                                                    style: TextStyle(
                                                        color: Colors.grey))
                                              ])),
                                          Row(children: <Widget>[
                                            Text(info.symbol),
                                            Padding(
                                              padding: const EdgeInsets.all(2),
                                              child: Text("/",
                                                  style: TextStyle(
                                                      color: Colors.grey)),
                                            ),
                                            Text(
                                                info.contractType == "quarter"
                                                    ? "季度"
                                                    : (info.contractType ==
                                                            "this_week"
                                                        ? "本周"
                                                        : "下周"),
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                            Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: Text("/",
                                                  style: TextStyle(
                                                      color: Colors.grey)),
                                            ),
                                            Text(
                                                info.direction == "buy"
                                                    ? "追涨"
                                                    : "杀跌",
                                                style: TextStyle(
                                                    color: Colors.grey))
                                          ]),
                                          info.agree != null
                                              ? Container(
                                                  child: (info.agree
                                                      ? Text(
                                                          "同意",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green),
                                                        )
                                                      : Text("拒绝",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey))))
                                              : Container(
                                                  child: Row(children: <Widget>[
                                                  IconButton(
                                                      color: Colors.blue,
                                                      icon: Icon(Icons
                                                          .check_circle_outline),
                                                      onPressed:
                                                          info.agree == null
                                                              ? () {
                                                                  agree(
                                                                      info.phone,
                                                                      info.symbol,
                                                                      info.contractType,
                                                                      info.direction,
                                                                      true);
                                                                }
                                                              : null),
                                                  IconButton(
                                                      color: Colors.blue,
                                                      icon: Icon(Icons
                                                          .do_not_disturb_alt),
                                                      onPressed:
                                                          info.agree == null
                                                              ? () {
                                                                  agree(
                                                                      info.phone,
                                                                      info.symbol,
                                                                      info.contractType,
                                                                      info.direction,
                                                                      false);
                                                                }
                                                              : null)
                                                ]))
                                        ]));
                              }))));
        }));
  }
}
