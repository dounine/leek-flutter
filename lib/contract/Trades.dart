import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/ContractPage.dart';
import 'package:leek/components/cslider.dart';
import 'package:leek/store/ContractStore.dart';
import 'package:leek/store/SocketStore.dart';
import 'package:provider/provider.dart';

class Trades extends StatefulWidget {
  Trades({Key key}) : super(key: key);

  @override
  _TradesState createState() {
    return _TradesState();
  }
}

class _TradesState extends State<Trades> with SingleTickerProviderStateMixin {
  ContractInfo contractInfo;
  bool switchValue = true;
  AnimationController controller;
  Animation<Color> skeletonColor;
  CurvedAnimation curved;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        duration: const Duration(seconds: 1), lowerBound: 0.5, vsync: this);
    curved = new CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  _switchChange(bool value) {
    if (!value) {
      controller.stop();
    } else {
      controller.forward();
    }
    setState(() {
      switchValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    ContractStore _contractStore = Provider.of<ContractStore>(context);
    SocketStore socketStore = Provider.of<SocketStore>(context);
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    Widget skeleton = FadeTransition(
        opacity: curved,
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                child: Switch(
                  value: switchValue,
                  onChanged: _switchChange,
                ),
              ),
              Container(
                  padding: EdgeInsets.all(6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                              //人民币价格
                              margin: EdgeInsets.only(
                                left: 8,
                                top: 6,
                              ),
                              height: 16,
                              width: 104,
                              color: Colors.grey[300]),
                          Container(
                              //USDT价格
                              margin: EdgeInsets.only(top: 9, left: 6),
                              height: 14,
                              width: 60,
                              color: Colors.grey[300]),
                        ],
                      ),
                      Container(
                          //涨幅
                          height: 14,
                          width: 60,
                          color: Colors.grey[300])
                    ],
                  )),
              Container(
                margin: EdgeInsets.only(top: 10.0, left: 16),
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 10.0),
                      child: Container(
                          height: 24, width: 42, color: Colors.grey[300]),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 16.0),
                        child: Container(
                            height: 24, width: 42, color: Colors.grey[300])),
                    Container(
                        margin: EdgeInsets.only(left: 16.0),
                        child: Container(
                            height: 24, width: 42, color: Colors.grey[300]))
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                height: 10,
                color: Colors.grey[100],
              ),
              Container(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: Container(
                            //USDT价格
                            height: 38,
                            color: Colors.grey[300]),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 30,
                padding: EdgeInsets.only(
                  left: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(right: 10),
                            height: 20,
                            width: 20,
                            color: Colors.grey[300]),
                        Container(
                            margin: EdgeInsets.only(right: 10),
                            height: 20,
                            width: 20,
                            color: Colors.grey[300]),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                child: Expanded(
                    child: Column(
                  children: <Widget>[
                    Container(
                      height: 60,
                      child: Row(
                        children: <Widget>[
                          Container(
                              //文字信息
                              margin: EdgeInsets.only(left: 15, right: 15),
                              height: 18,
                              width: 30,
                              color: Colors.grey[300]),
                          Container(
                              //滑杆
                              height: 18,
                              width: 300,
                              color: Colors.grey[300])
                        ],
                      ),
                    ),
                    Container(
                      height: 60,
                      child: Row(
                        children: <Widget>[
                          Container(
                              //文字信息
                              margin: EdgeInsets.only(left: 15, right: 15),
                              height: 18,
                              width: 30,
                              color: Colors.grey[300]),
                          Container(
                              //滑杆
                              height: 18,
                              width: 300,
                              color: Colors.grey[300])
                        ],
                      ),
                    )
                  ],
                )),
              )
            ],
          ),
        ));

    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: ScreenUtil.instance.setHeight(60),
              padding: EdgeInsets.only(
                left: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Icon(Icons.fullscreen,
                            color: Colors.grey, size: 22),
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 10),
                        child:
                            Icon(Icons.settings, color: Colors.grey, size: 18),
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(Icons.lock_outline,
                            color: Colors.grey, size: 19),
                      )
                    ],
                  )
                ],
              ),
            ),
            Row(
              children: <Widget>[
                SizedBox(
                    width: ScreenUtil.instance.setWidth(126),
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "开仓",
                        style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                      ),
                    )),
                Switch(
                  value: _contractStore.open_enable,
                  onChanged: (bool value) {
                    _contractStore.open_enable = value;
                  },
                )
              ],
            ),
            Container(
              height: ScreenUtil.instance.setHeight(200),
              child: Row(
                children: <Widget>[
                  SizedBox(
                      width: ScreenUtil.instance.setWidth(160),
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "实时",
                          style:
                              TextStyle(color: Colors.blueGrey, fontSize: 16),
                        ),
                      )),
                  CustomliderWidget(
                    minValue: 0,
                    maxValue: 100,
                    defaultValue: 10,
                    setup: 1.0,
                    fixed: 2,
                    onChange: (double oldValue, double newValue) => {},
                  ),
                ],
              ),
            ),
            Container(
              height: ScreenUtil.instance.setHeight(160),
              child: Row(
                children: <Widget>[
                  SizedBox(
                      width: ScreenUtil.instance.setWidth(160),
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "反弹",
                          style:
                              TextStyle(color: Colors.blueGrey, fontSize: 16),
                        ),
                      )),
                  CustomliderWidget(
                    minValue: 0,
                    maxValue: 50,
                    defaultValue: _contractStore.open_rebound_price,
                    setup: 1.0,
                    fixed: 0,
                    onChange: (num oldValue, num newValue) {
                      _contractStore.open_rebound_price = newValue;
                      socketStore.sendMessage({
                        "type": "contract_update",
                        "data": {
                          "symbol": _contractStore.symbol,
                          "contractType": _contractStore.contractType,
                          "direction": _contractStore.direction,
                          "open_rebound_price": newValue.toString()
                        }
                      });
                    },
                  )
                ],
              ),
            ),
            Container(
              height: ScreenUtil.instance.setHeight(160),
              child: Row(
                children: <Widget>[
                  SizedBox(
                      width: ScreenUtil.instance.setWidth(160),
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "差价",
                          style:
                              TextStyle(color: Colors.blueGrey, fontSize: 16),
                        ),
                      )),
                  CustomliderWidget(
                    minValue: 0,
                    maxValue: 50,
                    defaultValue: _contractStore.open_plan_price_spread,
                    setup: 1.0,
                    fixed: 2,
                    onChange: (num oldValue, num newValue) {
                      _contractStore.open_plan_price_spread = newValue;
                      socketStore.sendMessage({
                        "type": "contract_update",
                        "data": {
                          "symbol": _contractStore.symbol,
                          "contractType": _contractStore.contractType,
                          "direction": _contractStore.direction,
                          "open_plan_price_spread": newValue.toString()
                        }
                      });
                    },
                  )
                ],
              ),
            ),
            Container(
              height: ScreenUtil.instance.setHeight(160),
              child: Row(
                children: <Widget>[
                  SizedBox(
                      width: ScreenUtil.instance.setWidth(160),
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "调度",
                          style:
                              TextStyle(color: Colors.blueGrey, fontSize: 16),
                        ),
                      )),
                  CustomliderWidget(
                    minValue: 0,
                    maxValue: 120,
                    defaultValue: _contractStore.open_schedue["length"],
                    setup: 1.0,
                    fixed: 0,
                    onChange: (num oldValue, num newValue) {
                      _contractStore.open_schedue = {
                        "length": newValue,
                        "unit": "seconds"
                      };
                      socketStore.sendMessage({
                        "type": "contract_update",
                        "data": {
                          "symbol": _contractStore.symbol,
                          "contractType": _contractStore.contractType,
                          "direction": _contractStore.direction,
                          "open_schedue": {
                            "length": newValue,
                            "unit": "seconds"
                          }
                        }
                      });
                    },
                  )
                ],
              ),
            ),
            Container(
              height: ScreenUtil.instance.setHeight(160),
              child: Row(
                children: <Widget>[
                  SizedBox(
                      width: ScreenUtil.instance.setWidth(160),
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "超时",
                          style:
                              TextStyle(color: Colors.blueGrey, fontSize: 16),
                        ),
                      )),
                  CustomliderWidget(
                    minValue: 1,
                    maxValue: 60,
                    defaultValue: _contractStore.open_entrust_timeout["length"],
                    setup: 1.0,
                    fixed: 0,
                    onChange: (num oldValue, num newValue) {
                      _contractStore.open_entrust_timeout = {
                        "length": newValue,
                        "unit": "seconds"
                      };
                      socketStore.sendMessage({
                        "type": "contract_update",
                        "data": {
                          "symbol": _contractStore.symbol,
                          "contractType": _contractStore.contractType,
                          "direction": _contractStore.direction,
                          "open_entrust_timeout": {
                            "length": newValue,
                            "unit": "seconds"
                          }
                        }
                      });
                    },
                  )
                ],
              ),
            ),
            Container(
              height: ScreenUtil.instance.setHeight(160),
              child: Row(
                children: <Widget>[
                  SizedBox(
                      width: ScreenUtil.instance.setWidth(160),
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "张数",
                          style:
                              TextStyle(color: Colors.blueGrey, fontSize: 16),
                        ),
                      )),
                  CustomliderWidget(
                    minValue: 1,
                    maxValue: 100,
                    defaultValue: _contractStore.open_volume,
                    fixed: 0,
                    setup: 1.0,
                    onChange: (num oldValue, num newValue) {
                      _contractStore.open_volume = newValue;
                      socketStore.sendMessage({
                        "type": "contract_update",
                        "data": {
                          "symbol": _contractStore.symbol,
                          "contractType": _contractStore.contractType,
                          "direction": _contractStore.direction,
                          "open_volume": newValue.toString()
                        }
                      });
                    },
                  )
                ],
              ),
            ),
            Container(
              height: ScreenUtil.instance.setHeight(100),
              child: Row(
                children: <Widget>[
                  SizedBox(
                      width: ScreenUtil.instance.setWidth(160),
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "杠杆",
                          style:
                              TextStyle(color: Colors.blueGrey, fontSize: 16),
                        ),
                      )),
                  Container(
                      width: ScreenUtil.instance.setWidth(880),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [1, 5, 10, 20].map((i) {
                          return Container(
                            child: Text(
                              "${i}倍",
                              style: TextStyle(
                                  fontWeight: i.toString() ==
                                          _contractStore.open_lever_rate
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            ),
                          );
                        }).toList(),
                      )),
                ],
              ),
            ),
            SizedBox(
              height: 20,
              child: Container(
                color: Colors.white,
              ),
            ),
            Row(
              children: <Widget>[
                SizedBox(
                    width: ScreenUtil.instance.setWidth(126),
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "绑定",
                        style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                      ),
                    )),
                Switch(
                  value: _contractStore.close_bind,
                  onChanged: (bool value) {
                    _contractStore.close_bind = value;
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
