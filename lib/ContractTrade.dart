import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/ContractPage.dart';
import 'package:leek/contract/Contrast.dart';
import 'package:leek/contract/Entrust.dart';
import 'package:leek/contract/Position.dart';
import 'package:leek/contract/Trades.dart';
import 'package:leek/store/ContractStore.dart';
import 'package:leek/store/SocketStore.dart';
import 'package:provider/provider.dart';
import 'package:vibrate/vibrate.dart';

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
  List<String> _socketMsg;
  String navName = "操盘";

//  ContractStore _contractStore;
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
    Vibrate.feedback(FeedbackType.light);
    controller = new AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this); //动画控制器
    curved = new CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    controller.forward();
    super.initState();
  }

  void onConnect() {
    Provider.of<SocketStore>(context)
        .sendMessage({"type": "sub", "channels": _socketMsg});
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

  void choose(ContractInfo contractInfo) async {
    ContractStore contractStore = Provider.of<ContractStore>(context);
    await contractStore.choose(contractInfo.symbol);
//    contractStore.initContract();
    _socketMsg = ["CONTRACT_${contractStore.symbol}_${contractStore.type}"];
    Provider.of<SocketStore>(context)
        .sendMessage({"type": "sub", "channels": _socketMsg});
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    final ContractInfo contractInfo = ModalRoute.of(context).settings.arguments;
    if (!contractInfo.quarterOpen) {
      _types.remove("quarter");
    }
    if (!contractInfo.thisWeekOpen) {
      _types.remove("this_week");
    }
    if (!contractInfo.nextWeekOpen) {
      _types.remove("next_week");
    }
    var appBar = new AppBar(
      title: Consumer<SocketStore>(
        builder: (context, socketStore, child) {
          return socketStore.status == SocketStatus.connected
              ? Text(
                  contractInfo.symbol,
                  style: TextStyle(color: Colors.white),
                )
              : const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white)),
                );
        },
      ),
    );
    ContractStore contractStore = Provider.of<ContractStore>(context);
    SocketStore socketStore = Provider.of<SocketStore>(context);
    if (null == pages) {
      choose(contractInfo);
      ContractStore contractStore = Provider.of<ContractStore>(context);
      contractStore.rise = contractInfo.rise;
      socketStore.addMsgListener("contract", contractStore.onMessage);
      pages = {
        "操盘": Trades(contractInfo: contractInfo),
        "委托": Entrust(),
        "持仓": Position(),
        "多空": Contrast()
      };
    }

    return WillPopScope(
        child: new Scaffold(
          appBar: appBar,
          body: Container(
            child: Column(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "￥${contractStore.cny}",
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 1000),
                              margin: EdgeInsets.only(left: 24),
                              child: Text(
                                contractStore.usdt,
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          ],
                        ),
                        Text(
                          "${contractStore.rise} %",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    )),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(10),
                ),
                Container(
                  margin:
                      EdgeInsets.only(left: ScreenUtil.instance.setWidth(20)),
                  child: Row(
                    children: _types
                        .map((key, value) {
                          return MapEntry(
                              key,
                              Container(
                                  child: Stack(
                                children: <Widget>[
                                  SizedBox(
                                    width: ScreenUtil.instance.setWidth(200),
                                    height: ScreenUtil.instance.setWidth(80),
                                    child: FlatButton(
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                              fontSize:
                                                  contractStore.type == key
                                                      ? 18
                                                      : 14,
                                              color: Colors.grey),
                                        ),
                                        onPressed: () {
                                          socketStore.sendMessage({
                                            "type": "unsub",
                                            "data": _socketMsg
                                          });
                                          contractStore.type = key;
                                          choose(contractInfo);
                                          Vibrate.feedback(FeedbackType.light);
                                          controller.reset();
                                          controller.forward();
                                        }),
                                  ),
                                  Positioned(
                                    right: ScreenUtil.instance.setWidth(22),
                                    bottom: ScreenUtil.instance.setWidth(4),
                                    child: FadeTransition(
                                      opacity: new Tween(begin: 0.0, end: 1.0)
                                          .animate(curved),
                                      child: Icon(
                                        Icons.brightness_1,
                                        size: ScreenUtil.instance.setWidth(24),
                                        color: contractStore.type == key
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
                  height: ScreenUtil.instance.setHeight(20),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 44,
                  decoration: ShapeDecoration(
//                color: Colors.white,
                    shape: Border(bottom: BorderSide(color: Colors.grey[100])),
                  ),
                  child: Row(
                      children: pages.keys.map((name) {
                    return Expanded(
                        child: Container(
                      height: 44,
                      child: FlatButton(
                        textColor:
                            navName == name ? Colors.black87 : Colors.grey,
                        onPressed: () {
                          setState(() {
                            navName = name;
                          });
                          Vibrate.feedback(FeedbackType.light);
                        },
                        child: Text(name,
                            style:
                                TextStyle(fontSize: navName == name ? 18 : 14)),
                      ),
                    ));
                  }).toList()),
                ),
                Expanded(child: pages[navName])
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: contractStore.direction == "buy" ? 0 : 1,
            onTap: (index) {
              contractStore.direction = (index == 0 ? "buy" : "sell");
              choose(contractInfo);
              Vibrate.feedback(FeedbackType.light);
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
          Navigator.pop(context, _socketMsg);
          return false;
        });
  }
}
