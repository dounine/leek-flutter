import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/ContractPage.dart';
import 'package:leek/components/cslider.dart';
import 'package:leek/components/cslider2.dart';
import 'package:leek/store/ContractStore.dart';
import 'package:leek/store/SocketStore.dart';
import 'package:provider/provider.dart';
import 'package:vibrate/vibrate.dart';

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
    super.initState();
  }

  @override
  void dispose() {
    controller?.stop();
    controller?.dispose();
    super.dispose();
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
    ContractStore contractStore = Provider.of<ContractStore>(context);
    SocketStore socketStore = Provider.of<SocketStore>(context);
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    return SingleChildScrollView(
      child: !contractStore.push_info
          ? Container(
              margin: EdgeInsets.all(ScreenUtil.instance.setWidth(40)),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                      left: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: ScreenUtil.instance.setWidth(260),
                          margin: EdgeInsets.only(
                            right: ScreenUtil.instance.setWidth(40),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Icon(Icons.fullscreen,
                                  color: Colors.grey, size: 22),
                              Icon(Icons.settings,
                                  color: Colors.grey, size: 18),
                              Icon(Icons.lock_outline,
                                  color: Colors.grey, size: 19),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                                left: ScreenUtil.instance.setWidth(30),
                                right: ScreenUtil.instance.setWidth(30)),
                            child: Text(
                              "开仓",
                              style: TextStyle(color: Colors.blueGrey),
                            ),
                          ),
                          Switch(
                            value: contractStore.open_enable,
                            onChanged: (bool value) {
                              contractStore.open_enable = value;
                            },
                          )
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            right: ScreenUtil.instance.setWidth(60)),
                        child: Text(contractStore.open_status),
                      )
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 30, bottom: 30),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                              left: ScreenUtil.instance.setWidth(30),
                              right: ScreenUtil.instance.setWidth(50)),
                          child: Text(
                            "实时",
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                        contractStore.openTradeValue == -1
                            ? Expanded(
                                child: Center(
                                  child: SizedBox(
                                    height: ScreenUtil.instance.setWidth(50),
                                    width: ScreenUtil.instance.setWidth(50),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                              )
                            : CustomliderWidget2(
                                width: ScreenUtil.instance.setWidth(860),
                                minValue: 0,
                                maxValue: 100,
                                defaultValue1: contractStore.openEntrustValue,
                                defaultValue2: contractStore.openTradeValue,
                                setup: 1.0,
                                fixed: 2,
                                eventName:
                                    "online_open_entrust_price,online_open_trade_price",
                                onChange: (double oldValue, double newValue) =>
                                    {},
                              )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil.instance.setHeight(80)),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                              left: ScreenUtil.instance.setWidth(30),
                              right: ScreenUtil.instance.setWidth(50)),
                          child: Text(
                            "反弹",
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                        CustomliderWidget(
                          width: ScreenUtil.instance.setWidth(860),
                          minValue: 0,
                          maxValue: 50,
                          defaultValue: contractStore.open_rebound_price,
                          setup: 1.0,
                          fixed: 0,
                          eventName: "open_rebound_price",
                          onChange: (num oldValue, num newValue) {
                            contractStore.open_rebound_price = newValue;
                            socketStore.sendMessage({
                              "type": "contract_update",
                              "data": {
                                "symbol": contractStore.symbol,
                                "contractType": contractStore.contractType,
                                "direction": contractStore.direction,
                                "open_rebound_price": newValue.toString()
                              }
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil.instance.setHeight(60)),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                              left: ScreenUtil.instance.setWidth(30),
                              right: ScreenUtil.instance.setWidth(50)),
                          child: Text(
                            "差价",
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                        CustomliderWidget(
                          width: ScreenUtil.instance.setWidth(860),
                          minValue: 0,
                          maxValue: 50,
                          defaultValue: contractStore.open_plan_price_spread,
                          setup: 1.0,
                          fixed: 2,
                          eventName: "open_plan_price_spread",
                          onChange: (num oldValue, num newValue) {
                            contractStore.open_plan_price_spread = newValue;
                            socketStore.sendMessage({
                              "type": "contract_update",
                              "data": {
                                "symbol": contractStore.symbol,
                                "contractType": contractStore.contractType,
                                "direction": contractStore.direction,
                                "open_plan_price_spread": newValue.toString()
                              }
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil.instance.setHeight(60)),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                              left: ScreenUtil.instance.setWidth(30),
                              right: ScreenUtil.instance.setWidth(50)),
                          child: Text(
                            "调度",
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                        CustomliderWidget(
                          width: ScreenUtil.instance.setWidth(860),
                          minValue: 0,
                          maxValue: 120,
                          defaultValue: contractStore.open_schedue["length"],
                          setup: 1.0,
                          fixed: 0,
                          eventName: "open_schedue",
                          onChange: (num oldValue, num newValue) {
                            contractStore.open_schedue = {
                              "length": newValue,
                              "unit": "seconds"
                            };
                            socketStore.sendMessage({
                              "type": "contract_update",
                              "data": {
                                "symbol": contractStore.symbol,
                                "contractType": contractStore.contractType,
                                "direction": contractStore.direction,
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
                    padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil.instance.setHeight(60)),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                              left: ScreenUtil.instance.setWidth(30),
                              right: ScreenUtil.instance.setWidth(50)),
                          child: Text(
                            "超时",
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                        CustomliderWidget(
                          width: ScreenUtil.instance.setWidth(860),
                          minValue: 1,
                          maxValue: 60,
                          defaultValue:
                              contractStore.open_entrust_timeout["length"],
                          setup: 1.0,
                          fixed: 0,
                          eventName: "open_entrust_timeout",
                          onChange: (num oldValue, num newValue) {
                            contractStore.open_entrust_timeout = {
                              "length": newValue,
                              "unit": "seconds"
                            };
                            socketStore.sendMessage({
                              "type": "contract_update",
                              "data": {
                                "symbol": contractStore.symbol,
                                "contractType": contractStore.contractType,
                                "direction": contractStore.direction,
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
                    padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil.instance.setHeight(60)),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                              left: ScreenUtil.instance.setWidth(30),
                              right: ScreenUtil.instance.setWidth(50)),
                          child: Text(
                            "张数",
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                        CustomliderWidget(
                          width: ScreenUtil.instance.setWidth(860),
                          minValue: 1,
                          maxValue: 100,
                          defaultValue: contractStore.open_volume,
                          fixed: 0,
                          setup: 1.0,
                          eventName: "open_volume",
                          onChange: (num oldValue, num newValue) {
                            contractStore.open_volume = newValue;
                            socketStore.sendMessage({
                              "type": "contract_update",
                              "data": {
                                "symbol": contractStore.symbol,
                                "contractType": contractStore.contractType,
                                "direction": contractStore.direction,
                                "open_volume": newValue.toString()
                              }
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: ScreenUtil.instance.setHeight(30),
                        bottom: ScreenUtil.instance.setHeight(60)),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                              left: ScreenUtil.instance.setWidth(30),
                              right: ScreenUtil.instance.setWidth(50)),
                          child: Text(
                            "杠杆",
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                        Container(
                          width: ScreenUtil.instance.setWidth(860),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [1, 5, 10, 20].map((i) {
                              return GestureDetector(
                                child: Text(
                                  "${i}倍",
                                  style: TextStyle(
                                      color: i.toString() ==
                                              contractStore.open_lever_rate
                                          ? Colors.black
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                                onTap: () {
                                  Vibrate.feedback(FeedbackType.selection);
                                  contractStore.open_lever_rate = i.toString();
                                  socketStore.sendMessage({
                                    "type": "contract_update",
                                    "data": {
                                      "symbol": contractStore.symbol,
                                      "contractType":
                                          contractStore.contractType,
                                      "direction": contractStore.direction,
                                      "open_lever_rate": i.toString()
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  new Divider(
                    height: 1,
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: ScreenUtil.instance.setHeight(30),
                        bottom: ScreenUtil.instance.setHeight(30)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(
                                  left: ScreenUtil.instance.setWidth(30),
                                  right: ScreenUtil.instance.setWidth(30)),
                              child: Text(
                                "绑定",
                                style: TextStyle(color: Colors.blueGrey),
                              ),
                            ),
                            Switch(
                              value: contractStore.close_bind,
                              onChanged: (bool value) {
                                contractStore.close_bind = value;
                                socketStore.sendMessage({
                                  "type": "contract_update",
                                  "data": {
                                    "symbol": contractStore.symbol,
                                    "contractType": contractStore.contractType,
                                    "direction": contractStore.direction,
                                    "close_bind": value
                                  }
                                });
                              },
                            )
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              right: ScreenUtil.instance.setWidth(60)),
                          child: Text(contractStore.close_status),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil.instance.setHeight(60)),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                              left: ScreenUtil.instance.setWidth(30),
                              right: ScreenUtil.instance.setWidth(50)),
                          child: Text(
                            "实时",
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                        contractStore.closeTradeValue == -1
                            ? Expanded(
                                child: Center(
                                  child: SizedBox(
                                    height: ScreenUtil.instance.setWidth(50),
                                    width: ScreenUtil.instance.setWidth(50),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                              )
                            : CustomliderWidget2(
                                width: ScreenUtil.instance.setWidth(860),
                                minValue: 0,
                                maxValue: 100,
                                defaultValue1: contractStore.closeEntrustValue,
                                defaultValue2: contractStore.closeTradeValue,
                                setup: 1.0,
                                fixed: 2,
                                eventName:
                                    "online_close_entrust_price,online_close_trade_price",
                                onChange: (double oldValue, double newValue) =>
                                    {},
                              )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil.instance.setHeight(60)),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                              left: ScreenUtil.instance.setWidth(30),
                              right: ScreenUtil.instance.setWidth(50)),
                          child: Text(
                            "反弹",
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                        CustomliderWidget(
                          width: ScreenUtil.instance.setWidth(860),
                          minValue: 0,
                          maxValue: 50,
                          defaultValue: contractStore.close_rebound_price,
                          setup: 1.0,
                          fixed: 0,
                          eventName: "close_rebound_price",
                          onChange: (num oldValue, num newValue) {
                            contractStore.close_rebound_price = newValue;
                            socketStore.sendMessage({
                              "type": "contract_update",
                              "data": {
                                "symbol": contractStore.symbol,
                                "contractType": contractStore.contractType,
                                "direction": contractStore.direction,
                                "close_rebound_price": newValue.toString()
                              }
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil.instance.setHeight(60)),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                              left: ScreenUtil.instance.setWidth(30),
                              right: ScreenUtil.instance.setWidth(50)),
                          child: Text(
                            "差价",
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                        CustomliderWidget(
                          width: ScreenUtil.instance.setWidth(860),
                          minValue: 0,
                          maxValue: 50,
                          defaultValue: contractStore.close_plan_price_spread,
                          setup: 1.0,
                          fixed: 2,
                          eventName: "close_plan_price_spread",
                          onChange: (num oldValue, num newValue) {
                            contractStore.close_plan_price_spread = newValue;
                            socketStore.sendMessage({
                              "type": "contract_update",
                              "data": {
                                "symbol": contractStore.symbol,
                                "contractType": contractStore.contractType,
                                "direction": contractStore.direction,
                                "close_plan_price_spread": newValue.toString()
                              }
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil.instance.setHeight(60)),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                              left: ScreenUtil.instance.setWidth(30),
                              right: ScreenUtil.instance.setWidth(50)),
                          child: Text(
                            "超时",
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                        CustomliderWidget(
                          width: ScreenUtil.instance.setWidth(860),
                          minValue: 1,
                          maxValue: 60,
                          defaultValue:
                              contractStore.close_entrust_timeout["length"],
                          setup: 1.0,
                          fixed: 0,
                          eventName: "close_entrust_timeout",
                          onChange: (num oldValue, num newValue) {
                            contractStore.close_entrust_timeout = {
                              "length": newValue,
                              "unit": "seconds"
                            };
                            socketStore.sendMessage({
                              "type": "contract_update",
                              "data": {
                                "symbol": contractStore.symbol,
                                "contractType": contractStore.contractType,
                                "direction": contractStore.direction,
                                "close_entrust_timeout": {
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
                    padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil.instance.setHeight(60)),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                              left: ScreenUtil.instance.setWidth(30),
                              right: ScreenUtil.instance.setWidth(50)),
                          child: Text(
                            "张数",
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                        CustomliderWidget(
                          width: ScreenUtil.instance.setWidth(860),
                          minValue: 1,
                          maxValue: 100,
                          defaultValue: contractStore.close_volume,
                          fixed: 0,
                          setup: 1.0,
                          eventName: "close_volume",
                          onChange: (num oldValue, num newValue) {
                            contractStore.close_volume = newValue;
                            socketStore.sendMessage({
                              "type": "contract_update",
                              "data": {
                                "symbol": contractStore.symbol,
                                "contractType": contractStore.contractType,
                                "direction": contractStore.direction,
                                "close_volume": newValue.toString()
                              }
                            });
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
