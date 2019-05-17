library globals;
import 'package:flutter/material.dart';


String identityUrl = 'https://identity-wucc.apps.dev-cefcfco.com';
String wuccUrl = 'https://admin-wucc.apps.dev-cefcfco.com';
String keyValueUrl = 'https://api-platform.apps.dev-cefcfco.com';


// 新浪财经行业分类列表
String minuteUrl = 'https://stock.caixin.com/cgi/StockRealTimeLineFiveData';
String dustryUrl = 'https://stock.caixin.com/cgi';


String kUrl = 'http://pdfm.eastmoney.com/EM_UBG_PDTI_Fast/api/js';


String scope = 'openid role ewip permission roledatapermission';
String grantType = 'password';
String clientId = 'test';
String clientSecret = 'secret';

// 等候后存储用户名
String userName = 'userName';
String accessToken = 'accessToken';
String isLogin = 'no';



List homePageTabData = [
  {
    'text': '首页',
    'icon': new Icon(Icons.home),
    'isShowBadge': true,
    'badgeData':{
      'num': 'new',
    }
  },
//  {'text': '动态','isShowBadge': false, 'icon': new Icon(Icons.filter_vintage)},
  {'text': '列表','isShowBadge': false, 'icon': new Icon(Icons.list)},
  {'text': '我的', 'isShowBadge': false,'icon': new Icon(Icons.person)},
];


List myPageTabData = [
  {'text': '新增','isShowBadge': false, 'icon': new Icon(Icons.add)},
  {'text': '列表','isShowBadge': false, 'icon': new Icon(Icons.dashboard)},
];

double sidesDistance = 10.0;

double horizontalDistance = 2.0;

const DEBUG = true;
