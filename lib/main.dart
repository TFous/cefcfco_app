import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/routers/application.dart';
import 'package:cefcfco_app/routers/routers.dart';
import 'package:cefcfco_app/utils/request.dart';
import 'package:cefcfco_app/utils/shared_preferences.dart';
import 'package:cefcfco_app/views/home_page.dart';
import 'package:cefcfco_app/views/login_page.dart';
import 'package:cefcfco_app/utils/globals.dart' as globals;

SpUtil sp;

class MyApp extends StatelessWidget {
  MyApp()  {
    final router = new Router();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  showLoginPage() {
    bool isLogin = sp.getBool(globals.isLogin);
//    if (isLogin == true) {
//      return AppPage();
//    } else {
//      return LoginPage();
//    }

    return LoginPage();
  }

  @override
  Widget build(BuildContext context) {
    showLoginPage();
    return new MaterialApp(
      title: '华信期货',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Scaffold(
          body: showLoginPage()
      ),
      onGenerateRoute: Application.router.generator,
    );
  }
}


void main() async {
  sp = await SpUtil.getInstance();
  runApp(new MyApp());
}
