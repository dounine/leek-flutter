import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/store/UserStore.dart';
import 'package:provider/provider.dart';

class Session extends StatefulWidget {
  const Session({Key key}) : super(key: key);

  @override
  _SessionState createState() {
    return _SessionState();
  }
}

class _SessionState extends State<Session> {
  @override
  void initState() {
    super.initState();
  }

  UserStore userStore;
  String preSessionId;

  @override
  void dispose() {
    userStore.webSession = preSessionId;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (userStore == null) {
      userStore = Provider.of<UserStore>(context);
      userStore.initWebSession();
      preSessionId = userStore.webSession;
    }
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    return new Scaffold(
      appBar: AppBar(
        title: Text("网页会话"),
      ),
      body: new Builder(builder: (context) {
        return Container(
          color: Colors.grey[100],
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(left: 14, right: 14, bottom: 6),
                child: Consumer<UserStore>(
                  builder: (_, store, child) {
                    return TextField(
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          store.webSession = value;
                        },
                        controller: TextEditingController.fromValue(
                            TextEditingValue(
                                text: store.webSession,
                                selection: TextSelection.fromPosition(
                                    TextPosition(
                                        affinity: TextAffinity.downstream,
                                        offset: store.webSession.length)))),
                        decoration: InputDecoration(
                            labelText: "会话ID",
                            helperText:
                                "使用浏览器登录帐号后、\n打开网络控制台某个API接口即可查看hbsession"));
                  },
                ),
              ),
              SizedBox(
                height: ScreenUtil.instance.setHeight(30),
              ),
              Consumer<UserStore>(
                builder: (_, store, child) {
                  print(store.webSession);
                  return store.status == "request"
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : FractionallySizedBox(
                          widthFactor: 0.96,
                          child: MaterialButton(
                            color: Colors.blue,
                            textColor: Colors.white,
                            height: ScreenUtil.instance.setHeight(90),
                            child: const Text("保存"),
                            onPressed: store.webSession == ""
                                ? null
                                : () {
                                    userStore.saveWebSession((status, msg) {
                                      if (status != "ok") {
                                        preSessionId = userStore.webSession;
                                      }
                                      Scaffold.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Row(
                                        children: <Widget>[
                                          Icon(status == "ok"
                                              ? Icons.check_circle_outline
                                              : Icons.error_outline),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          new Text(
                                            status == "ok" ? "保存成功" : "",
                                          ),
                                          SizedBox(
                                            width: status == "ok" ? 10 : 0,
                                          ),
                                          new Text(
                                            msg,
                                            style: TextStyle(color: Colors.red),
                                          )
                                        ],
                                      )));
                                    });
                                  },
                          ),
                        );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
