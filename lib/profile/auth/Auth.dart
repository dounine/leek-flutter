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
