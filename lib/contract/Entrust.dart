import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/contract/LimitEntrust.dart';
import 'package:leek/contract/PlanEntrust.dart';
import 'package:leek/store/ContractStore.dart';
import 'package:provider/provider.dart';
import 'package:vibrate/vibrate.dart';

class Entrust extends StatefulWidget {
  Entrust({Key key}) : super(key: key);

  @override
  _EntrustState createState() {
    return _EntrustState();
  }
}

class _EntrustState extends State<Entrust> {
  String type = "limit";
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
    ContractStore contractStore = Provider.of<ContractStore>(context);
    return Container(
        child: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            FlatButton(
              textColor: type == "limit" ? Colors.black87 : Colors.grey,
              onPressed: () {
                setState(() {
                  type = "limit";
                });
                Vibrate.feedback(FeedbackType.light);
              },
              child:
                  Text("限价委托", style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            FlatButton(
              textColor: type == "plan" ? Colors.black87 : Colors.grey,
              onPressed: () {
                setState(() {
                  type = "plan";
                });
                Vibrate.feedback(FeedbackType.light);
              },
              child:
                  Text("计划委托", style: TextStyle(fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        SizedBox(
          height: ScreenUtil.instance.setHeight(30),
        ),
        type == "limit"
            ? LimitEntrust(
                symbol: contractStore.symbol,
                contractType: contractStore.contractType)
            : PlanEntrust(
                symbol: contractStore.symbol,
                contractType: contractStore.contractType),
      ],
    ));
  }
}
