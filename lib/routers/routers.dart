import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import './router_handler.dart';

class Routes {
  static String root = "/";
  static String login = "/login";
  static String home = "/home";
  static String user = "/user";
  static String page1 = "/page1";
  static String about = "/about";
  static String webViewPage = '/web-view-page';

  static void configureRoutes(Router router) {
    router.notFoundHandler = new Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
        });
    router.define(login, handler: loginHandler);
    router.define(home, handler: homeHandler);
    router.define(page1, handler: page1Handler);

  }
}
