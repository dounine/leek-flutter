import 'package:flutter/material.dart';
import 'package:leek/store/UserStore.dart';
import 'package:provider/provider.dart';

class Profile extends StatelessWidget {
  Profile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: new ListTile(
                leading: const Icon(
                  Icons.person_outline,
                  size: 36,
                ),
                title: Text(
                  Provider.of<UserStore>(context).phone,
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18),
                ),
                trailing: Icon(Icons.keyboard_arrow_right)),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            color: Colors.white,
            child: ListTile(
                leading: const Icon(Icons.security),
                title: const Text("授权"),
                onTap: (){
                  Navigator.pushNamed(context, '/auth');
                },
                trailing: Icon(Icons.keyboard_arrow_right)),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            color: Colors.white,
            child: ListTile(
                leading: const Icon(Icons.scatter_plot),
                title: const Text("管理"),
                onTap: (){
                  Navigator.pushNamed(context, '/manager');
                },
                trailing: Icon(Icons.keyboard_arrow_right)),
          ),
          SizedBox(
            height: 20,
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
