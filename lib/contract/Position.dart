import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/util/ScaffoldUtil.dart';

class PositionOrder {
  final String direction;
  final String contract_type;
  final num cost_hold;
  final num cost_open;
  final num frozen;
  final num last_price;
  final num lever_rate;
  final num position_margin;
  final num profit;
  final num profit_rate;
  final num profit_unreal;
  final num volume;
  final num available;

  PositionOrder(
      this.direction,
      this.contract_type,
      this.cost_hold,
      this.cost_open,
      this.frozen,
      this.last_price,
      this.lever_rate,
      this.position_margin,
      this.profit,
      this.profit_rate,
      this.profit_unreal,
      this.volume,
      this.available);
}

class Position extends StatefulWidget {
  final String symbol;
  final String contractType;
  final String direction;

  Position(
      {Key key,
      @required this.symbol,
      @required this.contractType,
      @required this.direction})
      : super(key: key);

  @override
  _PositionState createState() {
    return _PositionState();
  }
}

class _PositionState extends State<Position> {
  String _reqStatus = "";
  String symbol;
  String contractType;
  String direction;
  List<PositionOrder> _list;

  @override
  void initState() {
    symbol = widget.symbol;
    contractType = widget.contractType;
    direction = widget.direction;
    query();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future lightningClose(num volumn,Function fun) async {
    try {
      setState(() {
        _reqStatus = "request";
      });
      Response response = await Config.dio.post(
          "/contract/position/lightning_close/${symbol}/${contractType}/${direction}/${volumn}");
      Map<String, dynamic> data = response.data;
      if (data["status"] == "ok") {
        setState(() {
          _reqStatus = data["status"];
        });
        query();
        HapticFeedback.lightImpact();
      } else {
        setState(() {
          _reqStatus = data["status"];
        });
        HapticFeedback.mediumImpact();
        Future.delayed(Duration.zero, () {
          ScaffoldUtil.show(_context, data);
        });
      }
      if(fun!=null){
        fun(data["status"]);
      }
    } catch (e) {
      print(e);
      setState(() {
        _reqStatus = "timeout";
      });
      HapticFeedback.heavyImpact();
      Future.delayed(Duration.zero, () {
        ScaffoldUtil.show(_context, {"status": "timeout"});
      });
    }
  }

  Future query() async {
    try {
      setState(() {
        _reqStatus = "request";
        _list = null;
      });
      Response response = await Config.dio
          .get("/contract/position/${symbol}/${contractType}/${direction}");
      Map<String, dynamic> data = response.data;
      if (data["status"] == "ok") {
        List<dynamic> orders = data["data"];
        List<PositionOrder> limitOrders = orders.map((item) {
          return PositionOrder(
            item["direction"],
            item["contract_type"],
            item["cost_hold"],
            item["cost_open"],
            item["frozen"],
            item["last_price"],
            item["lever_rate"],
            item["position_margin"],
            item["profit"],
            item["profit_rate"],
            item["profit_unreal"],
            item["volume"],
            item["available"],
          );
        }).toList();
        setState(() {
          _reqStatus = data["status"];
          _list = limitOrders;
        });
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.mediumImpact();
        setState(() {
          _reqStatus = data["status"];
        });
        Future.delayed(Duration.zero, () {
          ScaffoldUtil.show(_context, data);
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _reqStatus = "timeout";
      });
      HapticFeedback.heavyImpact();
      Future.delayed(Duration.zero, () {
        ScaffoldUtil.show(_context, {"status": "timeout"});
      });
    }
  }

  Future<Null> _refresh() async {
    await query();
    return;
  }

  BuildContext _context;

  Widget getRow(int index) {
    PositionOrder limitOrder = _list[index];
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  limitOrder.direction == "buy" ? "多" : "空",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  "·",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  "${limitOrder.lever_rate}X",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "|",
                    style: TextStyle(
                        color: Colors.grey[200],
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  (limitOrder.profit_rate * 100).toStringAsFixed(2) + "%",
                  style: TextStyle(
                      color: limitOrder.profit_rate >= 0
                          ? Colors.green
                          : Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  "(收益率)",
                  style: TextStyle(color: Colors.grey),
                )
              ],
            ),
            Container(
              child: IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    query();
                  }),
            )
          ],
        ),
        SizedBox(
          height: ScreenUtil.instance.setHeight(30),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "持仓量(张)",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(10),
                ),
                Text(limitOrder.volume.toString(),
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(30),
                ),
                Text(
                  "可平量(张)",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(10),
                ),
                Text(limitOrder.available.toString(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
              ],
            ),
            Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "开仓均价(USD)",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(10),
                ),
                Text(limitOrder.cost_open.toStringAsFixed(2),
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(30),
                ),
                Text(
                  "持仓均价(USD)",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(10),
                ),
                Text(limitOrder.cost_hold.toStringAsFixed(2),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  "收益(BTC)",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(10),
                ),
                Text(
                  limitOrder.profit.toStringAsFixed(4),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(30),
                ),
                Text(
                  "保证金(BTC)",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(10),
                ),
                Text(
                  limitOrder.position_margin.toStringAsFixed(4),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                )
              ],
            )
          ],
        ),
        SizedBox(
          height: ScreenUtil.instance.setHeight(30),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                color: Colors.grey[200],
                child: Text(
                  "平仓",
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () {},
              ),
            ),
            SizedBox(
              width: ScreenUtil.instance.setWidth(30),
            ),
            Expanded(
              child: FlatButton(
                color: Colors.grey[200],
                child: Text(
                  "闪电平仓",
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: Text('闪电平仓提示'),
                        content: Text("确定要以最优30档闪电平仓么?"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('取消'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: Text('确定'),
                            onPressed: () {
                              lightningClose(limitOrder.volume,(String status){
                                Navigator.of(context).pop();
                              });
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        )
      ],
    );
  }

  BuildContext cc;

  @override
  Widget build(BuildContext context) {
    cc = context;
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    return new Builder(builder: (c) {
      _context = c;
      return SingleChildScrollView(
        child: _list == null
            ? (_reqStatus == "timeout"
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Text("您的网络不给力、刷新重试"),
                        IconButton(
                            icon: Icon(Icons.refresh, color: Colors.blue),
                            onPressed: () {
                              query();
                            })
                      ])
                : Padding(
                    padding: EdgeInsets.all(ScreenUtil.instance.setWidth(200)),
                    child: Center(child: CircularProgressIndicator()),
                  ))
            : (_list.length == 0)
                ? Center(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: ScreenUtil.instance.setHeight(80),
                        ),
                        Icon(
                          Icons.inbox,
                          size: 36,
                          color: Colors.black12,
                        ),
                        Text(
                          "当前没有持仓",
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        )
                      ],
                    ),
                  )
                : Container(
                    child: new ListView.separated(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: _list.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(
                              height: 1,
                            ),
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: ScreenUtil.instance.setWidth(20)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtil.instance.setWidth(30)),
                              child: getRow(index));
                        }),
                  ),
      );
    });
  }
}
