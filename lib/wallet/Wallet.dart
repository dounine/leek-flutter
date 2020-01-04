import 'package:flutter/material.dart';

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
    return Center(child: Text("你的钱包空空如也"));
  }
}
