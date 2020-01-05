import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/profile/manager/ContractManager.dart';
import 'package:leek/profile/manager/OpenManager.dart';
import 'package:leek/util/ScaffoldUtil.dart';
import 'package:vibrate/vibrate.dart';

class OpenManagerEdit extends StatefulWidget {
  final String title;
  const OpenManagerEdit({this.title, Key key}) : super(key: key);

  @override
  _OpenManagerEditState createState() {
    return _OpenManagerEditState();
  }
}

class _OpenManagerEditState extends State<OpenManagerEdit> {
  bool passwordHidden = true;
  String _phone = "";
  Map<String, List<OpenManagerItem>> _list;
  String _reqStatus = "";

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      OpenManagerOperation userOperation =
          ModalRoute.of(context).settings.arguments;
      setState(() {
        _phone = userOperation.info.phone;
        _list = userOperation.info.list;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void update(
      String symbol, String contractType, String direction, bool add) async {
    if (add) {
      try {
        setState(() {
          _reqStatus = "request";
        });
        Map<String, String> formData = {
          "phone": _phone,
          "symbol": symbol,
          "contractType": contractType,
          "direction": direction
        };
        Response response =
            await Config.dio.post("/open/info/admin", data: formData);
        Map<String, dynamic> data = response.data;
        ScaffoldUtil.show(_context, data,
            msg: "开通" + (data["status"] == "ok" ? "成功" : "失败"));
        if (data["status"] == "ok") {
          Map<String, List<OpenManagerItem>> copyList = new Map();
          _list.keys.forEach((symbolName) {
            if (symbolName == symbol) {
              List<OpenManagerItem> convertList = [];
              _list[symbolName].forEach((citem) {
                if (citem.contractType == contractType) {
                  convertList.add(OpenManagerItem(
                      contractType,
                      direction == "buy" ? true : citem.buy,
                      direction == "sell" ? true : citem.sell));
                } else {
                  convertList.add(citem);
                }
              });
              copyList[symbolName] = convertList;
            } else {
              copyList[symbolName] = _list[symbolName];
            }
          });
          setState(() {
            _reqStatus = data["status"];
            _list = copyList;
          });
        } else {
          ScaffoldUtil.show(_context, data);
        }
      } catch (e) {
        setState(() {
          _reqStatus = "timeout";
        });
        ScaffoldUtil.show(_context, {"status": "timeout"});
      }
    } else {
      try {
        setState(() {
          _reqStatus = "request";
        });
        Response response = await Config.dio.delete(
            "/open/info/admin/${_phone}/${symbol}/${contractType}/${direction}");
        Map<String, dynamic> data = response.data;
        ScaffoldUtil.show(_context, data,
            msg: "关闭" + (data["status"] == "ok" ? "成功" : "失败"));
        if (data["status"] == "ok") {
          Map<String, List<OpenManagerItem>> copyList = new Map();
          _list.keys.forEach((symbolName) {
            if (symbolName == symbol) {
              List<OpenManagerItem> convertList = [];
              _list[symbolName].forEach((citem) {
                if (citem.contractType == contractType) {
                  convertList.add(OpenManagerItem(
                      contractType,
                      direction == "buy" ? false : citem.buy,
                      direction == "sell" ? false : citem.sell));
                } else {
                  convertList.add(citem);
                }
              });
              copyList[symbolName] = convertList;
            } else {
              copyList[symbolName] = _list[symbolName];
            }
          });
          setState(() {
            _reqStatus = data["status"];
            _list = copyList;
          });
        } else {
          ScaffoldUtil.show(_context, data);
        }
      } catch (e) {
        setState(() {
          _reqStatus = "timeout";
        });
        ScaffoldUtil.show(_context, {"status": "timeout"});
      }
    }
  }

  BuildContext _context;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    OpenManagerOperation operation = ModalRoute.of(context).settings.arguments;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, OpenManagerInfo(_phone, _list));
        return false;
      },
      child: new Scaffold(
          appBar: AppBar(
            title: Text(operation.title),
          ),
          body: new Builder(builder: (c) {
            _context = c;
            return _list == null
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Container(
                    child: new ListView.separated(
                        padding:
                            EdgeInsets.all(ScreenUtil.instance.setWidth(10)),
                        itemCount: _list.keys.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return new Container(
                              height: 1, color: Colors.grey[300]);
                        },
                        itemBuilder: (BuildContext context, int index) {
                          String symbol = _list.keys.toList()[index];
                          List<OpenManagerItem> listInfo = _list[symbol];
                          bool quarterBuy = listInfo
                                  .where((item) =>
                                      item.contractType == "quarter" &&
                                      item.buy)
                                  .length !=
                              0;
                          bool quarterSell = listInfo
                                  .where((item) =>
                                      item.contractType == "quarter" &&
                                      item.sell)
                                  .length !=
                              0;
                          bool thisWeekBuy = listInfo
                                  .where((item) =>
                                      item.contractType == "this_week" &&
                                      item.buy)
                                  .length !=
                              0;
                          bool thisWeekSell = listInfo
                                  .where((item) =>
                                      item.contractType == "this_week" &&
                                      item.sell)
                                  .length !=
                              0;
                          bool nextWeekBuy = listInfo
                                  .where((item) =>
                                      item.contractType == "next_week" &&
                                      item.buy)
                                  .length !=
                              0;
                          bool nextWeekSell = listInfo
                                  .where((item) =>
                                      item.contractType == "next_week" &&
                                      item.sell)
                                  .length !=
                              0;
                          return Column(
                            children: <Widget>[
                              Container(
                                height: ScreenUtil.instance.setHeight(100),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.all(
                                          ScreenUtil.instance.setWidth(20)),
                                      child: Text("币种"),
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(
                                            left: ScreenUtil.instance
                                                .setWidth(40)),
                                        child: Text(
                                          symbol,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500),
                                        )),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: ScreenUtil.instance.setHeight(10),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.all(
                                        ScreenUtil.instance.setWidth(20)),
                                    child: Text("类型"),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Text("季度"),
                                            Column(
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.trending_up,
                                                      color: Colors.green,
                                                    ),
                                                    IconButton(
                                                        icon: Icon(
                                                          quarterBuy
                                                              ? Icons.check_box
                                                              : Icons
                                                                  .check_box_outline_blank,
                                                          color: quarterBuy
                                                              ? Colors.blue
                                                              : Colors.grey,
                                                        ),
                                                        onPressed: () {
                                                          update(
                                                              symbol,
                                                              "quarter",
                                                              "buy",
                                                              !quarterBuy);
                                                        })
                                                  ],
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.trending_down,
                                                      color: Colors.red,
                                                    ),
                                                    IconButton(
                                                        icon: Icon(
                                                          quarterSell
                                                              ? Icons.check_box
                                                              : Icons
                                                                  .check_box_outline_blank,
                                                          color: quarterSell
                                                              ? Colors.blue
                                                              : Colors.grey,
                                                        ),
                                                        onPressed: () {
                                                          update(
                                                              symbol,
                                                              "quarter",
                                                              "sell",
                                                              !quarterSell);
                                                        })
                                                  ],
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text("本周"),
                                            Column(
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.trending_up,
                                                      color: Colors.green,
                                                    ),
                                                    IconButton(
                                                        icon: Icon(
                                                          thisWeekBuy
                                                              ? Icons.check_box
                                                              : Icons
                                                                  .check_box_outline_blank,
                                                          color: thisWeekBuy
                                                              ? Colors.blue
                                                              : Colors.grey,
                                                        ),
                                                        onPressed: () {
                                                          update(
                                                              symbol,
                                                              "this_week",
                                                              "buy",
                                                              !thisWeekBuy);
                                                        })
                                                  ],
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.trending_down,
                                                      color: Colors.red,
                                                    ),
                                                    IconButton(
                                                        icon: Icon(
                                                          thisWeekSell
                                                              ? Icons.check_box
                                                              : Icons
                                                                  .check_box_outline_blank,
                                                          color: thisWeekSell
                                                              ? Colors.blue
                                                              : Colors.grey,
                                                        ),
                                                        onPressed: () {
                                                          update(
                                                              symbol,
                                                              "this_week",
                                                              "sell",
                                                              !thisWeekSell);
                                                        })
                                                  ],
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text("下周"),
                                            Column(
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.trending_up,
                                                      color: Colors.green,
                                                    ),
                                                    IconButton(
                                                        icon: Icon(
                                                          nextWeekBuy
                                                              ? Icons.check_box
                                                              : Icons
                                                                  .check_box_outline_blank,
                                                          color: nextWeekBuy
                                                              ? Colors.blue
                                                              : Colors.grey,
                                                        ),
                                                        onPressed: () {
                                                          update(
                                                              symbol,
                                                              "next_week",
                                                              "buy",
                                                              !nextWeekBuy);
                                                        })
                                                  ],
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.trending_down,
                                                      color: Colors.red,
                                                    ),
                                                    IconButton(
                                                        icon: Icon(
                                                          nextWeekSell
                                                              ? Icons.check_box
                                                              : Icons
                                                                  .check_box_outline_blank,
                                                          color: nextWeekSell
                                                              ? Colors.blue
                                                              : Colors.grey,
                                                        ),
                                                        onPressed: () {
                                                          update(
                                                              symbol,
                                                              "next_week",
                                                              "sell",
                                                              !nextWeekSell);
                                                        })
                                                  ],
                                                )
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          );
                        }));
          })),
    );
  }
}
