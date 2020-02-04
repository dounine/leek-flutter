import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:leek/ContractOpen.dart';
import 'package:leek/ContractPage.dart';
import 'package:leek/contract/Entrust.dart';
import 'package:leek/contract/Position.dart';
import 'package:leek/contract/Trades.dart';
import 'package:leek/store/ContractStore.dart';
import 'package:leek/store/SocketStore.dart';
import 'package:provider/provider.dart';

class ContractTrade extends StatefulWidget {
  const ContractTrade({Key key}) : super(key: key);

  @override
  _ContractTradeState createState() {
    return _ContractTradeState();
  }
}

class _ContractTradeState extends State<ContractTrade>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Map<String, Widget> pages;
  PageView pageView;
  String navName = "操盘";
  ContractInfo contractInfo;
  List<dynamic> socketMsg;
  AnimationController controller;
  CurvedAnimation curved;
  Map<String, String> _types = {
    "quarter": "季度",
    "this_week": "当周",
    "next_week": "次周"
  };

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    controller = new AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this); //动画控制器
    curved = new CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    Future.delayed(Duration.zero, () {
      Provider.of<SocketStore>(context)
          .addConnectedListener("contract", this.onConnect);
    });
    controller.forward();
    super.initState();
  }

  void onConnect() {
    ContractStore contractStore = Provider.of<ContractStore>(context);
//    contractStore.push_info = false;
    socketMsg = [
      {
        "type": "contract",
        "json":
            '{"symbol":"${contractStore.symbol}","contractType":"${contractStore.contractType}","direction":"${contractStore.direction}","offset":"${contractStore.open_switch ? 'open' : 'close'}"}'
      }
    ];
    var hasOpen = contractInfo.opens
        .where((item) =>
            item.contractType == contractStore.contractType &&
            item.direction == contractStore.direction)
        .isNotEmpty;
    if (hasOpen) {
      Provider.of<SocketStore>(context)
          .sendMessage({"type": "sub", "channels": socketMsg});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Provider.of<SocketStore>(context)
            .addConnectedListener("contract", this.onConnect);
        print('应用程序可见并响应用户输入。');
        break;
      case AppLifecycleState.inactive:
        print('应用程序处于非活动状态，并且未接收用户输入');
        break;
      case AppLifecycleState.paused:
        print('用户当前看不到应用程序，没有响应');
        break;
      case AppLifecycleState.detached:
        print('应用程序将暂停。');
        break;
      default:
        print("其它");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void choose(ContractInfo contractInfo, String nname) async {
    ContractStore contractStore = Provider.of<ContractStore>(context);
    await contractStore.choose(contractInfo.symbol);
    socketMsg = [
      {
        "type": "contract",
        "json":
            '{"symbol":"${contractStore.symbol}","contractType":"${contractStore.contractType}","direction":"${contractStore.direction}","offset":"${contractStore.open_switch ? 'open' : 'close'}"}'
      }
    ];
    var hasOpen = contractInfo.opens
        .where((item) =>
            item.contractType == contractStore.contractType &&
            item.direction == contractStore.direction)
        .isNotEmpty;
    if (hasOpen) {
      Provider.of<SocketStore>(context)
          .sendMessage({"type": "sub", "channels": socketMsg});
    }
    if (nname != null) {
      setState(() {
        navName = nname;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    contractInfo = ModalRoute.of(context).settings.arguments;
    ContractStore contractStore = Provider.of<ContractStore>(context);
    SocketStore socketStore = Provider.of<SocketStore>(context);
    if (pages == null) {
      choose(contractInfo, null);
      ContractStore contractStore = Provider.of<ContractStore>(context);
      socketStore.addMsgListener("contract", contractStore.onMessage);
      pages = {
        "操盘": Trades(configs: contractInfo.configs),
        "委托": Entrust(),
        "持仓": Position(
          symbol: contractStore.symbol,
          contractType: contractStore.contractType,
          direction: contractStore.direction,
        )
      };
    }

    var hasOpen = contractInfo.opens
        .where((item) =>
            item.contractType == contractStore.contractType &&
            item.direction == contractStore.direction)
        .isNotEmpty;

    return WillPopScope(
        child: new Scaffold(
          appBar: new AppBar(
            actions: [
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: ScreenUtil.instance.setWidth(30)),
                child: contractStore.screen
                    ? (Icon(contractStore.direction == "buy"
                        ? Icons.trending_up
                        : Icons.trending_down))
                    : Container(),
              )
            ],
            title: Consumer<SocketStore>(
              builder: (context, socketStore, child) {
                return socketStore.status == SocketStatus.connected
                    ? Container(
                        width: ScreenUtil.instance.setWidth(170),
                        child: Row(
                          children: <Widget>[
                            SvgPicture.asset(
                                "images/${contractInfo.symbol.toLowerCase()}.svg",
                                width: ScreenUtil.instance.setWidth(50),
                                height: ScreenUtil.instance.setWidth(50),
                                semanticsLabel: contractInfo.symbol),
                            SizedBox(
                              width: ScreenUtil.instance.setWidth(10),
                            ),
                            Text(
                              contractInfo.symbol,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: ScreenUtil.instance.setWidth(50),
                        width: ScreenUtil.instance.setWidth(50),
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white)),
                      );
              },
            ),
          ),
          body: Container(
            child: Column(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(ScreenUtil.instance.setWidth(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              left: ScreenUtil.instance.setWidth(20)),
                          child: Column(
                            children: <Widget>[
                              Consumer<ContractStore>(
                                  builder: (context, cs, child) {
                                return cs.screen
                                    ? Container()
                                    : Container(
                                        width:
                                            ScreenUtil.instance.setWidth(300),
                                        child: Text(
                                          contractStore.cny == ""
                                              ? "--"
                                              : contractStore.cny,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      );
                              }),
                              Container(
                                width: ScreenUtil.instance.setWidth(300),
                                child: Text(
                                  contractStore.usdt == ""
                                      ? "--"
                                      : contractStore.usdt,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            ],
                          ),
                        ),
                        Text(
                          "${contractStore.rise} %",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    )),
                Consumer<ContractStore>(builder: (context, cs, child) {
                  return cs.screen
                      ? Container()
                      : Column(
                          children: <Widget>[
                            SizedBox(
                              height: ScreenUtil.instance.setHeight(10),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  left: ScreenUtil.instance.setWidth(20)),
                              child: Row(
                                children: _types
                                    .map((key, value) {
                                      return MapEntry(
                                          key,
                                          Container(
                                              child: Stack(
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: ScreenUtil.instance
                                                        .setWidth(20)),
                                                child: Container(
                                                  width: ScreenUtil.instance
                                                      .setWidth(150),
                                                  margin: EdgeInsets.all(
                                                      ScreenUtil.instance
                                                          .setWidth(10)),
                                                  child: GestureDetector(
                                                    child: Text(
                                                      value,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: contractStore
                                                                      .contractType ==
                                                                  key
                                                              ? Colors.black
                                                              : Colors.grey),
                                                    ),
                                                    onTap: () {
                                                      socketStore.sendMessage({
                                                        "type": "unsub",
                                                        "channels": socketMsg
                                                      });
                                                      contractStore
                                                          .contractType = key;
                                                      choose(
                                                          contractInfo, null);
                                                      HapticFeedback
                                                          .selectionClick();
                                                      controller.reset();
                                                      controller.forward();
                                                    },
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                right: ScreenUtil.instance
                                                    .setWidth(22),
                                                bottom: ScreenUtil.instance
                                                    .setWidth(4),
                                                child: FadeTransition(
                                                  opacity: new Tween(
                                                          begin: 0.0, end: 1.0)
                                                      .animate(curved),
                                                  child: Icon(
                                                    Icons.brightness_1,
                                                    size: ScreenUtil.instance
                                                        .setWidth(24),
                                                    color: contractStore
                                                                .contractType ==
                                                            key
                                                        ? Colors.lightBlueAccent
                                                        : Colors.transparent,
                                                  ),
                                                ),
                                              )
                                            ],
                                          )));
                                    })
                                    .values
                                    .toList(),
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil.instance.setHeight(40),
                            ),
                            hasOpen
                                ? Container(
                                    height: ScreenUtil.instance.setHeight(80),
                                    decoration: ShapeDecoration(
                                      shape: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey[100])),
                                    ),
                                    child: Row(
                                        children: pages.keys.map((name) {
                                      return Expanded(
                                        child: FlatButton(
                                          textColor: navName == name
                                              ? Colors.black87
                                              : Colors.grey,
                                          onPressed: () {
                                            setState(() {
                                              navName = name;
                                            });
                                            HapticFeedback.selectionClick();
                                          },
                                          child: Text(name,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                      );
                                    }).toList()),
                                  )
                                : Container(),
                          ],
                        );
                }),
                hasOpen
                    ? Expanded(
                        child: navName == "持仓"
                            ? new Position(
                                symbol: contractStore.symbol,
                                contractType: contractStore.contractType,
                                direction: contractStore.direction,
                              )
                            : pages[navName],
                      )
                    : new ContractOpen(contractStore.symbol,
                        contractStore.contractType, contractStore.direction)
              ],
            ),
          ),
          bottomNavigationBar: contractStore.screen
              ? null
              : BottomNavigationBar(
                  currentIndex: contractStore.direction == "buy" ? 0 : 1,
                  onTap: (index) {
                    contractStore.direction = (index == 0 ? "buy" : "sell");
                    choose(contractInfo, "操盘");
                    HapticFeedback.selectionClick();
                  },
                  items: const <BottomNavigationBarItem>[
                    const BottomNavigationBarItem(
                        icon: Icon(Icons.trending_up), title: Text("追涨")),
                    const BottomNavigationBarItem(
                        icon: Icon(Icons.trending_down), title: Text("杀跌")),
                  ],
                ),
        ),
        onWillPop: () async {
          ContractStore contractStore = Provider.of<ContractStore>(context);
          var hasOpen = contractInfo.opens
              .where((item) =>
                  item.contractType == contractStore.contractType &&
                  item.direction == contractStore.direction)
              .isNotEmpty;
          List<dynamic> socketMsg = [
            {
              "type": "contract",
              "json":
                  '{"symbol":"${contractStore.symbol}","contractType":"${contractStore.contractType}","direction":"${contractStore.direction}","offset":"${contractStore.open_switch ? 'open' : 'close'}"}'
            }
          ];
          Navigator.pop(context, socketMsg);
          return false;
        });
  }
}
