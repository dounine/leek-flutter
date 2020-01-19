import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushEvent {
  String name;
  dynamic value;

  PushEvent(this.name, this.value);
}

class Config {
//  static final String httpUrl = "http://localhost:9000";
//  static final String wsUrl = "ws://localhost:9000";
   static final String httpUrl = "http://47.52.140.153:9000";
   static final String wsUrl = "ws://47.52.140.153:9000";
  static final EventBus eventBus = EventBus();
  static final Dio dio = new Dio(BaseOptions(
      baseUrl: httpUrl,
      connectTimeout: 5000,
      receiveTimeout: 5000,
      sendTimeout: 5000));
  static get setDioHeaderToken => (String token) async {
    Config.dio.options.headers["token"] = token;
  };
}
