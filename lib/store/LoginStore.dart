//import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:leek/Config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibrate/vibrate.dart';

class LoginStore extends ChangeNotifier {
  LoginStore() {
    _readAccount();
  }

  String _phone = "";
  String _password = "";
  bool _passwordHidden = true;
  String _status = "";

  Function _next;

  String get phone => _phone;

  String get password => _password;

  String get status => _status;

  bool get passwordHidden => _passwordHidden;

  bool get isValid {
    return RegExp(
                r"^1([38][0-9]|4[579]|5[0-3,5-9]|6[6]|7[0135678]|9[89])\d{8}$")
            .hasMatch(_phone) &&
        _password.length >= 6;
  }

  void login() async {
    if (this.isValid) {
      Map<String, dynamic> data = {"phone": _phone, "password": _password};
      _status = "request";
      String msg = "";
      try {
        Response response = await Config.dio.post("/user/login", data: data);
        Map<String, dynamic> result = response.data;
        _status = result["status"];
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        if (_status == "ok") {
          Vibrate.feedback(FeedbackType.light);
          await sharedPreferences.setString(
              "token", result["data"]["token"] ?? "");
          Config.setToken();
        } else {
          Vibrate.feedback(FeedbackType.warning);
          await sharedPreferences.remove("token");
        }
        msg = result["msg"] ?? "";
        _next(_status, msg);
      } on DioError {
        _status = "fail";
        Vibrate.feedback(FeedbackType.warning);
        print("登录失败、请检查网络.");
        _next("fail", "登录失败、请检查网络.");
      } catch (e) {
        _status = "fail";
        Vibrate.feedback(FeedbackType.warning);
        print("登录失败、${msg}");
        _next("fail", "登录失败、${msg}");
      }
    } else {
      _status = "";
      throw new Exception("帐号验证失败、请联系管理员.");
    }
  }

  void nextAnimation(Function next) => this._next = next;

  void _readAccount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _phone = sharedPreferences.getString("phone") ?? "";
    _password = sharedPreferences.getString("password") ?? "";
    notifyListeners();
  }

  set passwordHidden(bool value) {
    _passwordHidden = value;
    notifyListeners();
  }

  set status(String value) {
    _status = value;
    notifyListeners();
  }

  void change(String type, String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (type == "phone") {
      _phone = value;
    } else if (type == "password") {
      _password = value;
    }
    sharedPreferences.setString(type, value);
    notifyListeners();
  }
}
