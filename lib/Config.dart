import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushEvent {
  String name;
  dynamic value;

  PushEvent(this.name, this.value);
}

class Config {
  static final String httpUrl = "http://localhost:9000";
  static final String wsUrl = "ws://localhost:9000";
  static final EventBus eventBus = EventBus();
  static final Dio dio = new Dio(BaseOptions(
      baseUrl: httpUrl,
      connectTimeout: 5000,
      receiveTimeout: 5000,
      sendTimeout: 5000));
  static final setToken = () async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString("token") ?? "";
    Config.dio.options.headers["token"] = token;
  };
}
