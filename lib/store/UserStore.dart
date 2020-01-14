import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:leek/Config.dart';
import 'package:leek/LoginPage.dart';
import 'package:leek/Screen.dart';
import 'package:leek/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibrate/vibrate.dart';

class UserStore extends ChangeNotifier {
  UserStore() {
    init();
  }

  String _token = "";
  String _phone;
  String _apiKey = "";
  String _apiSecret = "";
  String _webSession = "";
  String _status = "";
  bool _showSecret = false;
  Widget _widget = new Screen();

  bool get showSecret => _showSecret;

  set showSecret(bool value) {
    _showSecret = value;
    notifyListeners();
  }

  String get apiKey => _apiKey;

  String get status => _status;

  String get apiSecret => _apiSecret;

  String get webSession => _webSession;

  set apiKey(String value) {
    _apiKey = value;
    notifyListeners();
  }

  set apiSecret(String value) {
    _apiSecret = value;
    notifyListeners();
  }

  set webSession(String value) {
    _webSession = value;
    notifyListeners();
  }

  Widget getWidget() {
    return _widget;
  }

  set phone(String value) {
    _phone = value;
  }

  String get phone => _phone;

  void init() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _token = sharedPreferences.getString("token") ?? "";
    if (_token != "") {
      try {
        Response response = await Config.dio.get("/user/valid");
        Map<String, dynamic> result = response.data;
        if (result["status"] == "ok") {
          _widget = MyHomePage();
        } else {
          _widget = LoginPage();
        }
      } catch (e) {
        new Timer(const Duration(seconds: 3), () {
          print("超时、重新验证");
          init();
        });
      }
    } else {
      _widget = LoginPage();
    }
    _phone = sharedPreferences.getString("phone") ?? "";
    notifyListeners();
  }

  void initApi(Function callback) async {
    try {
      Response response = await Config.dio.get("/user/api");
      Map<String, dynamic> result = response.data;
      _status = result["status"];
      if (result["status"] == "ok") {
        _apiKey = result["data"]["accessKey"];
        _apiSecret = result["data"]["accessSecret"];
      }
    } catch (e) {
      print(e);
      if (callback != null) {
        _status = "";
        callback("fail", "请求超时、请稍候再试.");
      }
    }
    notifyListeners();
  }

  void saveApi(Function callback) async {
    _status = "request";
    notifyListeners();
    Map<String, String> saveData = {
      "accessKey": _apiKey,
      "accessSecret": _apiSecret
    };
    try {
      Response response = await Config.dio.post("/user/api", data: saveData);
      Map<String, dynamic> result = response.data;
      if (result["status"] == "ok") {
        Vibrate.feedback(FeedbackType.light);
      } else {
        Vibrate.feedback(FeedbackType.warning);
      }
      _status = result["status"];
      if (callback != null) {
        callback(_status, result["msg"] ?? "");
      }
      notifyListeners();
    } catch (e) {
      Vibrate.feedback(FeedbackType.warning);
    }
  }

  void initWebSession() async {
    Response response = await Config.dio.get("/user/query/hbsession");
    Map<String, dynamic> result = response.data;
    if (result["status"] == "ok") {
      _webSession = result["data"];
      notifyListeners();
    }
  }

  void saveWebSession(Function callback) async {
    _status = "request";
    notifyListeners();
    Map<String, String> saveData = {"value": _webSession};
    try {
      Response response =
          await Config.dio.post("/user/hbsession", data: saveData);
      Map<String, dynamic> result = response.data;
      _status = result["status"];
      if (callback != null) {
        callback(_status, result["msg"] ?? "");
      }
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  void logout() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove("token");
    init();
  }
}
