import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:leek/Config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibrate/vibrate.dart';
import 'package:web_socket_channel/io.dart';

enum SocketStatus { close, connect, connected, closed }

class SocketStore extends ChangeNotifier {
  SocketStore() {
    init();
  }

  IOWebSocketChannel _channel;
  SocketStatus _status = SocketStatus.closed;
  Map<String, Function> _funs = Map();
  Map<String, Function> _connectedFuns = Map();

  get status => _status;

  set status(SocketStatus value) => _status = value;

  void connect() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString("token");
    if (token != "") {
      _channel = IOWebSocketChannel.connect("${Config.wsUrl}/ws?token=$token");
    } else {
      _channel = IOWebSocketChannel.connect("${Config.wsUrl}/ws");
    }
    _channel.stream.listen(this.onData, onError: onError, onDone: onDone);
  }

  void addMsgListener(String name, Function fun) {
    _funs[name] = fun;
  }

  void addConnectedListener(String name, Function fun) {
    _connectedFuns[name] = fun;
  }

  void delConnectedListener(String name) {
    _connectedFuns.remove(name);
  }

  void delMsgListener(String name) {
    _funs.remove(name);
  }

  void sendMessage(Map<String, dynamic> data) {
    print("消息发送${data}");
    String sendMessage = jsonEncode(data);
    if (_status == SocketStatus.connected) {
      _channel.sink.add(sendMessage);
    }
  }

  void onData(event) {
    if (_status != SocketStatus.connected) {
      _status = SocketStatus.connected;
      Vibrate.feedback(FeedbackType.medium);
      _connectedFuns.forEach((name, fun) {
        fun();
      });
      notifyListeners();
    }
    _funs.forEach((name, fun) {
      fun(jsonDecode(event));
    });
  }

  void onError(err) {
    print("socket 连接错误 ${err}");
    Vibrate.feedback(FeedbackType.error);
  }

  void onDone() {
    new Timer(const Duration(seconds: 3), () {
      print("socket 关闭重新连接");
      Vibrate.feedback(FeedbackType.warning);
      _status = SocketStatus.closed;
      notifyListeners();
      init();
    });
  }

  void init() async {
    connect();
  }
}
