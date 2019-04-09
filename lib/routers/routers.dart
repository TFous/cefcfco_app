import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import './router_handler.dart';

import 'package:cefcfco_app/common/utils/router_config.dart' as routerConfig;

class Routes {
  static void configureRoutes(Router router) {
    router.notFoundHandler = new Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
        });
    router.define(routerConfig.login, handler: loginHandler);
    router.define(routerConfig.home, handler: homeHandler);
    router.define(routerConfig.page1, handler: page1Handler);
    router.define(routerConfig.setting, handler: settingHandler);
    router.define(routerConfig.changeSecondPassword, handler: changeSecondPasswordHandler);
  }
}
