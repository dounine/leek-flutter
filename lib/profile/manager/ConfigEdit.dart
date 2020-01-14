import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/profile/manager/ContractManager.dart';
import 'package:leek/profile/manager/ContractManagerEdit.dart';
import 'package:leek/util/ScaffoldUtil.dart';
import 'package:vibrate/vibrate.dart';

class ConfigEdit extends StatefulWidget {
  final String title;
  const ConfigEdit({this.title, Key key}) : super(key: key);

  @override
  _ConfigEditState createState() {
    return _ConfigEditState();
  }
}

class _ConfigEditState extends State<ConfigEdit> {
  String _name;
  String _symbol;
  String _keyName;
  String _minValue;
  String _maxValue;
  String _defaultValue;
  int _fixed = 0;
  String _setup;
  bool _user;
  String _reqStatus = "";

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      ConfigInfo info = ModalRoute.of(context).settings.arguments;
      setState(() {
        _name = info.name;
        _symbol = info.symbol;
        _keyName = info.keyName;
        _minValue = info.minValue.toString();
        _maxValue = info.maxValue.toString();
        _defaultValue = info.defaultValue.toString();
        _fixed = info.fixed;
        _setup = info.setup.toString();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void update() async {
    try {
      setState(() {
        _reqStatus = "request";
      });
      Response response = await Config.dio.patch("/config/admin/info", data: {
        "phone": "",
        "symbol": _symbol,
        "keyName": _keyName,
        "minValue": num.parse(_minValue),
        "maxValue": num.parse(_maxValue),
        "defaultValue": num.parse(_defaultValue),
        "fixed": _fixed,
        "setup": num.parse(_setup),
        "user": false
      });
      Map<String, dynamic> data = response.data;
      if (data["status"] == "fail") {
        Vibrate.feedback(FeedbackType.warning);
        ScaffoldUtil.show(_context, data);
      } else {
        Vibrate.feedback(FeedbackType.light);
        ScaffoldUtil.show(_context, data, msg: "保存成功");
      }

      setState(() {
        _reqStatus = data["status"];
      });
    } catch (e) {
      setState(() {
        _reqStatus = "timeout";
      });
      Vibrate.feedback(FeedbackType.warning);
      ScaffoldUtil.show(_context, {"status": "timeout"});
    }
  }

  BuildContext _context;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    ConfigInfo info = ModalRoute.of(context).settings.arguments;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(
            context,
            ConfigInfo(
                _name,
                _symbol,
                _keyName,
                double.parse(_minValue),
                double.parse(_maxValue),
                double.parse(_defaultValue),
                _fixed,
                double.parse(_setup)));
        return false;
      },
      child: new Scaffold(
          appBar: AppBar(
            title: Text("修改信息"),
          ),
          body: new Builder(builder: (c) {
            _context = c;
            return Container(
                child: Column(children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(ScreenUtil.instance.setWidth(20)),
                    child: Text("最小值"),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        keyboardType: TextInputType.text,
                        controller: TextEditingController.fromValue(
                            TextEditingValue(
                                text: _minValue.toString(),
                                selection: TextSelection.fromPosition(
                                    TextPosition(
                                        affinity: TextAffinity.downstream,
                                        offset: _minValue.toString().length)))),
                        decoration: InputDecoration(labelText: "浮点数"),
                        onChanged: (value) {
                          setState(() {
                            _minValue = value;
                          });
                        },
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(ScreenUtil.instance.setWidth(20)),
                    child: Text("最大值"),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        keyboardType: TextInputType.text,
                        controller: TextEditingController.fromValue(
                            TextEditingValue(
                                text: _maxValue.toString(),
                                selection: TextSelection.fromPosition(
                                    TextPosition(
                                        affinity: TextAffinity.downstream,
                                        offset: _maxValue.toString().length)))),
                        decoration: InputDecoration(labelText: "浮点数"),
                        onChanged: (value) {
                          setState(() {
                            _maxValue = value;
                          });
                        },
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(ScreenUtil.instance.setWidth(20)),
                    child: Text("默认值"),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        keyboardType: TextInputType.text,
                        controller: TextEditingController.fromValue(
                            TextEditingValue(
                                text: _defaultValue.toString(),
                                selection: TextSelection.fromPosition(
                                    TextPosition(
                                        affinity: TextAffinity.downstream,
                                        offset:
                                            _defaultValue.toString().length)))),
                        decoration: InputDecoration(labelText: "浮点数"),
                        onChanged: (value) {
                          setState(() {
                            _defaultValue = value;
                          });
                        },
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(ScreenUtil.instance.setWidth(20)),
                    child: Text("保留小数"),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: TextEditingController.fromValue(
                            TextEditingValue(
                                text: _fixed.toString(),
                                selection: TextSelection.fromPosition(
                                    TextPosition(
                                        affinity: TextAffinity.downstream,
                                        offset: _fixed.toString().length)))),
                        decoration: InputDecoration(labelText: "整数"),
                        onChanged: (value) {
                          setState(() {
                            _fixed = num.parse(value);
                          });
                        },
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(ScreenUtil.instance.setWidth(20)),
                    child: Text("步进数"),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        keyboardType: TextInputType.text,
                        controller: TextEditingController.fromValue(
                            TextEditingValue(
                                text: _setup.toString(),
                                selection: TextSelection.fromPosition(
                                    TextPosition(
                                        affinity: TextAffinity.downstream,
                                        offset: _setup.toString().length)))),
                        decoration: InputDecoration(labelText: "浮点数"),
                        onChanged: (value) {
                          setState(() {
                            _setup = value;
                          });
                        },
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: ScreenUtil.instance.setHeight(40),
              ),
              _reqStatus == "request"
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : FractionallySizedBox(
                      widthFactor: 0.96,
                      child: MaterialButton(
                        color: Colors.blue,
                        textColor: Colors.white,
                        height: ScreenUtil.instance.setHeight(90),
                        child: new Text("保存"),
                        onPressed: (_minValue == "" ||
                                _maxValue == "" ||
                                _defaultValue == "" ||
                                _setup == "")
                            ? null
                            : () {
                                update();
                              },
                      ),
                    )
            ]));
          })),
    );
  }
}
