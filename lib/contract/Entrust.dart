import 'package:flutter/material.dart';
import 'package:vibrate/vibrate.dart';

class Entrust extends StatefulWidget {
  Entrust({Key key}) : super(key: key);

  @override
  _EntrustState createState() {
    return _EntrustState();
  }
}

class _EntrustState extends State<Entrust> {
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
    // TODO: implement build
    return Container(
      child: Column(
        children: <Widget>[
          RaisedButton(
            child: Text("heavy"),
            onPressed: (){
              Vibrate.feedback(FeedbackType.heavy);
            },
          ),
          RaisedButton(
            child: Text("selection"),
            onPressed: (){
              Vibrate.feedback(FeedbackType.selection);
            },
          ),
          RaisedButton(
            child: Text("warning"),
            onPressed: (){
              Vibrate.feedback(FeedbackType.warning);
            },
          ),
          RaisedButton(
            child: Text("error"),
            onPressed: (){
              Vibrate.feedback(FeedbackType.error);
            },
          ),
          RaisedButton(
            child: Text("success"),
            onPressed: (){
              Vibrate.feedback(FeedbackType.success);
            },
          ),
          RaisedButton(
            child: Text("medium"),
            onPressed: (){
              Vibrate.feedback(FeedbackType.medium);
            },
          ),
          RaisedButton(
            child: Text("light"),
            onPressed: (){
              Vibrate.feedback(FeedbackType.light);
            },
          ),
          RaisedButton(
            child: Text("impact"),
            onPressed: (){
              Vibrate.feedback(FeedbackType.impact);
            },
          )
        ],
      )
    );
  }
}
