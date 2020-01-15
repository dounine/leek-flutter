import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/util/ScaffoldUtil.dart';

class Api extends StatefulWidget {
  const Api({Key key}) : super(key: key);

  @override
  _ApiState createState() {
    return _ApiState();
  }
}

class _ApiState extends State<Api> {
  @override
  void initState() {
    query();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _accessKey = "";
  String _accessSecret = "";
  String _reqStatus = "";
  bool _showSecret = false;
  BuildContext _context;

  void query() async {
    try {
      setState(() {
        _reqStatus = "request";
      });
      Response response = await Config.dio.get("/user/api");
      Map<String, dynamic> data = response.data;
      if (data["status"] == "ok") {
        HapticFeedback.lightImpact();
        setState(() {
          _accessKey = data["data"]["accessKey"];
          _accessSecret = data["data"]["accessSecret"];
          _reqStatus = data["status"];
        });
      } else {
        setState(() {
          _reqStatus = data["status"];
        });
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      print(e);
      setState(() {
        _reqStatus = "timeout";
      });
      HapticFeedback.heavyImpact();
      ScaffoldUtil.show(_context, {"status": "timeout"});
    }
  }

  void update() async {
    try {
      setState(() {
        _reqStatus = "request";
      });
      Response response = await Config.dio.post("/user/api",
          data: {"accessKey": _accessKey, "accessSecret": _accessSecret});
      Map<String, dynamic> data = response.data;
      if (data["status"] == "ok") {
        ScaffoldUtil.show(_context, {"status": "ok", "msg": "修改成功"});
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.mediumImpact();
        ScaffoldUtil.show(_context, data);
      }
      setState(() {
        _reqStatus = data["status"];
      });
    } catch (e) {
      print(e);
      setState(() {
        _reqStatus = "timeout";
      });
      HapticFeedback.heavyImpact();
      ScaffoldUtil.show(_context, {"status": "timeout"});
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("API授权"),
        ),
        body: new Builder(builder: (c) {
          _context = c;
          return Container(
            color: Colors.grey[100],
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: ScreenUtil.instance.setHeight(20),
                ),
                Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(
                        left: ScreenUtil.instance.setWidth(40),
                        right: ScreenUtil.instance.setWidth(40),
                        bottom: ScreenUtil.instance.setHeight(20)),
                    child: TextField(
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          setState(() {
                            _accessKey = value;
                          });
                        },
                        controller: TextEditingController.fromValue(
                            TextEditingValue(
                                text: _accessKey,
                                selection: TextSelection.fromPosition(
                                    TextPosition(
                                        affinity: TextAffinity.downstream,
                                        offset: _accessKey.length)))),
                        decoration: InputDecoration(
                            labelText: "Key", helperText: "密钥Key"))),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(40),
                ),
                Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(
                        left: ScreenUtil.instance.setWidth(40),
                        right: ScreenUtil.instance.setWidth(40),
                        bottom: ScreenUtil.instance.setHeight(20)),
                    child: TextField(
                        keyboardType: TextInputType.text,
                        obscureText: !_showSecret,
                        onChanged: (value) {
                          setState(() {
                            _accessSecret = value;
                          });
                        },
                        controller: TextEditingController.fromValue(
                            TextEditingValue(
                                text: _accessSecret,
                                selection: TextSelection.fromPosition(
                                    TextPosition(
                                        affinity: TextAffinity.downstream,
                                        offset: _accessSecret.length)))),
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showSecret = !_showSecret;
                                  });
                                },
                                icon: Icon(
                                  Icons.visibility,
                                  color: Colors.blue[200],
                                )),
                            labelText: "Secret",
                            helperText: "密钥Secret"))),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(40),
                ),
                Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: ScreenUtil.instance.setWidth(20)),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "登录网页火币后、在API管理可创建API Key\n创建的时候权限设置需要勾选交易选项",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(30),
                ),
                _reqStatus == "request"
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : ((_accessKey == "" || _accessSecret == "")
                        ? Container()
                        : FractionallySizedBox(
                            widthFactor: 0.96,
                            child: MaterialButton(
                              color: Colors.blue,
                              textColor: Colors.white,
                              height: ScreenUtil.instance.setHeight(90),
                              child: new Text("保存"),
                              onPressed: () {
                                update();
                              },
                            ),
                          )),
              ],
            ),
          );
        }));
  }
}
