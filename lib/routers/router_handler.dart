import 'package:cefcfco_app/views/changeSecondPassword_page.dart';
import 'package:cefcfco_app/views/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:cefcfco_app/views/login_page.dart';
import 'package:cefcfco_app/views/home_page.dart';
import 'package:cefcfco_app/components/AppWrap.dart';
import 'package:cefcfco_app/views/page1/home_page.dart' as page1;
import 'package:cefcfco_app/views/KlinePage/DayKLine_page.dart';
import 'package:cefcfco_app/views/KlinePage/MinKLine_page.dart';



// 首次登录页
var loginHandler = new Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new AppWrap(
      child: new LoginPage(),
    );
  },
);

// 主页
var homeHandler = new Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new AppWrap(
      child: new AppPage(),
    );
  },
);


// 关于
var page1Handler = new Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
//    return new page1.AppPage();
    return new AppWrap(
      child: new page1.AppPage(),
    );
  },
);

// 设置列表页
var settingHandler = new Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new AppWrap(
      child: new SettingPage(),
    );
//    return new SettingPage();
  },
);

// 设置列表页
var changeSecondPasswordHandler = new Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new AppWrap(
      child: new ChangeSecondPasswordPage(),
    );
//    return new ChangeSecondPasswordPage();
  },
);


//  k线行情图
var dayKlinePageHandler = new Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new AppWrap(
      child: new DayKLine(),
    );
//    return new ChangeSecondPasswordPage();
  },
);

//  分时行情图
var minKlinePageHandler = new Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new AppWrap(
      child: new MinKLine(),
    );
//    return new ChangeSecondPasswordPage();
  },
);