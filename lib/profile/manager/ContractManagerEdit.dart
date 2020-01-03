import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/profile/manager/ContractManager.dart';
import 'package:leek/profile/manager/User.dart';
import 'package:leek/store/UserStore.dart';
import 'package:leek/util/ScaffoldUtil.dart';
import 'package:provider/provider.dart';
import 'package:vibrate/vibrate.dart';

class ContractManagerEdit extends StatefulWidget {
  final String title;
  const ContractManagerEdit({this.title, Key key}) : super(key: key);

  @override
  _ContractManagerEditState createState() {
    return _ContractManagerEditState();
  }
}

class _ContractManagerEditState extends State<ContractManagerEdit> {
  bool passwordHidden = true;
  String _status = "normal";
  String _symbol = "";
  bool _quarter = false;
  bool _thisWeek = false;
  bool _nextWeek = false;
  String _reqStatus = "";

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      ContractManagerOperation userOperation =
          ModalRoute.of(context).settings.arguments;
      setState(() {
        _symbol = userOperation.info.symbol;
        _quarter = userOperation.info.quarter;
        _thisWeek = userOperation.info.thisWeek;
        _nextWeek = userOperation.info.nextWeek;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void add() async {
    try {
      setState(() {
        _reqStatus = "request";
      });
      Response response = await Config.dio.post("/user/admin/info",
          data: {"symbol": _symbol, "password": _symbol});
      Map<String, dynamic> data = response.data;
      setState(() {
        _reqStatus = data["status"];
      });
      ScaffoldUtil.show(_context, data,
          msg: "添加${data['status'] == 'ok' ? '成功' : '失败'}");
    } catch (e) {
      setState(() {
        _reqStatus = "timeout";
      });
      ScaffoldUtil.show(_context, {"status": "timeout"});
    }
  }


  void update(String contractType, bool value) async {
    try {
      setState(() {
        _reqStatus = "request";
      });
      Response response = await Config.dio.patch(
          "/contract/admin/info/auto/${_symbol}/${contractType}/${value}");
      Map<String, dynamic> data = response.data;
      ScaffoldUtil.show(_context, data,
          msg: "${value ? '开通' : '关闭'}" +
              (data["status"] == "ok" ? "成功" : "失败"));
      if (data["status"] == "ok") {
        if (_status == "normal") {
          setState(() {
            _reqStatus = data["status"];
            _status = 'locked';
          });
        } else {
          setState(() {
            _reqStatus = data["status"];
            _status = 'normal';
          });
        }
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

  BuildContext _context;

  String _period = "BTC";
  Map<String, String> _periods = {
    "BTC": "BTC",
    "ETH": "ETH",
    "ETC": "ETC",
  };

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    ContractManagerOperation operation =
        ModalRoute.of(context).settings.arguments;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(
            context,
            ContractManagerInfo(
                _symbol, _quarter, _thisWeek, _nextWeek, operation.info.add));
        return false;
      },
      child: new Scaffold(
          appBar: AppBar(
            title: Text(operation.title),
            actions: <Widget>[
              operation.info.add
                  ? IconButton(
                      icon: Icon(Icons.save),
                      onPressed: () {
                        add();
                      })
                  : Container()
            ],
          ),
          body: new Builder(builder: (context) {
            _context = context;
            return Container(
                margin: EdgeInsets.all(10),
                child: Column(children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(10),
                        child: Text("币种"),
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 20),
                          child: operation.info.add
                              ? Row(children: <Widget>[
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      items: _periods.keys.map((name) {
                                        return new DropdownMenuItem(
                                          child: new Text(_periods[name]),
                                          value: name,
                                        );
                                      }).toList(),
                                      iconSize: 18,
                                      hint: Text(
                                        _periods[_period],
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _period = value;
                                        });
                                        // _choose(_symbol, _type);
                                        Vibrate.feedback(FeedbackType.light);
                                      },
                                    ),
                                  )
                                ])
                              : Text(operation.info.symbol)),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(10),
                        child: Text("类型"),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text("季度"),
                                IconButton(
                                    icon: Icon(
                                      _quarter
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color:
                                          _quarter ? Colors.blue : Colors.grey,
                                    ),
                                    onPressed: () {
                                      if (!operation.info.add) {
                                        update("quarter", !_quarter);
                                      }
                                      setState(() {
                                        _quarter = !_quarter;
                                      });
                                    })
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text("本周"),
                                IconButton(
                                    icon: Icon(
                                      _thisWeek
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color:
                                          _thisWeek ? Colors.blue : Colors.grey,
                                    ),
                                    onPressed: () {
                                      if (!operation.info.add) {
                                        update("this_week", !_thisWeek);
                                      }
                                      setState(() {
                                        _thisWeek = !_thisWeek;
                                      });
                                    })
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text("下周"),
                                IconButton(
                                    icon: Icon(
                                      _nextWeek
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color:
                                          _nextWeek ? Colors.blue : Colors.grey,
                                    ),
                                    onPressed: () {
                                      if (!operation.info.add) {
                                        update("next_week", !_nextWeek);
                                      }
                                      setState(() {
                                        _nextWeek = !_nextWeek;
                                      });
                                    })
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ]));
          })),
    );
  }
}
