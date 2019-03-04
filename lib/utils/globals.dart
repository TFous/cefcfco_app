library globals;
import 'package:flutter/material.dart';


String identityUrl = 'https://identity-wucc.apps.dev-cefcfco.com';
String keyValueUrl = 'https://api-platform.apps.dev-cefcfco.com';

String scope = 'openid role ewip permission roledatapermission';
String grantType = 'password';
String clientId = 'test';
String clientSecret = 'secret';

// 等候后存储用户名
String userName = 'userName';
String accessToken = 'accessToken';
String isLogin = 'no';



List homePageTabData = [
  {'text': '首页', 'router':'/home','icon': new Icon(Icons.home)},
  {'text': '动态', 'router':'/about', 'icon': new Icon(Icons.filter_vintage)},
  {'text': '列表', 'router':'/about', 'icon': new Icon(Icons.list)},
  {'text': '我的','router':'/user', 'icon': new Icon(Icons.person)},
];


List myPageTabData = [
  {'text': '编辑', 'router':'/home','icon': new Icon(Icons.edit)},
  {'text': '新增', 'router':'/home', 'icon': new Icon(Icons.add)},
  {'text': '列表','router':'/about', 'icon': new Icon(Icons.dashboard)},
];

double sidesDistance = 10.0;
