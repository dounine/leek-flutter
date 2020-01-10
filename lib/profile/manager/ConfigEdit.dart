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
  double _minValue = 0;
  double _maxValue = 100;
  double _defaultValue = 0;
  int _fixed = 0;
  double _setup = 1;
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
        _minValue = info.minValue;
        _maxValue = info.maxValue;
        _defaultValue = info.defaultValue;
        _fixed = info.fixed;
        _setup = info.setup;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void update(String contractType, bool value) async {
    try {
      setState(() {
        _reqStatus = "${contractType}_request";
      });
      Response response = await Config.dio.patch(
          "/contract/admin/info/auto/${_symbol}/${contractType}/${value}");
      Map<String, dynamic> data = response.data;
      if (data["status"] == "fail") {
        ScaffoldUtil.show(_context, data,
            msg: "${value ? '开通' : '关闭'}" + "失败:${data['msg']}");
      }

      setState(() {
        _reqStatus = contractType + "_" + data["status"];
      });
    } catch (e) {
      setState(() {
        _reqStatus = contractType + "_timeout";
      });
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
            ConfigInfo(_name, _symbol, _keyName, _minValue, _maxValue,
                _defaultValue, _fixed, _setup));
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
                                text: "",
                                selection: TextSelection.fromPosition(
                                    TextPosition(
                                        affinity: TextAffinity.downstream,
                                        offset: "".length)))),
                        decoration: InputDecoration(labelText: "最小值"),
                        onChanged: (value) {},
                      ),
                    ),
                  )
                ],
              )
            ]));
          })),
    );
  }
}
