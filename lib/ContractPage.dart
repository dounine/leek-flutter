import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/store/ContractStore.dart';
import 'package:leek/store/SocketStore.dart';
import 'package:leek/util/ScaffoldUtil.dart';
import 'package:provider/provider.dart';
import 'package:vibrate/vibrate.dart';

class ContractPage extends StatefulWidget {
  ContractPage({Key key}) : super(key: key);

  @override
  _ContractPageState createState() {
    return _ContractPageState();
  }
}

class ConfigInfo {
  final String keyName;
  final num minValue;
  final num maxValue;
  final num defaultValue;
  final int fixed;
  final String name;
  final num setup;
  final String symbol;
  ConfigInfo(this.keyName, this.minValue, this.maxValue, this.defaultValue,
      this.fixed, this.name, this.setup, this.symbol);
}

class OpenItem {
  final String contractType;
  final String direction;

  OpenItem({this.contractType, this.direction});
}

class ContractInfo {
  final String symbol;

  final bool quarter;
  final bool thisWeek;
  final bool nextWeek;
  final String rise;
  final List<OpenItem> opens;
  final List<ConfigInfo> configs;

  ContractInfo(
      {this.symbol,
      this.quarter,
      this.thisWeek,
      this.nextWeek,
      this.rise,
      this.opens,
      this.configs});
}

class _ContractPageState extends State<ContractPage> {
  List<ContractInfo> list;
  String _reqStatus = "";
  BuildContext _context;

  Future query() async {
    try {
      setState(() {
        _reqStatus = "request";
      });
      Response response = await Config.dio.get("/contract/list");
      Map<String, dynamic> data = response.data;
      if (data["status"] == "ok") {
        List<ContractInfo> tmpList = [];
        List<dynamic> dataList = data["data"];
        dataList.forEach((item) {
          List<OpenItem> openItems = [];
          var opens = item["opens"] as List<dynamic>;
          opens.forEach((j) {
            openItems.add(OpenItem(
                contractType: j["contractType"], direction: j["direction"]));
          });
          List<ConfigInfo> configs =
              (item["configs"] as List<dynamic>).map((citem) {
            return ConfigInfo(
              citem["keyName"],
              citem["minValue"],
              citem["maxValue"],
              citem["defaultValue"],
              citem["fixed"],
              citem["name"],
              citem["setup"],
              citem["symbol"],
            );
          }).toList();
          tmpList.add(ContractInfo(
            symbol: item["symbol"],
            quarter: item["quarter"],
            thisWeek: item["thisWeek"],
            nextWeek: item["nextWeek"],
            rise: "0.0",
            opens: openItems,
            configs: configs
          ));
        });
        setState(() {
          _reqStatus = data["status"];
          list = tmpList;
        });
        Vibrate.feedback(FeedbackType.light);
      } else {
        setState(() {
          _reqStatus = data["status"];
        });
        ScaffoldUtil.show(_context, data);
      }
    } catch (e) {
      print(e);
      setState(() {
        _reqStatus = "timeout";
      });
      ScaffoldUtil.show(_context, {"status": "timeout"});
    }
  }

  @override
  void initState() {
    query();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Null> _refresh() async {
    await query();
    return;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    return new Builder(builder: (c) {
      _context = c;
      return RefreshIndicator(
          onRefresh: _refresh,
          child: list == null
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
                  : Center(
                      child: CircularProgressIndicator(),
                    ))
              : (list.length == 0)
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
                            "没有数据显示",
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          )
                        ],
                      ),
                    )
                  : Container(
                      child: ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(
                                height: 1,
                              ),
                          itemBuilder: (BuildContext context, int index) {
                            return getRow(index);
                          }),
                    ));
    });
  }

  _onTap(int index) {
    ContractInfo data = list[index];
    Navigator.pushNamed(context, '/contractTrade', arguments: data)
        .then((result) {
      Provider.of<ContractStore>(context).push_info = false;
      Provider.of<SocketStore>(context)
          .sendMessage({"type": "unsub", "channels": result});
      Provider.of<SocketStore>(context).delConnectedListener("contract");
      Provider.of<SocketStore>(context).delMsgListener("contract");
    });
  }

  Widget getRow(int index) {
    ContractInfo data = list[index];
    return Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onTap(index),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(data.symbol,
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500)),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Container(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: "24h ",
                              style: TextStyle(color: Colors.grey)),
                          TextSpan(
                              text: "", style: TextStyle(color: Colors.black54))
                        ])))
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 5.0),
                      child: Text("",
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 3.0),
                      child: Text("",
                          style:
                              TextStyle(fontSize: 12, color: Colors.black54)),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: ScreenUtil.instance.setHeight(10),
                    horizontal: ScreenUtil.instance.setWidth(30)),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color:
                        data.rise.startsWith("-") ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(2.0)),
                child: Container(
                  child: Text(
                    "${data.rise}%",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
