import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/util/ScaffoldUtil.dart';

class LimitOrder {
  final String offset; //方向
  final String order_id_str; //定单id
  final String order_source; //定单源
  final int status; //状态 3未成交 4部分成交 5部分成交已撤单 6全部成交 7已撤单
  final num price; //价格
  final num volume; //数量
  final String time; //时间
  final String direction;
  final int lever_rate; //杠杆倍数
  final num margin_frozen; //冻结资金
  final num trade_volume; //成交量
  final num trade_avg_price;
  final num fee;

  LimitOrder(
      this.offset,
      this.order_id_str,
      this.order_source,
      this.status,
      this.price,
      this.volume,
      this.time,
      this.lever_rate,
      this.margin_frozen,
      this.direction,
      this.trade_volume,
      this.trade_avg_price,
      this.fee);
}

class LimitEntrust extends StatefulWidget {
  final String symbol;
  final String contractType;
  LimitEntrust({Key key, @required this.symbol, @required this.contractType})
      : super(key: key);

  @override
  _LimitEntrustState createState() {
    return _LimitEntrustState();
  }
}

class _LimitEntrustState extends State<LimitEntrust> {
  String _reqStatus = "";
  String symbol;
  String contractType;
  List<LimitOrder> _list;

  @override
  void initState() {
    symbol = widget.symbol;
    contractType = widget.contractType;
    query();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future cancel(String orderId) async {
    try {
      setState(() {
        _reqStatus = "request";
      });
      Response response = await Config.dio
          .delete("/contract/entrust/cancel/limit/${symbol}/${orderId}");
      Map<String, dynamic> data = response.data;
      if (data["status"] == "ok") {
        setState(() {
          _reqStatus = data["status"];
          _list = _list.where((item) {
            return item.order_id_str != orderId;
          }).toList();
        });
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
      });
      Response response = await Config.dio
          .get("/contract/entrust/limit/${symbol}/${contractType}");
      Map<String, dynamic> data = response.data;
      print(data);
      if (data["status"] == "ok") {
        Map<String, dynamic> dataMap = data["data"];
        List<dynamic> orders = dataMap["orders"];
        List<LimitOrder> limitOrders = orders.map((item) {
          return LimitOrder(
            item["offset"],
            item["order_id_str"],
            item["order_source"],
            item["status"],
            item["price"],
            item["volume"],
            item["time"],
            item["lever_rate"],
            item["margin_frozen"],
            item["direction"],
            item["trade_volume"],
            item["trade_avg_price"],
            item["fee"],
          );
        }).toList();
        setState(() {
          _reqStatus = data["status"];
          _list = limitOrders;
        });
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
    LimitOrder limitOrder = _list[index];
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  limitOrder.offset == "open" ? "开" : "平",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  limitOrder.direction == "buy" ? "多" : "空",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  "·",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  "${limitOrder.lever_rate}X",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: ScreenUtil.instance.setWidth(40),
                ),
                Text(
                  limitOrder.time,
                  style: TextStyle(color: Colors.grey),
                )
              ],
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: ScreenUtil.instance.setWidth(180),
                  maxHeight: ScreenUtil.instance.setHeight(60)),
              child: FlatButton(
                color: Colors.grey[200],
                child: Text(
                  "撤销",
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () {
                  cancel(limitOrder.order_id_str);
                },
              ),
            ),
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
                  "委托量(张)",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(10),
                ),
                Text(limitOrder.volume.toString(),
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(16),
                ),
                Text(
                  "成交量(张)",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(10),
                ),
                Text(limitOrder.trade_volume.toString(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "委托价(USD)",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(10),
                ),
                Text(limitOrder.price.toStringAsFixed(2),
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(16),
                ),
                Text(
                  "成交均价(USD)",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(10),
                ),
                Text(
                    limitOrder.trade_avg_price == null
                        ? ""
                        : limitOrder.trade_avg_price.toStringAsFixed(2),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  "保证金(BTC)",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(10),
                ),
                Text(
                  limitOrder.margin_frozen.toStringAsFixed(4),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(16),
                ),
                Text(
                  "手续费(BTC)",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(10),
                ),
                Text(
                  limitOrder.fee.toStringAsFixed(4),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                )
              ],
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                          "当前没有委托数据",
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
