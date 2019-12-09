import 'package:cefcfco_app/common/utils/common.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/routers/application.dart';
import 'package:cefcfco_app/routers/routers.dart';
import 'package:cefcfco_app/common/utils/request.dart';
import 'package:cefcfco_app/common/utils/shared_preferences.dart';
import 'package:cefcfco_app/views/home_page.dart';
import 'package:cefcfco_app/views/login_page.dart';
import 'package:cefcfco_app/common/utils/globals.dart' as globals;
//import 'package:flutter_jpush/flutter_jpush.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cefcfco_app/common/localization/LanguageLocalizationsDelegate.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:cefcfco_app/redux/AppState.dart';
import 'package:redux/redux.dart';

void main() async {
  sp = await SpUtil.getInstance();
  runApp(new MyApp());
}

SpUtil sp;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp>{
  bool isConnected = false;
  String registrationId;
  List notificationList = [];
//  final Locale locale;
  final store = new Store<AppStates>(
    appReducer,
    ///初始化数据
    initialState: new AppStates(
        themeData: CommonUtils.getThemeData(Colors.teal),
        isFocus: false,
        locale: Locale('zh', 'CH')),
  );

  _MyAppState();

  @override
  void initState() {
    super.initState();
//    _startupJpush();
    _initRouter();
  }

  void _startupJpush() async {
    print("初始化jpush");
//    await FlutterJPush.startup();
    print("初始化jpush成功");
  }

  void _initRouter() {
    final router = new Router();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  showLoginPage() {
    bool isLogin = sp.getBool(globals.isLogin);
//    if (isLogin == true) {
//      refreshToken();
//    return new AppPage();
//    } else {
//    return new LoginPage();
//    }
    return LoginPage();
  }

  refreshToken() async {
    //    设置 dio 的token
  }

  @override
  Widget build(BuildContext context) {
    return new StoreProvider(
      store: store,
      child: new StoreBuilder<AppStates>(builder: (context, store) {
        return new MaterialApp(
          ///多语言实现代理
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              LanguageLocalizationsDelegate.delegate,
            ],
            locale: store.state.locale,
            supportedLocales: [store.state.locale],
            theme: store.state.themeData,
            home: new Scaffold(body: showLoginPage()),
            onGenerateRoute: Application.router.generator,
            );
      }),
    );
  }
}
