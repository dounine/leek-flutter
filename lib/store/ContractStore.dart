import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:leek/Config.dart';
import 'package:leek/store/SocketStore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContractStore extends ChangeNotifier {
  String _symbol;
  String _type;
  String _direction = "buy";
  String _usdt = "";
  String _cny = "";
  String _rise = "0.0";
  double _open = 0.0;

  bool _open_enable = false;
  num _open_rebound_price = 0;
  num _open_plan_price_spread = 0;
  num _open_volume = 1;
  num _open_scheduling = 3;
  String _open_status = "--";

  bool _close_enable = false;
  bool _close_associated = false;
  num _close_rebound_price = 0;
  num _close_plan_price_spread = 0;
  num _close_volume = 1;
  String _close_status = "--";

  bool get open_enable => _open_enable;

  set open_enable(bool value) {
    _open_enable = value;
  }

  bool get close_enable => _close_enable;

  set close_enable(bool value) {
    _close_enable = value;
  }

  String get symbol => _symbol;

  double get open => _open;

  set open(double value) {
    _open = value;
  }

  String get direction => _direction;

  String get usdt => _usdt;

  String get cny => _cny;

  String get rise => _rise;

  set rise(String value) {
    _rise = value;
  }

  String get type => _type;

  set type(String value) {
    _type = value;
    save();
  }

  set direction(String value) {
    _direction = value;
    save();
  }

  void onMessage(Map<String, dynamic> data) {
    if (data["status"] == "ok" &&
        data["type"] == "price" &&
        data["data"] != null) {
      double usdtPrice = double.parse(data["data"].toString());
      _usdt = usdtPrice.toString();
      _cny = (usdtPrice * 7).toStringAsFixed(2);
      _rise = ((usdtPrice - _open) / _open * 100).toStringAsFixed(2);
      notifyListeners();
    }
  }

  void save() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, dynamic> data = json.decode(
        sharedPreferences.getString("contract_${symbol.toLowerCase()}") ??
            "{}");
    data["type"] = _type;
    data["symbol"] = _symbol;
    data["direction"] = _direction;
    sharedPreferences.setString(
        "contract_${symbol.toLowerCase()}", json.encode(data));
    notifyListeners();
  }

  Future choose(String symbol) async {
    _symbol = symbol;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, dynamic> data = json.decode(
        sharedPreferences.getString("contract_${symbol.toLowerCase()}") ??
            "{}");
    _type = data["type"] ?? "quarter";
    _direction = data["direction"] ?? "buy";
    notifyListeners();
  }

  void initContract() async {
    Response response = await Config.dio.get(
        "/contract/scheduling/${_symbol.toLowerCase()}/${_type}/${_direction}");
    Map<String, dynamic> result = response.data;
  }
}
