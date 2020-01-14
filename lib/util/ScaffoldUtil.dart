import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScaffoldUtil {
  static void show(BuildContext context, Map<String, dynamic> data,
      {String msg}) {
    if (context == null) {
      print("context 不能为空");
    } else {
      IconData icon = Icons.check_circle_outline;
      if (data["status"] == "fail") {
        icon = Icons.error_outline;
      } else if (data["status"] == "timeout") {
        icon = Icons.access_time;
      }
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Row(
        children: <Widget>[
          Icon(icon),
          SizedBox(
            width: 10,
          ),
          SizedBox(
            width: 0,
          ),
          new Text(
            msg ?? (data["status"] == "timeout" ? "请求超时" : data['msg']),
            style: TextStyle(
                color: data["status"] != "ok" ? Colors.red : Colors.white),
          )
        ],
      )));
    }
  }
}
