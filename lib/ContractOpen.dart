import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/ContractPage.dart';
import 'package:leek/contract/Contrast.dart';
import 'package:leek/contract/Entrust.dart';
import 'package:leek/contract/Position.dart';
import 'package:leek/contract/Trades.dart';
import 'package:leek/store/ContractStore.dart';
import 'package:leek/store/SocketStore.dart';
import 'package:provider/provider.dart';
import 'package:vibrate/vibrate.dart';

class ContractOpen extends StatefulWidget {
  final String symbol;
  final String contractType;
  final String direction;

  const ContractOpen(this.symbol, this.contractType, this.direction, {Key key})
      : super(key: key);

  @override
  _ContractOpenState createState() {
    return _ContractOpenState();
  }
}

class _ContractOpenState extends State<ContractOpen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  String _status = "";
  String _agree;

  Dio dio = Config.dio;

  void application() async {
    var symbol = widget.symbol;
    var contractType = widget.contractType;
    var direction = widget.direction;
    setState(() {
      _status = "request";
    });
    try {
      Response response = await Config.dio
          .post("/open/request/info/${symbol}/${contractType}/${direction}");
      Map<String, dynamic> result = response.data;
      setState(() {
        _status = result["status"];
      });
      if (result["status"] == "fail") {
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Row(
          children: <Widget>[
            Icon(Icons.error_outline),
            SizedBox(
              width: 10,
            ),
            new Text(""),
            SizedBox(
              width: 0,
            ),
            new Text(
              result["msg"],
              style: TextStyle(color: Colors.red),
            )
          ],
        )));
        setState(() {
          _agree = "";
        });
      }
    } catch (e) {
      setState(() {
        _status = "";
      });
    }
  }

  void queryStatus() async {
    var symbol = widget.symbol;
    var contractType = widget.contractType;
    var direction = widget.direction;
    setState(() {
      _status = "request";
    });
    try {
      Response response = await Config.dio
          .get("/open/request/info/${symbol}/${contractType}/${direction}");
      Map<String, dynamic> result = response.data;
      print(result);
      setState(() {
        _status = result["status"];
      });
      if (result["status"] == "ok" && result["data"] != null) {
        setState(() {
          _agree = "";
        });
      }
    } catch (e) {
      setState(() {
        _status = "";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    queryStatus();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(height: ScreenUtil.instance.setHeight(500)),
          Container(
            child: Text(
              "您当前还没有开通这个功能、需要申请",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          SizedBox(
            height: ScreenUtil.instance.setHeight(50),
          ),
          SizedBox(
            width: ScreenUtil.instance.setWidth(800),
            child: _status == "request"
                ? CircularProgressIndicator()
                : RaisedButton(
                    child: Text(
                      _agree == null ? "申请开通" : "已申请、等待审核",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.lightBlue,
                    onPressed: _agree == null
                        ? () {
                            application();
                          }
                        : null,
                  ),
          )
        ],
      ),
    );
  }
}
