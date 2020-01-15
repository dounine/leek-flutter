import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:leek/ContractPage.dart';
import 'package:leek/ContractTrade.dart';
import 'package:leek/profile/Profile.dart';
import 'package:leek/profile/auth/Api.dart';
import 'package:leek/profile/auth/Auth.dart';
import 'package:leek/profile/manager/ConfigEdit.dart';
import 'package:leek/profile/manager/ContractManager.dart';
import 'package:leek/profile/manager/ContractManagerEdit.dart';
import 'package:leek/profile/manager/Manager.dart';
import 'package:leek/profile/manager/OpenManager.dart';
import 'package:leek/profile/manager/OpenManagerEdit.dart';
import 'package:leek/profile/manager/OpenRequest.dart';
import 'package:leek/profile/manager/User.dart';
import 'package:leek/profile/manager/UserEdit.dart';
import 'package:leek/profile/setting/Setting.dart';
import 'package:leek/store/ContractStore.dart';
import 'package:leek/store/LoginStore.dart';
import 'package:leek/store/SocketStore.dart';
import 'package:leek/store/UserStore.dart';
import 'package:leek/wallet/Wallet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Config.dio.interceptors
      .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
    //是先锁定请求不发送出去，当整个取值添加到请求头后再dio.unlock()解锁发送出去
    Config.dio.lock();
    Future<dynamic> future = Future(() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString("token");
    });
    return future.then((value) {
      options.headers["token"] = value;
      return options;
    }).whenComplete(() => Config.dio.unlock());
  }, onResponse: (Response response) {
    // 在返回响应数据之前做一些预处理
    return response; // continue
  }, onError: (DioError e) {
    // 当请求失败时做一些预处理
    return e; //continue
  }));
//  (Config.dio.httpClientAdapter as DefaultHttpClientAdapter)
//      .onHttpClientCreate = (client) {
//    client.findProxy = (uri) {
//      return "PROXY localhost:1081";
//    };
//    client.badCertificateCallback =
//        (X509Certificate cert, String host, int port) => true;
//  };
  runApp(MyApp());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
}

class MyApp extends StatelessWidget {
  final ThemeData kDefaultTheme = new ThemeData(
      //默认的Material主题风格
      primaryColor: Colors.blue,
      backgroundColor: const Color(0xfff5f6f9)
//    accentColor: Colors.orangeAccent[400],
      );
  final LoginStore loginStore = LoginStore();
  final UserStore userStore = UserStore();
  final SocketStore socketStore = SocketStore();
  final ContractStore contractStore = ContractStore();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => loginStore,
          ),
          ChangeNotifierProvider(
            create: (_) => userStore,
          ),
          ChangeNotifierProvider(
            create: (_) => socketStore,
          ),
          ChangeNotifierProvider(
            create: (_) => contractStore,
          )
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: kDefaultTheme,
          home: Consumer<UserStore>(
            builder: (_, currentUser, child) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: currentUser.getWidget(),
              );
            },
          ),
          routes: <String, WidgetBuilder>{
            "/home": (BuildContext context) => const HomePage(),
            "/contractTrade": (BuildContext context) => const ContractTrade(),
            "/auth": (BuildContext context) => const Auth(),
            "/manager": (BuildContext context) => const Manager(),
            "/user": (BuildContext context) => const User(),
            "/user-edit": (BuildContext context) => const UserEdit(),
            "/open-request": (BuildContext context) => const OpenRequest(),
            "/open-manager": (BuildContext context) => const OpenManager(),
            "/config-edit": (BuildContext context) => const ConfigEdit(),
            "/open-manager-edit": (BuildContext context) =>
                const OpenManagerEdit(),
            "/contract-manager": (BuildContext context) =>
                const ContractManager(),
            "/contract-edit": (BuildContext context) =>
                const ContractManagerEdit(),
            "/api": (BuildContext context) => const Api(),
            "/setting": (BuildContext context) => const Setting(),
          },
        ));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 1;
  double _lowerValue = 10.0;
  double _upperValue = 30.0;
  Map<String, Widget> _widgetOptions;
  AnimationController controller;
  CurvedAnimation curved;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  void _onChange(double oldValue, double newValue) {}

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndex = index;
    });
    controller.forward();
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    curved = new CurvedAnimation(
        parent: controller,
        curve: const Interval(0.2, 1, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    if (_widgetOptions == null) {
      _widgetOptions = {
        "首页": Container(
          child: Center(
            child: Text(
              "咱们韭菜的信仰：追涨杀跌",
            ),
          ),
        ),
        "合约": ContractPage(),
        "钱包": Wallet(),
        "我": Profile()
      };
    }
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    return Scaffold(
      appBar: _widgetOptions.keys.toList()[_selectedIndex] != "钱包"
          ? AppBar(
              title: Consumer<SocketStore>(
                builder: (context, socketStore, child) {
                  return socketStore.status == SocketStatus.connected
                      ? Text(
                          _widgetOptions.keys.toList()[_selectedIndex],
                          style: TextStyle(color: Colors.white),
                        )
                      : SizedBox(
                          height: 24,
                          width: 24,
                          child: new CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  new AlwaysStoppedAnimation(Colors.white)),
                        );
                },
              ),
            )
          : null,
      body: _widgetOptions[_widgetOptions.keys.toList()[_selectedIndex]],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: _selectedIndex == 0
                  ? ScaleTransition(
                      scale: new Tween(begin: 1.0, end: 1.1).animate(curved),
                      child: Icon(Icons.home),
                    )
                  : Icon(Icons.home),
              title: Text("首页")),
          BottomNavigationBarItem(
              icon: _selectedIndex == 1
                  ? ScaleTransition(
                      scale: new Tween(begin: 1.0, end: 1.0).animate(curved),
                      child: Icon(Icons.content_paste),
                    )
                  : Icon(Icons.content_paste),
              title: Text("合约")),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), title: Text("钱包")),
          BottomNavigationBarItem(
              icon: _selectedIndex == 3
                  ? ScaleTransition(
                      scale: new Tween(begin: 1.0, end: 1.1).animate(curved),
                      child: Icon(
                        Icons.person_outline,
                      ),
                    )
                  : Icon(
                      Icons.person_outline,
                    ),
              title: Text("我")),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
