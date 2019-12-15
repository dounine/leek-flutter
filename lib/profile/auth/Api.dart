import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/store/UserStore.dart';
import 'package:provider/provider.dart';

class Api extends StatefulWidget {
  const Api({Key key}) : super(key: key);

  @override
  _ApiState createState() {
    return _ApiState();
  }
}

class _ApiState extends State<Api> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  UserStore userStore;
  String status;
  String preApiKey;
  String preApiSecret;
  BuildContext _context;

  @override
  Widget build(BuildContext context) {
    if (userStore == null) {
      userStore = Provider.of<UserStore>(context);
      userStore.initApi((status, msg) {
        if (status != "ok" && _context != null) {
          Scaffold.of(_context).showSnackBar(SnackBar(
              content: Row(
            children: <Widget>[
              Icon(Icons.error_outline),
              SizedBox(
                width: 10,
              ),
              new Text(""),
              SizedBox(
                width: 0,
              ),
              new Text(
                msg,
                style: TextStyle(color: Colors.red),
              )
            ],
          )));
        }
      });
      preApiKey = userStore.apiKey;
      status = userStore.status;
      preApiSecret = userStore.apiSecret;
    }
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("API授权"),
        ),
        body: new Builder(
          builder: (context) {
            _context = context;
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
                              store.apiKey = value;
                            },
                            controller: TextEditingController.fromValue(
                                TextEditingValue(
                                    text: store.apiKey,
                                    selection: TextSelection.fromPosition(
                                        TextPosition(
                                            affinity: TextAffinity.downstream,
                                            offset: store.apiKey.length)))),
                            decoration: InputDecoration(
                                labelText: "Key", helperText: "密钥Key"));
                      },
                    ),
                  ),
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
                            obscureText: !store.showSecret,
                            onChanged: (value) {
                              store.apiSecret = value;
                            },
                            controller: TextEditingController.fromValue(
                                TextEditingValue(
                                    text: store.apiSecret,
                                    selection: TextSelection.fromPosition(
                                        TextPosition(
                                            affinity: TextAffinity.downstream,
                                            offset: store.apiSecret.length)))),
                            decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      store.showSecret = !store.showSecret;
                                    },
                                    icon: Icon(
                                      Icons.visibility,
                                      color: Colors.blue[200],
                                    )),
                                labelText: "Secret",
                                helperText: "密钥Secret"));
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "登录网页火币后、在API管理可创建API Key\n创建的时候权限设置需要勾选交易选项",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )),
                  SizedBox(
                    height: ScreenUtil.instance.setHeight(30),
                  ),
                  Consumer<UserStore>(
                    builder: (_, store, child) {
                      return (store.status == "request" || store.status == "")
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : FractionallySizedBox(
                              widthFactor: 0.96,
                              child: MaterialButton(
                                color: Colors.blue,
                                textColor: Colors.white,
                                height: ScreenUtil.instance.setHeight(90),
                                child: new Text("保存"),
                                onPressed: (store.apiKey == "" ||
                                        store.apiSecret == "")
                                    ? null
                                    : () {
                                        userStore.saveApi((status, msg) {
                                          if (status != "success") {
                                            preApiKey = userStore.apiKey;
                                            preApiSecret = userStore.apiSecret;
                                          }
                                          Scaffold.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Row(
                                            children: <Widget>[
                                              Icon(status == "success"
                                                  ? Icons.check_circle_outline
                                                  : Icons.error_outline),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              new Text(
                                                status == "success" ? "保存成功" : "",
                                              ),
                                              SizedBox(
                                                width: status == "success" ? 10 : 0,
                                              ),
                                              new Text(
                                                msg,
                                                style: TextStyle(
                                                    color: Colors.red),
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
          },
        ));
  }
}
