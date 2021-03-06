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

  BuildContext bc;

  void sub(bool open) async {
    ContractStore contractStore = Provider.of<ContractStore>(bc);
    await contractStore.choose(contractStore.symbol);
    List<dynamic> _socketMsg = [
      {
        "type": "contract",
        "json":
            '{"symbol":"${contractStore.symbol}","contractType":"${contractStore.contractType}","direction":"${contractStore.direction}","offset":"${open ? 'open' : 'close'}"}'
      }
    ];
    Provider.of<SocketStore>(context)
        .sendMessage({"type": "sub", "channels": _socketMsg});
  }

  void navSetting(String keyName) {
    HapticFeedback.lightImpact();
    ConfigInfo configInfo =
        configs.where((item) => item.keyName == keyName).toList()[0];
    Navigator.pushNamed(context, '/config-edit',
            arguments: ConfigInfo(
                configInfo.keyName,
                configInfo.minValue,
                configInfo.maxValue,
                configInfo.defaultValue,
                configInfo.fixed,
                configInfo.name,
                configInfo.setup,
                configInfo.symbol,
                user: true))
        .then((result) {
      ConfigInfo configInfo = result;
      List<ConfigInfo> list = [];
      configs.forEach((item) {
        if (item.keyName == configInfo.keyName) {
          list.add(configInfo);
        } else {
          list.add(item);
        }
      });
      setState(() {
        configs = list;
      });
    });
  }

  void choose(bool open) async {
    ContractStore contractStore = Provider.of<ContractStore>(bc);
    List<dynamic> unsub = [
      {
        "type": "contract",
        "json":
            '{"symbol":"${contractStore.symbol}","contractType":"${contractStore.contractType}","direction":"${contractStore.direction}","offset":"${contractStore.open_switch ? 'open' : 'close'}"}'
      }
    ];
    Provider.of<SocketStore>(context)
        .sendMessage({"type": "unsub", "channels": unsub});
    contractStore.open_switch = open;
    sub(open);
  }

  ConfigInfo getInfo(String keyName) {
    return configs.where((item) => item.keyName == keyName).toList().isEmpty
        ? ConfigInfo("", 0, 100, 0, 0, "", 1, "")
        : configs.where((item) => item.keyName == keyName).toList()[0];
  }

  @override
  Widget build(BuildContext context) {
    bc = context;
    ContractStore contractStore = Provider.of<ContractStore>(context);
    SocketStore socketStore = Provider.of<SocketStore>(context);
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);

    ConfigInfo open_online = getInfo("open_online");
    ConfigInfo open_rebound_price = getInfo("open_rebound_price");
    ConfigInfo open_plan_price_spread = getInfo("open_plan_price_spread");
    ConfigInfo open_schedue = getInfo("open_schedue");
    ConfigInfo open_entrust_timeout = getInfo("open_entrust_timeout");
    ConfigInfo open_volume = getInfo("open_volume");
    ConfigInfo close_online = getInfo("close_online");
    ConfigInfo close_rebound_price = getInfo("close_rebound_price");
    ConfigInfo close_plan_price_spread = getInfo("close_plan_price_spread");
    ConfigInfo close_entrust_timeout = getInfo("close_entrust_timeout");
    ConfigInfo close_volume = getInfo("close_volume");
    ConfigInfo close_boarding = getInfo("close_boarding");

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
                  child: Icon(
                    Icons.vpn_key,
                    color: Colors.blueGrey,
                  )),
              Switch(
                value: contractStore.open_enable,
                onChanged: contractStore.locked
                    ? null
                    : (bool value) {
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
        padding:
            EdgeInsets.symmetric(vertical: ScreenUtil.instance.setHeight(60)),
        child: Row(
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(
                    left: ScreenUtil.instance.setWidth(30),
                    right: ScreenUtil.instance.setWidth(50)),
                child: GestureDetector(
                  child: Icon(
                    Icons.traffic,
                    color: Colors.blueGrey,
                  ),
                  onTap: () {
                    navSetting("open_online");
                  },
                )),
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
                : new Consumer<ContractStore>(builder: (context, cs, child) {
                    return CustomliderWidget2(
                      key: ObjectKey("online_open_trade_price"),
                      splits: 3,
                      touch: !cs.locked,
                      width: ScreenUtil.instance.setWidth(860),
                      minValue: open_online.minValue,
                      maxValue: open_online.maxValue,
                      defaultValue1: cs.openEntrustValue,
                      defaultValue2: cs.openTradeValue,
                      setup: open_online.setup,
                      fixed: open_online.fixed,
                      eventName:
                          "online_open_entrust_price,online_open_trade_price",
                      onChange: (double oldValue, double newValue) {
                        cs.openEntrustValue = newValue;
                        socketStore.sendMessage({
                          "type": "contract_update",
                          "data": {
                            "symbol": cs.symbol,
                            "contractType": cs.contractType,
                            "direction": cs.direction,
                            "open_plan_price": (newValue + cs.openInitPrice)
                                .toStringAsFixed(open_online.fixed)
                          }
                        });
                      },
                    );
                  })
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
                child: GestureDetector(
                  onTap: () {
                    navSetting("open_rebound_price");
                  },
                  child: Icon(
                    Icons.directions_car,
                    color: Colors.blueGrey,
                  ),
                )),
            new Consumer<ContractStore>(builder: (context, cs, child) {
              return CustomliderWidget(
                key: ObjectKey("open_rebound_price"),
                splits: 3,
                touch: !cs.locked,
                width: ScreenUtil.instance.setWidth(860),
                minValue: open_rebound_price.minValue,
                maxValue: open_rebound_price.maxValue,
                defaultValue: cs.open_rebound_price,
                setup: open_rebound_price.setup,
                fixed: open_rebound_price.fixed,
                eventName: "open_rebound_price",
                animation: false,
                onChange: (num oldValue, num newValue) {
                  contractStore.open_rebound_price = double.parse(
                      newValue.toStringAsFixed(open_rebound_price.fixed));
                  socketStore.sendMessage({
                    "type": "contract_update",
                    "data": {
                      "symbol": cs.symbol,
                      "contractType": cs.contractType,
                      "direction": cs.direction,
                      "open_rebound_price":
                          newValue.toStringAsFixed(open_rebound_price.fixed)
                    }
                  });
                },
              );
            })
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
                child: GestureDetector(
                    onTap: () {
                      navSetting("open_plan_price_spread");
                    },
                    child: Icon(Icons.ev_station, color: Colors.blueGrey))),
            new Consumer<ContractStore>(builder: (context, cs, child) {
              return CustomliderWidget(
                key: ObjectKey("open_plan_price_spread"),
                splits: 3,
                touch: !cs.locked,
                width: ScreenUtil.instance.setWidth(860),
                minValue: open_plan_price_spread.minValue,
                maxValue: open_plan_price_spread.maxValue,
                defaultValue: cs.open_plan_price_spread,
                setup: open_plan_price_spread.setup,
                fixed: open_plan_price_spread.fixed,
                eventName: "open_plan_price_spread",
                animation: false,
                onChange: (num oldValue, num newValue) {
                  contractStore.open_plan_price_spread = double.parse(
                      newValue.toStringAsFixed(open_plan_price_spread.fixed));
                  socketStore.sendMessage({
                    "type": "contract_update",
                    "data": {
                      "symbol": cs.symbol,
                      "contractType": cs.contractType,
                      "direction": cs.direction,
                      "open_plan_price_spread":
                          newValue.toStringAsFixed(open_plan_price_spread.fixed)
                    }
                  });
                },
              );
            })
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
              child: GestureDetector(
                onTap: () {
                  navSetting("open_schedue");
                },
                child: Icon(
                  Icons.schedule,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            new Consumer<ContractStore>(builder: (context, cs, child) {
              return CustomliderWidget(
                key: ObjectKey("open_schedue"),
                splits: 3,
                touch: !cs.locked,
                width: ScreenUtil.instance.setWidth(860),
                minValue: open_schedue.minValue,
                maxValue: open_schedue.maxValue,
                defaultValue: cs.open_schedue["length"],
                setup: open_schedue.setup,
                fixed: open_schedue.fixed,
                eventName: "open_schedue",
                onChange: (num oldValue, num newValue) {
                  contractStore.open_schedue = {
                    "length": newValue.toInt(),
                    "unit": "seconds"
                  };
                  socketStore.sendMessage({
                    "type": "contract_update",
                    "data": {
                      "symbol": cs.symbol,
                      "contractType": cs.contractType,
                      "direction": cs.direction,
                      "open_schedue": {
                        "length": newValue.toInt(),
                        "unit": "seconds"
                      }
                    }
                  });
                },
              );
            })
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
                child: GestureDetector(
                  onTap: () {
                    navSetting("open_entrust_timeout");
                  },
                  child: Icon(
                    Icons.av_timer,
                    color: Colors.blueGrey,
                  ),
                )
//              Text(
//                "超时",
//                style: TextStyle(color: Colors.blueGrey),
//              ),
                ),
            new Consumer<ContractStore>(builder: (context, cs, child) {
              return CustomliderWidget(
                key: ObjectKey("open_entrust_timeout"),
                splits: 3,
                touch: !cs.locked,
                width: ScreenUtil.instance.setWidth(860),
                minValue: open_entrust_timeout.minValue,
                maxValue: open_entrust_timeout.maxValue,
                defaultValue: cs.open_entrust_timeout["length"],
                setup: open_entrust_timeout.setup,
                fixed: open_entrust_timeout.fixed,
                eventName: "open_entrust_timeout",
                onChange: (num oldValue, num newValue) {
                  contractStore.open_entrust_timeout = {
                    "length": newValue.toInt(),
                    "unit": "seconds"
                  };
                  socketStore.sendMessage({
                    "type": "contract_update",
                    "data": {
                      "symbol": cs.symbol,
                      "contractType": cs.contractType,
                      "direction": cs.direction,
                      "open_entrust_timeout": {
                        "length": newValue.toInt(),
                        "unit": "seconds"
                      }
                    }
                  });
                },
              );
            })
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
                child: GestureDetector(
                  onTap: () {
                    navSetting("open_volume");
                  },
                  child: Icon(
                    Icons.local_gas_station,
                    color: Colors.blueGrey,
                  ),
                )),
            new Consumer<ContractStore>(builder: (context, cs, child) {
              return CustomliderWidget(
                key: ObjectKey("open_volume"),
                splits: 3,
                touch: !cs.locked,
                width: ScreenUtil.instance.setWidth(860),
                minValue: open_volume.minValue,
                maxValue: open_volume.maxValue,
                defaultValue: cs.open_volume,
                fixed: open_volume.fixed,
                setup: open_volume.setup,
                eventName: "open_volume",
                onChange: (num oldValue, num newValue) {
                  contractStore.open_volume = newValue.toInt();
                  socketStore.sendMessage({
                    "type": "contract_update",
                    "data": {
                      "symbol": cs.symbol,
                      "contractType": cs.contractType,
                      "direction": cs.direction,
                      "open_volume": newValue.toInt()
                    }
                  });
                },
              );
            })
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
                child: Icon(Icons.sort, color: Colors.blueGrey)),
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
                      if (contractStore.open_enable == false &&
                          !contractStore.locked) {
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
                      }
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
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(
                      left: ScreenUtil.instance.setWidth(30),
                      right: ScreenUtil.instance.setWidth(30)),
                  child: Icon(
                    Icons.rv_hookup,
                    color: Colors.blueGrey,
                  )),
              Switch(
                value: contractStore.close_bind,
                onChanged: true
                    ? null
                    : (bool value) {
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
          Row(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(
                      left: ScreenUtil.instance.setWidth(30),
                      right: ScreenUtil.instance.setWidth(30)),
                  child: Icon(
                    Icons.accessible_forward,
                    color: Colors.blueGrey,
                  )),
              contractStore.close_getoff == null
                  ? Text(
                      "--",
                      style: TextStyle(color: Colors.grey),
                    )
                  : Switch(
                      value: contractStore.close_getoff == null
                          ? false
                          : contractStore.close_getoff,
                      onChanged: true
                          ? null
                          : (bool value) {
                              contractStore.close_bind = value;
                              socketStore.sendMessage({
                                "type": "contract_update",
                                "data": {
                                  "symbol": contractStore.symbol,
                                  "contractType": contractStore.contractType,
                                  "direction": contractStore.direction,
                                  "close_getoff": value
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
      Container(
        padding:
            EdgeInsets.symmetric(vertical: ScreenUtil.instance.setHeight(60)),
        child: Row(
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(
                    left: ScreenUtil.instance.setWidth(30),
                    right: ScreenUtil.instance.setWidth(50)),
                child: GestureDetector(
                  onTap: () {
                    navSetting("close_online");
                  },
                  child: Icon(
                    Icons.traffic,
                    color: Colors.blueGrey,
                  ),
                )),
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
                : new Consumer<ContractStore>(
                    builder: (context, cs, child) {
                      return CustomliderWidget2(
                        key: ObjectKey("online_close_trade_price"),
                        splits: 3,
                        touch: !cs.locked,
                        width: ScreenUtil.instance.setWidth(860),
                        minValue: close_online.minValue,
                        maxValue: close_online.maxValue,
                        defaultValue1: cs.closeEntrustValue,
                        defaultValue2: cs.closeTradeValue,
                        setup: close_online.setup,
                        fixed: close_online.fixed,
                        eventName:
                            "online_close_entrust_price,online_close_trade_price",
                        onChange: (double oldValue, double newValue) {
                          cs.closeEntrustValue = newValue;
                          socketStore.sendMessage({
                            "type": "contract_update",
                            "data": {
                              "symbol": cs.symbol,
                              "contractType": cs.contractType,
                              "direction": cs.direction,
                              "close_plan_price": (newValue + cs.closeInitPrice)
                                  .toStringAsFixed(close_online.fixed)
                            }
                          });
                        },
                      );
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
                child: GestureDetector(
                  onTap: () {
                    navSetting("close_rebound_price");
                  },
                  child: Icon(
                    Icons.directions_car,
                    color: Colors.blueGrey,
                  ),
                )),
            new Consumer<ContractStore>(builder: (context, cs, child) {
              return CustomliderWidget(
                key: ObjectKey("close_rebound_price"),
                splits: 3,
                touch: !cs.locked,
                width: ScreenUtil.instance.setWidth(860),
                minValue: close_rebound_price.minValue,
                maxValue: close_rebound_price.maxValue,
                defaultValue: cs.close_rebound_price,
                setup: close_rebound_price.setup,
                fixed: close_rebound_price.fixed,
                eventName: "close_rebound_price",
                onChange: (num oldValue, num newValue) {
                  contractStore.close_rebound_price = double.parse(
                      newValue.toStringAsFixed(close_rebound_price.fixed));
                  socketStore.sendMessage({
                    "type": "contract_update",
                    "data": {
                      "symbol": cs.symbol,
                      "contractType": cs.contractType,
                      "direction": cs.direction,
                      "close_rebound_price":
                          newValue.toStringAsFixed(close_rebound_price.fixed)
                    }
                  });
                },
              );
            })
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
                child: GestureDetector(
                    onTap: () {
                      navSetting("close_plan_price_spread");
                    },
                    child: Icon(Icons.ev_station, color: Colors.blueGrey))),
            new Consumer<ContractStore>(builder: (context, cs, child) {
              return CustomliderWidget(
                key: ObjectKey("close_plan_price_spread"),
                splits: 3,
                touch: !cs.locked,
                width: ScreenUtil.instance.setWidth(860),
                minValue: close_plan_price_spread.minValue,
                maxValue: close_plan_price_spread.maxValue,
                defaultValue: cs.close_plan_price_spread,
                setup: close_plan_price_spread.setup,
                fixed: close_plan_price_spread.fixed,
                eventName: "close_plan_price_spread",
                onChange: (num oldValue, num newValue) {
                  contractStore.close_plan_price_spread = double.parse(
                      newValue.toStringAsFixed(close_plan_price_spread.fixed));
                  socketStore.sendMessage({
                    "type": "contract_update",
                    "data": {
                      "symbol": cs.symbol,
                      "contractType": cs.contractType,
                      "direction": cs.direction,
                      "close_plan_price_spread": newValue
                          .toStringAsFixed(close_plan_price_spread.fixed)
                    }
                  });
                },
              );
            })
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
                child: GestureDetector(
                  onTap: () {
                    navSetting("close_boarding");
                  },
                  child: Icon(
                    Icons.local_taxi,
                    color: Colors.blueGrey,
                  ),
                )),
            new Consumer<ContractStore>(builder: (context, cs, child) {
              return CustomliderWidget(
                key: ObjectKey("close_boarding"),
                splits: 3,
                touch: !cs.locked,
                width: ScreenUtil.instance.setWidth(860),
                minValue: close_boarding.minValue,
                maxValue: close_boarding.maxValue,
                defaultValue: cs.close_boarding,
                setup: close_boarding.setup,
                fixed: close_boarding.fixed,
                eventName: "close_boarding",
                onChange: (num oldValue, num newValue) {
                  contractStore.close_boarding = double.parse(
                      newValue.toStringAsFixed(close_boarding.fixed));
                  socketStore.sendMessage({
                    "type": "contract_update",
                    "data": {
                      "symbol": cs.symbol,
                      "contractType": cs.contractType,
                      "direction": cs.direction,
                      "close_boarding":
                          newValue.toStringAsFixed(close_boarding.fixed)
                    }
                  });
                },
              );
            })
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
                child: GestureDetector(
                  onTap: () {
                    navSetting("close_entrust_timeout");
                  },
                  child: Icon(
                    Icons.av_timer,
                    color: Colors.blueGrey,
                  ),
                )),
            new Consumer<ContractStore>(builder: (context, cs, child) {
              return CustomliderWidget(
                key: ObjectKey("close_entrust_timeout"),
                touch: !cs.locked,
                splits: 3,
                width: ScreenUtil.instance.setWidth(860),
                minValue: close_entrust_timeout.minValue,
                maxValue: close_entrust_timeout.maxValue,
                defaultValue: cs.close_entrust_timeout["length"],
                setup: close_entrust_timeout.setup,
                fixed: close_entrust_timeout.fixed,
                eventName: "close_entrust_timeout",
                onChange: (num oldValue, num newValue) {
                  contractStore.close_entrust_timeout = {
                    "length": newValue.toInt(),
                    "unit": "seconds"
                  };
                  socketStore.sendMessage({
                    "type": "contract_update",
                    "data": {
                      "symbol": cs.symbol,
                      "contractType": cs.contractType,
                      "direction": cs.direction,
                      "close_entrust_timeout": {
                        "length": newValue.toInt(),
                        "unit": "seconds"
                      }
                    }
                  });
                },
              );
            })
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
                child: Icon(
                  Icons.local_gas_station,
                  color: Colors.blueGrey,
                )),
            new Consumer<ContractStore>(builder: (context, cs, child) {
              return CustomliderWidget(
                key: ObjectKey("close_volume"),
                touch: false,
                splits: 3,
                width: ScreenUtil.instance.setWidth(860),
                minValue: close_volume.minValue,
                maxValue: close_volume.maxValue,
                defaultValue: cs.close_volume,
                fixed: close_volume.fixed,
                setup: close_volume.setup,
                eventName: "close_volume",
                onChange: (num oldValue, num newValue) {
                  contractStore.close_volume = newValue;
                  socketStore.sendMessage({
                    "type": "contract_update",
                    "data": {
                      "symbol": cs.symbol,
                      "contractType": cs.contractType,
                      "direction": cs.direction,
                      "close_volume": newValue.toString()
                    }
                  });
                },
              );
            })
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
                child: Icon(
                  Icons.attach_money,
                  color: Colors.blueGrey,
                )),
            new Consumer<ContractStore>(builder: (context, cs, child) {
              return Text(cs.close_profit);
            })
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
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
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
                        icon: Icon(
                            contractStore.locked == true
                                ? Icons.lock_outline
                                : Icons.lock_open,
                            size: 22),
                        onPressed: () {
                          contractStore.locked = !contractStore.locked;
                        },
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin:
                    EdgeInsets.only(right: ScreenUtil.instance.setWidth(20)),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      color:
                          contractStore.open_switch ? Colors.blue : Colors.grey,
                      icon: Icon(Icons.invert_colors),
                      onPressed: () {
                        choose(true);
                      },
                    ),
                    IconButton(
                      color: !contractStore.open_switch
                          ? Colors.blue
                          : Colors.grey,
                      icon: Icon(Icons.invert_colors_off),
                      onPressed: () {
                        choose(false);
                      },
                    ),
                    IconButton(
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
                  ],
                ),
              ),
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
            : new Consumer<ContractStore>(builder: (context, cs, child) {
                return cs.open_switch
                    ? Column(children: openWidgets)
                    : Column(children: closeWidgets);
              })
      ],
    ));
  }
}
