import 'dart:async';

import 'package:cefcfco_app/net/Code.dart';
import 'package:cefcfco_app/net/HttpErrorEvent.dart';
import 'package:cefcfco_app/style/theme.dart';
import 'package:cefcfco_app/utils/common.dart';
import 'package:event_bus/event_bus.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/routers/application.dart';
import 'package:cefcfco_app/routers/routers.dart';
import 'package:cefcfco_app/utils/request.dart';
import 'package:cefcfco_app/utils/shared_preferences.dart';
import 'package:cefcfco_app/views/home_page.dart';
import 'package:cefcfco_app/views/login_page.dart';
import 'package:cefcfco_app/utils/globals.dart' as globals;
import 'package:flutter_jpush/flutter_jpush.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cefcfco_app/localization/LanguageLocalizationsDelegate.dart';
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
        locale: Locale('zh', 'CH')),
  );

  _MyAppState();


  @override
  void initState() {
    super.initState();
    _startupJpush();
    _initRouter();
  }

  void _startupJpush() async {
    print("初始化jpush");
    await FlutterJPush.startup();
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
//    return new AppWrap(
//      child: new AppPage(),
//    );
//    } else {
//    return new AppWrap(
//      child: new LoginPage(),
//    );
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

class AppWrap extends StatefulWidget {
  final Widget child;

  AppWrap({Key key, this.child}) : super(key: key);

  @override
  State<AppWrap> createState() {
    return new _AppWrap();
  }
}

class _AppWrap extends State<AppWrap>{
  StreamSubscription stream;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new StoreBuilder<AppStates>(builder: (context, store) {
      ///通过 StoreBuilder 和 Localizations 实现实时多语言切换
      return new Localizations.override(
        context: context,
        locale: store.state.locale,
        child: widget.child,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    stream =  Code.eventBus.on<HttpErrorEvent>().listen((event) {
      errorHandleFunction(event.code, event.message);
    });
  }

  @override
  void dispose() {
    super.dispose();
    if(stream != null) {
      stream.cancel();
      stream = null;
    }
  }

  errorHandleFunction(int code, message) {

  }
}