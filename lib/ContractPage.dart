import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:leek/Config.dart';
import 'package:leek/store/SocketStore.dart';
import 'package:leek/store/UserStore.dart';
import 'package:provider/provider.dart';
import 'package:vibrate/vibrate.dart';

import 'ContractTrade.dart';

class ContractPage extends StatefulWidget {
  ContractPage({Key key}) : super(key: key);

  @override
  _ContractPageState createState() {
    return _ContractPageState();
  }
}

class OpenItem {
  final String contractType;
  final String direction;

  OpenItem({this.contractType, this.direction});
}

class ContractInfo {
  final String symbol;

  final bool quarterOpen;
  final bool thisWeekOpen;
  final bool nextWeekOpen;
  final String rise;
  final List<OpenItem> opens;

  ContractInfo(
      {this.symbol,
      this.quarterOpen,
      this.thisWeekOpen,
      this.nextWeekOpen,
      this.rise,
      this.opens});
}

class _ContractPageState extends State<ContractPage> {
  List<ContractInfo> list;

  Future query() async {
    Response response = await Config.dio.get("/contract/listOpen");
    Map<String, dynamic> data = response.data;
    if (data["status"] == "ok") {
      List<ContractInfo> tmpList = [];
      List<dynamic> dataList = data["data"];
      dataList.forEach((item) {
        List<OpenItem> openItems = [];
        var opens = item["opens"] as List<dynamic>;
        opens.forEach((j){
          openItems.add(OpenItem(
            contractType: j["contractType"],
            direction: j["direction"]
          ));
        });
        tmpList.add(ContractInfo(
            symbol: item["symbol"],
            quarterOpen: item["quarterOpen"],
            thisWeekOpen: item["thisWeekOpen"],
            nextWeekOpen: item["nextWeekOpen"],
            rise: "0.0",
            opens: openItems));
      });
      setState(() {
        list = tmpList;
      });
      Vibrate.feedback(FeedbackType.light);
    } else if (data["status"] == "fail" && data["msg"] == "token invalid.") {
      Future.delayed(Duration.zero, () {
        Provider.of<UserStore>(context).logout();
      });
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
    return RefreshIndicator(
        onRefresh: _refresh,
        child: list == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : (list != null && list.length == 0)
                ? Center(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 40,
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
                            new Divider(
                              height: 1,
                            ),
                        itemBuilder: (BuildContext context, int index) {
                          return getRow(index);
                        }),
                  ));
  }

  _onTap(int index) {
    ContractInfo data = list[index];
    Navigator.pushNamed(context, '/contractTrade', arguments: data)
        .then((result) {
      Provider.of<SocketStore>(context)
          .sendMessage({"type": "unsub", "channels": result});
      Provider.of<SocketStore>(context).delConnectedListener("contract");
      Provider.of<SocketStore>(context).delMsgListener("contract");
    });
  }

  Widget getRow(int index) {
    ContractInfo data = list[index];
    return Container(
        height: 60,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onTap(index),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 20.0, top: 5.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 5.0),
                        child: Text(data.symbol,
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                      Container(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: "24h ",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            TextSpan(
                                text: "",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black54))
                          ])))
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 5.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 5.0),
                        child: Text("",
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
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
              ),
              Expanded(
                child: Container(
                  height: 30,
                  margin: EdgeInsets.only(left: 24, right: 24.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color:
                          data.rise.startsWith("-") ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(2.0)),
                  child: Container(
                    child: Text(
                      "${data.rise}%",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
