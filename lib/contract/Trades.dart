import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/ContractPage.dart';
import 'package:leek/components/cslider.dart';
import 'package:leek/components/cslider2.dart';
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
    controller.dispose();
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
              height: 100,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
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
                              child: Icon(Icons.settings,
                                  color: Colors.grey, size: 18),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                                width: ScreenUtil.instance.setWidth(126),
                                child: Container(
                                  margin: EdgeInsets.only(left: 10),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "开仓",
                                    style: TextStyle(
                                        color: Colors.blueGrey, fontSize: 16),
                                  ),
                                )),
                            Switch(
                              value: contractStore.open_enable,
                              onChanged: (bool value) {
                                contractStore.open_enable = value;
                              },
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 40),
                        child: Text(contractStore.open_status),
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
                                style: TextStyle(
                                    color: Colors.blueGrey, fontSize: 16),
                              ),
                            )),
                        CustomliderWidget2(
                          minValue: 0,
                          maxValue: 100,
                          defaultValue: contractStore.openTradeValue,
                          setup: 1.0,
                          fixed: 2,
                          onChange: (double oldValue, double newValue) => {},
                          eventName: "onlineTradePrice",
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
                                "反弹",
                                style: TextStyle(
                                    color: Colors.blueGrey, fontSize: 16),
                              ),
                            )),
                        CustomliderWidget(
                          minValue: 0,
                          maxValue: 50,
                          defaultValue: contractStore.open_rebound_price,
                          setup: 1.0,
                          fixed: 0,
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
                                style: TextStyle(
                                    color: Colors.blueGrey, fontSize: 16),
                              ),
                            )),
                        CustomliderWidget(
                          minValue: 0,
                          maxValue: 50,
                          defaultValue: contractStore.open_plan_price_spread,
                          setup: 1.0,
                          fixed: 2,
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
                                style: TextStyle(
                                    color: Colors.blueGrey, fontSize: 16),
                              ),
                            )),
                        CustomliderWidget(
                          minValue: 0,
                          maxValue: 120,
                          defaultValue: contractStore.open_schedue["length"],
                          setup: 1.0,
                          fixed: 0,
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
                                style: TextStyle(
                                    color: Colors.blueGrey, fontSize: 16),
                              ),
                            )),
                        CustomliderWidget(
                          minValue: 1,
                          maxValue: 60,
                          defaultValue:
                              contractStore.open_entrust_timeout["length"],
                          setup: 1.0,
                          fixed: 0,
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
                                style: TextStyle(
                                    color: Colors.blueGrey, fontSize: 16),
                              ),
                            )),
                        CustomliderWidget(
                          minValue: 1,
                          maxValue: 100,
                          defaultValue: contractStore.open_volume,
                          fixed: 0,
                          setup: 1.0,
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
                                style: TextStyle(
                                    color: Colors.blueGrey, fontSize: 16),
                              ),
                            )),
                        Container(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [1, 5, 10, 20].map((i) {
                            return Container(
                              child: FlatButton(
                                child: Text(
                                  "${i}倍",
                                  style: TextStyle(
                                      color: i.toString() ==
                                              contractStore.open_lever_rate
                                          ? Colors.black
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
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
                              style: TextStyle(
                                  color: Colors.blueGrey, fontSize: 16),
                            ),
                          )),
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
                  )
                ],
              ),
            ),
    );
  }
}
