import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Wallet extends StatefulWidget {
  Wallet({Key key}) : super(key: key);

  @override
  _WalletState createState() {
    return _WalletState();
  }
}

class _WalletState extends State<Wallet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: <Widget>[
          FlatButton(
            child: Text("heavyImpact"),
            onPressed: () {
              HapticFeedback.heavyImpact();
            },
          ),
          FlatButton(
            child: Text("lightImpact"),
            onPressed: () {
              HapticFeedback.lightImpact();
            },
          ),
          FlatButton(
            child: Text("mediumImpact()"),
            onPressed: () {
              HapticFeedback.mediumImpact();
            },
          ),
          FlatButton(
            child: Text("selectionClick()"),
            onPressed: () {
              HapticFeedback.selectionClick();
            },
          ),
          FlatButton(
            child: Text("vibrate()"),
            onPressed: () {
              HapticFeedback.vibrate();
            },
          )
        ],
      ),
    );
  }
}
