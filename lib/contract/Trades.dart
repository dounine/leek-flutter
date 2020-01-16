import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/ContractPage.dart';
import 'package:leek/components/cslider.dart';
import 'package:leek/components/cslider2.dart';
import 'package:leek/store/ContractStore.dart';
import 'package:leek/store/SocketStore.dart';
import 'package:provider/provider.dart';

class Trades extends StatefulWidget {
  final List<ConfigInfo> configs;
  Trades({Key key, @required this.configs}) : super(key: key);

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
  List<ConfigInfo> configs;
  bool openIcon = true;

  @override
  void initState() {
    configs = widget.configs;
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
    HapticFeedback.selectionClick();
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

    ConfigInfo notFound = ConfigInfo("", 0, 100, 0, 0, "", 1, "");

    ConfigInfo open_online =
        configs.where((item) => item.keyName == "open_online").toList()[0] ??
            notFound;
    ConfigInfo open_rebound_price = configs
            .where((item) => item.keyName == "open_rebound_price")
            .toList()[0] ??
        notFound;
    ConfigInfo open_plan_price_spread = configs
            .where((item) => item.keyName == "open_plan_price_spread")
            .toList()[0] ??
        notFound;
    ConfigInfo open_schedue =
        configs.where((item) => item.keyName == "open_schedue").toList()[0] ??
            notFound;
    ConfigInfo open_entrust_timeout = configs
            .where((item) => item.keyName == "open_entrust_timeout")
            .toList()[0] ??
        notFound;
    ConfigInfo open_volume =
        configs.where((item) => item.keyName == "open_volume").toList()[0] ??
            notFound;
    ConfigInfo close_online =
        configs.where((item) => item.keyName == "close_online").toList()[0] ??
            notFound;
    ConfigInfo close_rebound_price = configs
            .where((item) => item.keyName == "close_rebound_price")
            .toList()[0] ??
        notFound;
    ConfigInfo close_plan_price_spread = configs
            .where((item) => item.keyName == "close_plan_price_spread")
            .toList()[0] ??
        notFound;
    ConfigInfo close_entrust_timeout = configs
            .where((item) => item.keyName == "close_entrust_timeout")
            .toList()[0] ??
        notFound;
    ConfigInfo close_volume =
        configs.where((item) => item.keyName == "close_volume").toList()[0] ??
            notFound;

    List<Widget> openWidgets = [
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
                  "运行",
                  style: TextStyle(color: Colors.blueGrey),
                ),
              ),
              Switch(
                value: contractStore.open_enable,
                onChanged: (bool value) {
                  contractStore.open_enable = value;
                  socketStore.sendMessage({
                  "type": "contract_update",
                  "data": {
                    "symbol": contractStore.symbol,
                    "contractType": contractStore.contractType,
                    "direction": contractStore.direction,
                    "open_enable": value
                  }
                });
                },
              )
            ],
          ),
          Container(
            padding: EdgeInsets.only(right: ScreenUtil.instance.setWidth(60)),
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
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : CustomliderWidget2(
                    splits: 3,
                    width: ScreenUtil.instance.setWidth(860),
                    minValue: open_online.minValue,
                    maxValue: open_online.maxValue,
                    defaultValue1: contractStore.openEntrustValue,
                    defaultValue2: contractStore.openTradeValue,
                    setup: open_online.setup,
                    fixed: open_online.fixed,
                    eventName:
                        "online_open_entrust_price,online_open_trade_price",
                    onChange: (double oldValue, double newValue){
                      print(newValue);
                    },
                  )
          ],
        ),
      ),
      Container(
        padding:
            EdgeInsets.symmetric(vertical: ScreenUtil.instance.setHeight(80)),
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
              splits: 3,
              width: ScreenUtil.instance.setWidth(860),
              minValue: open_rebound_price.minValue,
              maxValue: open_rebound_price.maxValue,
              defaultValue: contractStore.open_rebound_price,
              setup: open_rebound_price.setup,
              fixed: open_rebound_price.fixed,
              eventName: "open_rebound_price",
              animation: false,
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
        padding:
            EdgeInsets.symmetric(vertical: ScreenUtil.instance.setHeight(60)),
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
              splits: 3,
              width: ScreenUtil.instance.setWidth(860),
              minValue: open_plan_price_spread.minValue,
              maxValue: open_plan_price_spread.maxValue,
              defaultValue: contractStore.open_plan_price_spread,
              setup: open_plan_price_spread.setup,
              fixed: open_plan_price_spread.fixed,
              eventName: "open_plan_price_spread",
              animation: false,
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
        padding:
            EdgeInsets.symmetric(vertical: ScreenUtil.instance.setHeight(60)),
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
              splits: 3,
              width: ScreenUtil.instance.setWidth(860),
              minValue: open_schedue.minValue,
              maxValue: open_schedue.maxValue,
              defaultValue: contractStore.open_schedue["length"],
              setup: open_schedue.setup,
              fixed: open_schedue.fixed,
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
                    "open_schedue": {"length": newValue, "unit": "seconds"}
                  }
                });
              },
            )
          ],
        ),
      ),
      Container(
        padding:
            EdgeInsets.symmetric(vertical: ScreenUtil.instance.setHeight(60)),
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
              splits: 3,
              width: ScreenUtil.instance.setWidth(860),
              minValue: open_entrust_timeout.minValue,
              maxValue: open_entrust_timeout.maxValue,
              defaultValue: contractStore.open_entrust_timeout["length"],
              setup: open_entrust_timeout.setup,
              fixed: open_entrust_timeout.fixed,
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
        padding:
            EdgeInsets.symmetric(vertical: ScreenUtil.instance.setHeight(60)),
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
              splits: 3,
              width: ScreenUtil.instance.setWidth(860),
              minValue: open_volume.minValue,
              maxValue: open_volume.maxValue,
              defaultValue: contractStore.open_volume,
              fixed: open_volume.fixed,
              setup: open_volume.setup,
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
                          color: i == contractStore.open_lever_rate
                              ? Colors.black
                              : Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      contractStore.open_lever_rate = i;
                      socketStore.sendMessage({
                        "type": "contract_update",
                        "data": {
                          "symbol": contractStore.symbol,
                          "contractType": contractStore.contractType,
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
    ];

    List<Widget> closeWidgets = [
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
              padding: EdgeInsets.only(right: ScreenUtil.instance.setWidth(60)),
              child: Text(contractStore.close_status),
            )
          ],
        ),
      ),
      Container(
        padding:
            EdgeInsets.symmetric(vertical: ScreenUtil.instance.setHeight(60)),
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
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : CustomliderWidget2(
                    splits: 3,
                    width: ScreenUtil.instance.setWidth(860),
                    minValue: close_online.minValue,
                    maxValue: close_online.maxValue,
                    defaultValue1: contractStore.closeEntrustValue,
                    defaultValue2: contractStore.closeTradeValue,
                    setup: close_online.setup,
                    fixed: close_online.fixed,
                    eventName:
                        "online_close_entrust_price,online_close_trade_price",
                    onChange: (double oldValue, double newValue) => {},
                  )
          ],
        ),
      ),
      Container(
        padding:
            EdgeInsets.symmetric(vertical: ScreenUtil.instance.setHeight(60)),
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
              splits: 3,
              width: ScreenUtil.instance.setWidth(860),
              minValue: close_rebound_price.minValue,
              maxValue: close_rebound_price.maxValue,
              defaultValue: contractStore.close_rebound_price,
              setup: close_rebound_price.setup,
              fixed: close_rebound_price.fixed,
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
        padding:
            EdgeInsets.symmetric(vertical: ScreenUtil.instance.setHeight(60)),
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
              splits: 3,
              width: ScreenUtil.instance.setWidth(860),
              minValue: close_plan_price_spread.minValue,
              maxValue: close_plan_price_spread.maxValue,
              defaultValue: contractStore.close_plan_price_spread,
              setup: close_plan_price_spread.setup,
              fixed: close_plan_price_spread.fixed,
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
        padding:
            EdgeInsets.symmetric(vertical: ScreenUtil.instance.setHeight(60)),
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
              splits: 3,
              width: ScreenUtil.instance.setWidth(860),
              minValue: close_entrust_timeout.minValue,
              maxValue: close_entrust_timeout.maxValue,
              defaultValue: contractStore.close_entrust_timeout["length"],
              setup: close_entrust_timeout.setup,
              fixed: close_entrust_timeout.fixed,
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
        padding:
            EdgeInsets.symmetric(vertical: ScreenUtil.instance.setHeight(60)),
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
              splits: 3,
              width: ScreenUtil.instance.setWidth(860),
              minValue: close_volume.minValue,
              maxValue: close_volume.maxValue,
              defaultValue: contractStore.close_volume,
              fixed: close_volume.fixed,
              setup: close_volume.setup,
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
    ];

    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: 10,
            bottom: 10,
            left: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    color: openIcon ? Colors.blue : Colors.grey,
                    icon: Icon(Icons.invert_colors),
                    onPressed: () {
                      setState(() {
                        openIcon = true;
                        Future.delayed(new Duration(milliseconds: 100), () {
                          Config.eventBus.fire(PushEvent(
                              "online_open_trade_price",
                              contractStore.openTradeValue));
                          Config.eventBus.fire(PushEvent("open_rebound_price",
                              contractStore.open_rebound_price));
                          Config.eventBus.fire(PushEvent(
                              "open_plan_price_spread",
                              contractStore.open_plan_price_spread));
                          Config.eventBus.fire(PushEvent(
                              "open_volume", contractStore.open_volume));
                          Config.eventBus.fire(PushEvent("open_schedue",
                              contractStore.open_schedue["length"]));
                          Config.eventBus.fire(PushEvent("open_entrust_timeout",
                              contractStore.open_entrust_timeout["length"]));
                        });
                      });
                    },
                  ),
                  IconButton(
                    color: !openIcon ? Colors.blue : Colors.grey,
                    icon: Icon(Icons.invert_colors_off),
                    onPressed: () {
                      setState(() {
                        openIcon = false;
                        Future.delayed(new Duration(milliseconds: 100), () {
                          Config.eventBus.fire(PushEvent(
                              "online_close_trade_price",
                              contractStore.closeTradeValue));
                          Config.eventBus.fire(PushEvent("close_rebound_price",
                              contractStore.close_rebound_price));
                          Config.eventBus.fire(PushEvent(
                              "close_plan_price_spread",
                              contractStore.close_plan_price_spread));
                          Config.eventBus.fire(PushEvent(
                              "close_volume", contractStore.close_volume));
                          Config.eventBus.fire(PushEvent("close_schedue",
                              contractStore.close_schedue["length"]));
                          Config.eventBus.fire(PushEvent(
                              "close_entrust_timeout",
                              contractStore.close_entrust_timeout["length"]));
                        });
                      });
                    },
                  )
                ],
              ),
              Container(
                margin:
                    EdgeInsets.only(right: ScreenUtil.instance.setWidth(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    SizedBox(
                      width: ScreenUtil.instance.setWidth(100),
                      child: IconButton(
                        color: Colors.black54,
                        icon: Icon(
                            contractStore.screen
                                ? Icons.fullscreen_exit
                                : Icons.fullscreen,
                            size: 22),
                        onPressed: () {
                          contractStore.screen = !contractStore.screen;
                        },
                      ),
                    ),
                    SizedBox(
                      width: ScreenUtil.instance.setWidth(100),
                      child: IconButton(
                        color: Colors.black54,
                        icon: Icon(Icons.settings, size: 22),
                        onPressed: () {},
                      ),
                    ),
                    SizedBox(
                      width: ScreenUtil.instance.setWidth(100),
                      child: IconButton(
                        color: Colors.black54,
                        icon: Icon(Icons.lock_outline, size: 22),
                        onPressed: () {},
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        !contractStore.push_info
            ? Container(
                padding: EdgeInsets.all(ScreenUtil.instance.setWidth(200)),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Column(
                children: openIcon ? openWidgets : closeWidgets,
              )
      ],
    ));
  }
}
