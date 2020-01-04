import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/store/UserStore.dart';
import 'package:provider/provider.dart';

class Profile extends StatelessWidget {
  Profile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: ScreenUtil.instance.setHeight(20),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: new ListTile(
                leading: const Icon(
                  Icons.person_outline,
                ),
                title: Text(
                  Provider.of<UserStore>(context).phone,
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                trailing: Icon(Icons.keyboard_arrow_right)),
          ),
          SizedBox(
            height: ScreenUtil.instance.setHeight(40),
          ),
          Container(
            color: Colors.white,
            child: ListTile(
                leading: const Icon(Icons.security),
                title: const Text("授权"),
                onTap: () {
                  Navigator.pushNamed(context, '/auth');
                },
                trailing: Icon(Icons.keyboard_arrow_right)),
          ),
          SizedBox(
            height: ScreenUtil.instance.setHeight(40),
          ),
          Container(
            color: Colors.white,
            child: ListTile(
                leading: const Icon(Icons.scatter_plot),
                title: const Text("管理"),
                onTap: () {
                  Navigator.pushNamed(context, '/manager');
                },
                trailing: Icon(Icons.keyboard_arrow_right)),
          ),
          SizedBox(
            height: ScreenUtil.instance.setHeight(40),
          ),
          Container(
            color: Colors.white,
            child: new ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("设置"),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  Navigator.pushNamed(context, '/setting');
                }),
          )
        ],
      ),
    );
  }
}
