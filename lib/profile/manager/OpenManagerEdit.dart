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
  String _status = "normal";
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

  void update(String contractType, bool value) async {
    try {
      setState(() {
        _reqStatus = "request";
      });
      Response response =
          await Config.dio.patch("/contract/admin/info/auto/${_phone}");
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
                          bool quarter = listInfo
                                  .where(
                                      (item) => item.contractType == "quarter")
                                  .length !=
                              0;
                          bool thisWeek = listInfo
                                  .where((item) =>
                                      item.contractType == "this_week")
                                  .length !=
                              0;
                          bool nextWeek = listInfo
                                  .where((item) =>
                                      item.contractType == "next_week")
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
                                height: ScreenUtil.instance.setHeight(20),
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
                                            IconButton(
                                                icon: Icon(
                                                  quarter
                                                      ? Icons.check_box
                                                      : Icons
                                                          .check_box_outline_blank,
                                                  color: quarter
                                                      ? Colors.blue
                                                      : Colors.grey,
                                                ),
                                                onPressed: () {
                                                  update("quarter", !quarter);
                                                })
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text("本周"),
                                            IconButton(
                                                icon: Icon(
                                                  thisWeek
                                                      ? Icons.check_box
                                                      : Icons
                                                          .check_box_outline_blank,
                                                  color: thisWeek
                                                      ? Colors.blue
                                                      : Colors.grey,
                                                ),
                                                onPressed: () {
                                                  update(
                                                      "this_week", !thisWeek);
                                                })
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text("下周"),
                                            IconButton(
                                                icon: Icon(
                                                  nextWeek
                                                      ? Icons.check_box
                                                      : Icons
                                                          .check_box_outline_blank,
                                                  color: nextWeek
                                                      ? Colors.blue
                                                      : Colors.grey,
                                                ),
                                                onPressed: () {
                                                  update(
                                                      "next_week", !nextWeek);
                                                })
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          );
                        })
                    // Column(children: <Widget>[
                    // Container(
                    //   height: ScreenUtil.instance.setHeight(100),
                    //   child: Row(
                    //     children: <Widget>[
                    //       Container(
                    //         margin: EdgeInsets.all(10),
                    //         child: Text("币种"),
                    //       ),
                    //       Container(
                    //           margin: EdgeInsets.only(left: 20),
                    //           child: operation.info.add
                    //               ? (_periods == null
                    //                   ? SizedBox(
                    //                       width: ScreenUtil.instance
                    //                           .setWidth(50),
                    //                       height: ScreenUtil.instance
                    //                           .setWidth(50),
                    //                       child: CircularProgressIndicator(
                    //                         strokeWidth: 2,
                    //                       ),
                    //                     )
                    //                   : Row(children: <Widget>[
                    //                       DropdownButtonHideUnderline(
                    //                         child: DropdownButton(
                    //                           items:
                    //                               _periods.keys.map((name) {
                    //                             return new DropdownMenuItem(
                    //                               child: Row(
                    //                                 children: <Widget>[
                    //                                   new Text(
                    //                                       _periods[name]),
                    //                                   _period == name
                    //                                       ? Icon(
                    //                                           Icons
                    //                                               .arrow_left,
                    //                                           color:
                    //                                               Colors.blue,
                    //                                         )
                    //                                       : Container()
                    //                                 ],
                    //                               ),
                    //                               value: name,
                    //                             );
                    //                           }).toList(),
                    //                           iconSize: 18,
                    //                           hint: Text(
                    //                             _periods[_period],
                    //                           ),
                    //                           onChanged: (value) {
                    //                             setState(() {
                    //                               _period = value;
                    //                             });
                    //                             // _choose(_symbol, _type);
                    //                             Vibrate.feedback(
                    //                                 FeedbackType.light);
                    //                           },
                    //                         ),
                    //                       )
                    //                     ]))
                    //               : Text(
                    //                   operation.info.symbol,
                    //                   style: TextStyle(
                    //                       fontWeight: FontWeight.w500),
                    //                 )),
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: <Widget>[
                    //     Container(
                    //       margin: EdgeInsets.all(10),
                    //       child: Text("类型"),
                    //     ),
                    //     Expanded(
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //         children: <Widget>[
                    //           Row(
                    //             children: <Widget>[
                    //               Text("季度"),
                    //               IconButton(
                    //                   icon: Icon(
                    //                     _quarter
                    //                         ? Icons.check_box
                    //                         : Icons.check_box_outline_blank,
                    //                     color: _quarter
                    //                         ? Colors.blue
                    //                         : Colors.grey,
                    //                   ),
                    //                   onPressed: () {
                    //                     if (!operation.info.add) {
                    //                       update("quarter", !_quarter);
                    //                     }
                    //                     setState(() {
                    //                       _quarter = !_quarter;
                    //                     });
                    //                   })
                    //             ],
                    //           ),
                    //           Row(
                    //             children: <Widget>[
                    //               Text("本周"),
                    //               IconButton(
                    //                   icon: Icon(
                    //                     _thisWeek
                    //                         ? Icons.check_box
                    //                         : Icons.check_box_outline_blank,
                    //                     color: _thisWeek
                    //                         ? Colors.blue
                    //                         : Colors.grey,
                    //                   ),
                    //                   onPressed: () {
                    //                     if (!operation.info.add) {
                    //                       update("this_week", !_thisWeek);
                    //                     }
                    //                     setState(() {
                    //                       _thisWeek = !_thisWeek;
                    //                     });
                    //                   })
                    //             ],
                    //           ),
                    //           Row(
                    //             children: <Widget>[
                    //               Text("下周"),
                    //               IconButton(
                    //                   icon: Icon(
                    //                     _nextWeek
                    //                         ? Icons.check_box
                    //                         : Icons.check_box_outline_blank,
                    //                     color: _nextWeek
                    //                         ? Colors.blue
                    //                         : Colors.grey,
                    //                   ),
                    //                   onPressed: () {
                    //                     if (!operation.info.add) {
                    //                       update("next_week", !_nextWeek);
                    //                     }
                    //                     setState(() {
                    //                       _nextWeek = !_nextWeek;
                    //                     });
                    //                   })
                    //             ],
                    //           )
                    //         ],
                    //       ),
                    //     )
                    //   ],
                    // ),
                    // ]
                    // )
                    );
          })),
    );
  }
}
