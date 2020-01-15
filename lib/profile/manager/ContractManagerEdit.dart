import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/profile/manager/ContractManager.dart';
import 'package:leek/util/ScaffoldUtil.dart';

class ContractManagerEdit extends StatefulWidget {
  final String title;
  const ContractManagerEdit({this.title, Key key}) : super(key: key);

  @override
  _ContractManagerEditState createState() {
    return _ContractManagerEditState();
  }
}

class ConfigInfo {
  final String name;
  final String symbol;
  final String keyName;
  final double minValue;
  final double maxValue;
  final double defaultValue;
  final int fixed;
  final double setup;
  ConfigInfo(this.name, this.symbol, this.keyName, this.minValue, this.maxValue,
      this.defaultValue, this.fixed, this.setup);
}

class _ContractManagerEditState extends State<ContractManagerEdit> {
  bool passwordHidden = true;
  String _symbol = "";
  bool _quarter = false;
  bool _thisWeek = false;
  bool _nextWeek = false;
  String _reqStatus = "";
  bool _add = false;
  String _period = "";
  List<ConfigInfo> _configs;
  Map<String, String> _periods;

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
        _add = userOperation.info.add;
        _configs = userOperation.info.configs;
      });
    });
    queryUnUseList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void add() async {
    if (_symbol != "") {
      try {
        setState(() {
          _reqStatus = "request";
        });
        Response response =
            await Config.dio.post("/contract/admin/info", data: {
          "symbol": _symbol,
          "quarter": _quarter,
          "thisWeek": _thisWeek,
          "nextWeek": _nextWeek
        });
        Map<String, dynamic> data = response.data;
        if (data["status"] == "fail") {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.lightImpact();
        }
        setState(() {
          _reqStatus = data["status"];
        });
        ScaffoldUtil.show(_context, data,
            msg: "添加${data['status'] == 'ok' ? '成功' : '失败'}");
      } catch (e) {
        setState(() {
          _reqStatus = "timeout";
        });
        HapticFeedback.heavyImpact();
        ScaffoldUtil.show(_context, {"status": "timeout"});
      }
    }
  }

  void update(String contractType, bool value) async {
    try {
      setState(() {
        _reqStatus = "${contractType}_request";
      });
      Response response = await Config.dio.patch(
          "/contract/admin/info/auto/${_symbol}/${contractType}/${value}");
      Map<String, dynamic> data = response.data;
      if (data["status"] == "fail") {
        HapticFeedback.mediumImpact();
        ScaffoldUtil.show(_context, data,
            msg: "${value ? '开通' : '关闭'}" + "失败:${data['msg']}");
      } else {
        HapticFeedback.lightImpact();
      }

      setState(() {
        _reqStatus = contractType + "_" + data["status"];
      });
    } catch (e) {
      setState(() {
        _reqStatus = contractType + "_timeout";
      });
      HapticFeedback.heavyImpact();
      ScaffoldUtil.show(_context, {"status": "timeout"});
    }
  }

  void queryUnUseList() async {
    try {
      setState(() {
        _reqStatus = "request";
      });
      Response response = await Config.dio.get("/contract/admin/unuse/list");
      Map<String, dynamic> data = response.data;
      if (data["status"] == "ok") {
        List<dynamic> list = data["data"];
        Map<String, String> tmpMap = {};
        HapticFeedback.lightImpact();
        list.asMap().forEach((index, item) {
          if (index == 0) {
            print(_period);
            _period = item.toString();
          }
          tmpMap[item.toString()] = item.toString();
        });
        if (_add) {
          setState(() {
            _periods = tmpMap;
            _reqStatus = data["status"];
            _symbol = _period;
          });
        } else {
          setState(() {
            _periods = tmpMap;
            _reqStatus = data["status"];
          });
        }
      } else {
        setState(() {
          _reqStatus = data["status"];
        });
        HapticFeedback.mediumImpact();
        ScaffoldUtil.show(_context, data);
      }
    } catch (e) {
      setState(() {
        _reqStatus = "timeout";
      });
      HapticFeedback.heavyImpact();
      ScaffoldUtil.show(_context, {"status": "timeout"});
    }
  }

  BuildContext _context;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    ContractManagerOperation operation =
        ModalRoute.of(context).settings.arguments;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(
            context,
            ContractManagerInfo(_symbol, _quarter, _thisWeek, _nextWeek,
                _configs, operation.info.add));
        return false;
      },
      child: new Scaffold(
          appBar: AppBar(
            title: Text(operation.title),
            actions: <Widget>[
              (operation.info.add &&
                      _periods != null &&
                      _periods.keys.length != 0)
                  ? IconButton(
                      icon: Icon(Icons.save),
                      onPressed: _reqStatus != "request"
                          ? () {
                              add();
                            }
                          : null)
                  : Container()
            ],
          ),
          body: new Builder(builder: (c) {
            _context = c;
            return (operation.info.add &&
                    _periods != null &&
                    _periods.keys.length == 0)
                ? Container(
                    child: Center(
                      child: Text("已经全部添加完成、可以返回修改."),
                    ),
                  )
                : Column(children: <Widget>[
                    Container(
                      height: ScreenUtil.instance.setHeight(80),
                      child: Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(
                                ScreenUtil.instance.setWidth(20)),
                            child: Text("币种"),
                          ),
                          Container(
                              margin: EdgeInsets.only(
                                  left: ScreenUtil.instance.setWidth(40)),
                              child: operation.info.add
                                  ? (_periods == null
                                      ? _reqStatus == "timeout"
                                          ? IconButton(
                                              icon: Icon(
                                                Icons.refresh,
                                                color: Colors.blue,
                                              ),
                                              onPressed: () {
                                                queryUnUseList();
                                              },
                                            )
                                          : SizedBox(
                                              width: ScreenUtil.instance
                                                  .setWidth(50),
                                              height: ScreenUtil.instance
                                                  .setWidth(50),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                      : Row(children: <Widget>[
                                          DropdownButtonHideUnderline(
                                            child: DropdownButton(
                                              items: _periods.keys.map((name) {
                                                return new DropdownMenuItem(
                                                  child: Row(
                                                    children: <Widget>[
                                                      new Text(_periods[name]),
                                                      _period == name
                                                          ? Icon(
                                                              Icons.arrow_left,
                                                              color:
                                                                  Colors.blue,
                                                            )
                                                          : Container()
                                                    ],
                                                  ),
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
                                                  _symbol = value;
                                                });
                                                HapticFeedback.selectionClick();
                                              },
                                            ),
                                          )
                                        ]))
                                  : Text(
                                      operation.info.symbol,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    )),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          margin:
                              EdgeInsets.all(ScreenUtil.instance.setWidth(20)),
                          child: Text("类型"),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text("季度"),
                                  _reqStatus == "quarter_request"
                                      ? Container(
                                          padding: EdgeInsets.only(
                                              left: ScreenUtil.instance
                                                  .setWidth(42),
                                              right: ScreenUtil.instance
                                                  .setWidth(42)),
                                          child: SizedBox(
                                            width: ScreenUtil.instance
                                                .setWidth(40),
                                            height: ScreenUtil.instance
                                                .setWidth(40),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ))
                                      : IconButton(
                                          icon: Icon(
                                            _quarter
                                                ? Icons.check_box
                                                : Icons.check_box_outline_blank,
                                            color: _quarter
                                                ? Colors.blue
                                                : Colors.grey,
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
                                  _reqStatus == "this_week_request"
                                      ? Container(
                                          padding: EdgeInsets.only(
                                              left: ScreenUtil.instance
                                                  .setWidth(42),
                                              right: ScreenUtil.instance
                                                  .setWidth(42)),
                                          child: SizedBox(
                                            width: ScreenUtil.instance
                                                .setWidth(40),
                                            height: ScreenUtil.instance
                                                .setWidth(40),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ))
                                      : IconButton(
                                          icon: Icon(
                                            _thisWeek
                                                ? Icons.check_box
                                                : Icons.check_box_outline_blank,
                                            color: _thisWeek
                                                ? Colors.blue
                                                : Colors.grey,
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
                                  _reqStatus == "next_week_request"
                                      ? Container(
                                          padding: EdgeInsets.only(
                                              left: ScreenUtil.instance
                                                  .setWidth(42),
                                              right: ScreenUtil.instance
                                                  .setWidth(42)),
                                          child: SizedBox(
                                            width: ScreenUtil.instance
                                                .setWidth(40),
                                            height: ScreenUtil.instance
                                                .setWidth(40),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ))
                                      : IconButton(
                                          icon: Icon(
                                            _nextWeek
                                                ? Icons.check_box
                                                : Icons.check_box_outline_blank,
                                            color: _nextWeek
                                                ? Colors.blue
                                                : Colors.grey,
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
                    (operation.info.add || _configs == null)
                        ? Container()
                        : Expanded(
                            child: Container(
                              child: new ListView.separated(
                                  padding: EdgeInsets.all(5),
                                  itemCount: _configs.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return new Container(
                                        height: 1, color: Colors.grey[300]);
                                  },
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    ConfigInfo configInfo = _configs[index];
                                    return Row(
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.all(
                                              ScreenUtil.instance.setWidth(20)),
                                          child: Text(configInfo.name),
                                        ),
                                        Expanded(
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: <Widget>[
                                              Container(
                                                child: Text(configInfo.minValue
                                                    .toString()),
                                              ),
                                              Container(
                                                child: Text(configInfo.maxValue
                                                    .toString()),
                                              ),
                                              Container(
                                                child: Text(configInfo
                                                    .defaultValue
                                                    .toString()),
                                              ),
                                              Container(
                                                child: Text(configInfo.fixed
                                                    .toString()),
                                              ),
                                              Container(
                                                child: Text(configInfo.setup
                                                    .toString()),
                                              ),
                                            ])),
                                        IconButton(
                                          icon: Icon(
                                            Icons.chevron_right,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                                    context, '/config-edit',
                                                    arguments: configInfo)
                                                .then((result) {
                                              ConfigInfo configInfo = result;
                                              List<ConfigInfo> list = [];
                                              operation.info.configs
                                                  .forEach((item) {
                                                if (item.keyName ==
                                                    configInfo.keyName) {
                                                  list.add(configInfo);
                                                } else {
                                                  list.add(item);
                                                }
                                              });
                                              setState(() {
                                                _configs = list;
                                              });
                                            });
                                          },
                                        )
                                      ],
                                    );
                                  }),
                            ),
                          ),
                  ]);
          })),
    );
  }
}
