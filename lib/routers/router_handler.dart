import 'package:cefcfco_app/views/about_page.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:cefcfco_app/views/login_page.dart';
import 'package:cefcfco_app/views/home_page.dart';
import 'package:cefcfco_app/views/page1/home_page.dart' as page1;

// 首次登录页
var loginHandler = new Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new LoginPage();
  },
);

// 主页
var homeHandler = new Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new AppPage();
  },
);


// 关于
var page1Handler = new Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new page1.AppPage();
  },
);
