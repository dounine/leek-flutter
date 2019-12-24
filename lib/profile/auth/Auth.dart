import 'package:flutter/material.dart';

class Auth extends StatelessWidget {
  const Auth({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: Text("授权"),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              // Container(
              //   color: Colors.white,
              //   child: new ListTile(
              //       leading: new Icon(Icons.http),
              //       title: const Text("网页会话"),
              //       onTap: (){
              //         Navigator.pushNamed(context, "/session");
              //       },
              //       trailing: Icon(Icons.keyboard_arrow_right)),
              // ),
              // SizedBox(
              //   height: 1,
              //   child: Container(
              //     margin: EdgeInsets.only(left: 16),
              //     color: Colors.grey[200],
              //   ),
              // ),
              Container(
                color: Colors.white,
                child: new ListTile(
                    leading: new Icon(Icons.https),
                    title: const Text("API"),
                    onTap: (){
                      Navigator.pushNamed(context, "/api");
                    },
                    trailing: Icon(Icons.keyboard_arrow_right)),
              ),
            ],
          ),
        ));
  }
}
