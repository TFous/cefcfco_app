library globals;
import 'package:flutter/material.dart';


String identityUrl = 'https://identity-wucc.apps.dev-cefcfco.com';
String keyValueUrl = 'https://api-platform.apps.dev-cefcfco.com';

String scope = 'openid role ewip permission roledatapermission';
String grantType = 'password';
String clientId = 'test';
String clientSecret = 'secret';

String userName = 'userName';
String accessToken = 'accessToken';

String isLogin = 'no';

Map<String, dynamic> codeMessage = {
  '200': '服务器成功返回请求的数据。',
  '201': '新建或修改数据成功。',
  '202': '一个请求已经进入后台排队（异步任务）。',
  '204': '删除数据成功。',
  '400': '发出的请求有错误，服务器没有进行新建或修改数据的操作。',
  '401': '认证失败（令牌、用户名、密码错误）。',
  '403': '访问被禁止。',
  '404': '发出的请求针对的是不存在的记录，服务器没有进行操作。',
  '406': '请求的格式不可得。',
  '410': '请求的资源被永久删除，且不会再得到的。',
  '422': '当创建一个对象时，发生一个验证错误。',
  '500': '服务器发生错误，请检查服务器。',
  '502': '网关错误。',
  '503': '服务不可用，服务器暂时过载或维护。',
  '504': '网关超时。',
};

List homePageTabData = [
  {'text': '首页', 'router':'/home','icon': new Icon(Icons.language)},
  {'text': '动态', 'router':'/home', 'icon': new Icon(Icons.extension)},
  {'text': '我的','router':'/about', 'icon': new Icon(Icons.favorite)},
];


List myPageTabData = [
  {'text': '222', 'router':'/home','icon': new Icon(Icons.edit)},
  {'text': '333', 'router':'/home', 'icon': new Icon(Icons.add)},
  {'text': '444','router':'/about', 'icon': new Icon(Icons.dashboard)},
];