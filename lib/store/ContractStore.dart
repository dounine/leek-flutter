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
  String _contractType;
  String _direction = "buy";

  String _usdt = "";
  String _cny = "";
  String _rise = "0.0";
  double _open = 0.0;
  bool _push_info = false;
  num _openEntrustValue = -1;
  num _openEntrustPrice = -1;
  num _openTradeValue = -1;
  num _openTradePrice = -1;

  num _closeEntrustValue = -1;
  num _closeEntrustPrice = -1;
  num _closeTradeValue = -1;
  num _closeTradePrice = -1;

  String _open_status = "--";
  bool _open_enable = false;
  num _open_rebound_price = 0;
  num _open_plan_price_spread = 0;
  num _open_volume = 1;
  Map<String, dynamic> _open_schedue = {"length": 3, "unit": "seconds"};
  Map<String, dynamic> _open_entrust_timeout = {"length": 3, "unit": "seconds"};
  String _open_lever_rate = "20";

  String _close_status = "--";
  bool _close_bind = false;
  num _close_rebound_price = 0;
  num _close_plan_price_spread = 0;
  num _close_volume = 1;
  Map<String, dynamic> _close_schedue = {"length": 3, "unit": "seconds"};
  Map<String, dynamic> _close_entrust_timeout = {
    "length": 3,
    "unit": "seconds"
  };

  bool get push_info => _push_info;

  String get open_status => _open_status;
  String get open_lever_rate => _open_lever_rate;
  bool get open_enable => _open_enable;
  num get open_rebound_price => _open_rebound_price;
  num get open_plan_price_spread => _open_plan_price_spread;
  num get open_volume => _open_volume;
  num get openEntrustValue => _openEntrustValue;
  num get openEntrustPrice => _openEntrustPrice;
  num get openTradePrice => _openTradePrice;
  num get openTradeValue => _openTradeValue;
  num get closeEntrustValue => _closeEntrustValue;
  num get closeEntrustPrice => _closeEntrustPrice;
  num get closeTradePrice => _closeTradePrice;
  num get closeTradeValue => _closeTradeValue;
  Map<String, dynamic> get open_schedue => _open_schedue;
  Map<String, dynamic> get open_entrust_timeout => _open_entrust_timeout;

  String get close_status => _close_status;
  bool get close_bind => _close_bind;
  num get close_rebound_price => _close_rebound_price;
  num get close_plan_price_spread => _close_plan_price_spread;
  num get close_volume => _close_volume;
  Map<String, dynamic> get close_schedue => _close_schedue;
  Map<String, dynamic> get close_entrust_timeout => _close_entrust_timeout;

  String get symbol => _symbol;
  double get open => _open;

  set push_info(bool value) {
    _push_info = value;
  }

  set open_rebound_price(num value) {
    _open_rebound_price = value;
  }

  set open_lever_rate(String value) {
    _open_lever_rate = value;
    notifyListeners();
  }

  set open_plan_price_spread(num value) {
    _open_plan_price_spread = value;
  }

  set open_schedue(Map<String, dynamic> value) {
    _open_schedue = value;
  }

  set open_entrust_timeout(Map<String, dynamic> value) {
    _open_entrust_timeout = value;
  }

  set open_volume(num value) {
    _open_volume = value;
  }

  set open_enable(bool value) {
    _open_enable = value;
  }

  set close_bind(bool value) {
    _close_bind = value;
    notifyListeners();
  }

  set close_rebound_price(num value) {
    _close_rebound_price = value;
  }

  set close_plan_price_spread(num value) {
    _close_plan_price_spread = value;
  }

  set close_schedue(Map<String, dynamic> value) {
    _close_schedue = value;
  }

  set close_volume(num value) {
    _close_volume = value;
  }

  set close_entrust_timeout(Map<String, dynamic> value) {
    _close_entrust_timeout = value;
  }

  set open(double value) {
    _open = value;
  }

  String get direction => _direction;

  String get usdt {
    if (_usdt == "") {
      return _usdt;
    } else if (_usdt.split(".")[1].length == 1) {
      return "${_usdt}0";
    }
    return _usdt;
  }

  String get cny => _cny;

  String get rise => _rise;

  set rise(String value) {
    _rise = value;
  }

  String get contractType => _contractType ?? "quarter";

  set contractType(String value) {
    _contractType = value;
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
      // _rise = ((usdtPrice - _open) / _open * 100).toStringAsFixed(2);
    } else if (data["status"] == "ok" && data["type"] == "po") {
      var d = data["data"];
      print(d);
      if (d["offset"] == "open") {
        if (d["tv"] != null) {
          _openTradeValue = d["tv"];
          Config.eventBus
              .fire(PushEvent("online_open_trade_price", _openTradeValue));
        }
        if (d["ev"] != null) {
          _openEntrustValue = d["ev"];
          Config.eventBus
              .fire(PushEvent("online_open_entrust_price", _openEntrustValue));
        }
        if (d["tp"] != null) {
          _openTradePrice = d["tp"];
        }
        if (d["ep"] != null) {
          _openEntrustPrice = d["ep"];
        }
      } else if (d["offset"] == "close") {
        if (d["tv"] != null) {
          _closeTradeValue = d["tv"];
          Config.eventBus
              .fire(PushEvent("online_close_trade_price", _closeTradeValue));
        }
        if (d["ev"] != null) {
          _closeEntrustValue = d["ev"];
          Config.eventBus
              .fire(PushEvent("online_close_entrust_price", _closeEntrustValue));
        }
        if (d["tp"] != null) {
          _closeTradePrice = d["tp"];
        }
        if (d["ep"] != null) {
          _closeEntrustPrice = d["ep"];
        }
      }
    } else if (data["status"] == "ok" && data["type"] == "push_info") {
      var d = data["data"];
      print(d);
      _push_info = true;
      if (d["open_enable"] != null) {
        _open_enable = d["open_enable"];
      }
      if (d["open_rebound_price"] != null) {
        _open_rebound_price = d["open_rebound_price"];
        Config.eventBus
              .fire(PushEvent("open_rebound_price", _open_rebound_price));
      }
      if (d["open_plan_price_spread"] != null) {
        _open_plan_price_spread = d["open_plan_price_spread"];
        Config.eventBus
              .fire(PushEvent("open_plan_price_spread", _open_plan_price_spread));
      }
      if (d["open_volume"] != null) {
        _open_volume = d["open_volume"];
        Config.eventBus
              .fire(PushEvent("open_volume", _open_volume));
      }
      if (d["open_schedue"] != null) {
        _open_schedue = d["open_schedue"];
        Config.eventBus
              .fire(PushEvent("open_schedue", _open_schedue["length"]));
      }
      if (d["open_entrust_timeout"] != null) {
        _open_entrust_timeout = d["open_entrust_timeout"];
        Config.eventBus
              .fire(PushEvent("open_entrust_timeout", _open_entrust_timeout["length"]));
      }
      if (d["open_lever_rate"] != null) {
        _open_lever_rate = d["open_lever_rate"];
      }

      if (d["open_status"] != null) {
        _open_status = d["open_status"];
      }
      if (d["close_bind"] != null) {
        _close_bind = d["close_bind"];
      }
      if (d["close_rebound_price"] != null) {
        _close_rebound_price = d["close_rebound_price"];
        Config.eventBus
              .fire(PushEvent("close_rebound_price", _close_rebound_price));
      }
      if (d["close_plan_price_spread"] != null) {
        _close_plan_price_spread = d["close_plan_price_spread"];
        Config.eventBus
              .fire(PushEvent("close_plan_price_spread", _close_plan_price_spread));
      }
      if (d["close_volume"] != null) {
        _close_volume = d["close_volume"];
        Config.eventBus
              .fire(PushEvent("close_volume", _close_volume));
      }
      if (d["close_status"] != null) {
        _close_status = d["close_status"];
      }
      if (d["close_schedue"] != null) {
        _close_schedue = d["close_schedue"];
        Config.eventBus
              .fire(PushEvent("close_schedue", _close_schedue["length"]));
      }
      if (null != d["close_entrust_timeout"]) {
        _close_entrust_timeout = d["close_entrust_timeout"];
        Config.eventBus
              .fire(PushEvent("close_entrust_timeout", _close_entrust_timeout["length"]));
      }
    }
    notifyListeners();
  }

  void save() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, dynamic> data = json.decode(
        sharedPreferences.getString("contract_${symbol.toLowerCase()}") ??
            "{}");
    data["contractType"] = _contractType;
    data["symbol"] = _symbol;
    data["direction"] = _direction;
    sharedPreferences.setString(
        "contract_${symbol.toLowerCase()}", json.encode(data));
    notifyListeners();
  }

  Future choose(String symbol) async {
    _symbol = symbol;
    _push_info = false;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, dynamic> data = json.decode(
        sharedPreferences.getString("contract_${symbol.toLowerCase()}") ??
            "{}");
    _contractType = data["contractType"] ?? "quarter";
    _direction = data["direction"] ?? "buy";
    notifyListeners();
  }

  void initContract() async {
    Response response = await Config.dio.get(
        "/contract/scheduling/${_symbol.toLowerCase()}/${_contractType}/${_direction}");
    Map<String, dynamic> result = response.data;
  }
}
