import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/util/ScaffoldUtil.dart';

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
  String _reqStatus = "";
  String _agree;
  BuildContext _context;
  Dio dio = Config.dio;

  void application() async {
    var symbol = widget.symbol;
    var contractType = widget.contractType;
    var direction = widget.direction;
    try {
      setState(() {
        _reqStatus = "request";
      });
      Response response = await Config.dio
          .post("/open/request/info/${symbol}/${contractType}/${direction}");
      Map<String, dynamic> data = response.data;
      if (data["status"] == "fail") {
        ScaffoldUtil.show(_context, data);
        setState(() {
          _reqStatus = data["status"];
        });
      } else {
        setState(() {
          _reqStatus = data["status"];
          _agree = "";
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _reqStatus = "timeout";
      });
      ScaffoldUtil.show(_context, {"status": "timeout"});
    }
  }

  void queryStatus() async {
    var symbol = widget.symbol;
    var contractType = widget.contractType;
    var direction = widget.direction;
    try {
      setState(() {
        _reqStatus = "request";
      });
      Response response = await Config.dio
          .get("/open/request/info/${symbol}/${contractType}/${direction}");
      Map<String, dynamic> data = response.data;
      print(data);
      if (data["status"] == "ok" && data["data"] == null) {
        setState(() {
          _agree = null;
          _reqStatus = data["status"];
        });
      } else if (data["status"] == "ok" && data["data"] != null) {
        setState(() {
          _agree = (data["data"]["agree"] ?? "").toString();
          _reqStatus = data["status"];
        });
      } else {
        setState(() {
          _agree = "";
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
    queryStatus();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    return new Builder(builder: (context) {
      _context = context;
      return Container(
        child: Column(
          children: <Widget>[
            SizedBox(height: ScreenUtil.instance.setHeight(500)),
            Container(
              child: Text(
                _agree == "true" ? "管理员已经关闭您的这个合约交易" : "您当前还没有开通这个功能、需要申请",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            SizedBox(
              height: ScreenUtil.instance.setHeight(50),
            ),
            _reqStatus == "request"
                ? Center(child: CircularProgressIndicator())
                : _agree == "true"
                    ? Container()
                    : SizedBox(
                        width: ScreenUtil.instance.setWidth(800),
                        child: RaisedButton(
                          child: Text(
                            _agree == null
                                ? "申请开通"
                                : (_agree == ""
                                    ? "已申请、请等待审核"
                                    : (_agree == "false" ? "已拒绝、重新申请" : "已通过")),
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.lightBlue,
                          onPressed: (_agree == null || _agree == "false")
                              ? () {
                                  application();
                                }
                              : null,
                        ),
                      )
          ],
        ),
      );
    });
  }
}
