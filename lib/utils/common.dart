import 'dart:ui';

import 'package:flutter/material.dart';

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

/**
 *  提示信息，
 *  text 文字
 *
 */
void showInSnackBar(String text,GlobalKey<ScaffoldState> scaffoldKey) {
  scaffoldKey.currentState?.removeCurrentSnackBar();
  scaffoldKey.currentState.showSnackBar(new SnackBar(
    content: new Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
          color: Colors.white,
          fontSize: 13.0),
    ),
    backgroundColor: Colors.red,
    duration: Duration(seconds: 3),
  ));
}

num getCatchErrCode(response,scaffoldKey){
  var code = response.statusCode;
  if (code==200) {
    return code;
  }else{
    var code = response.statusCode.toString();
    var errMsg = codeMessage[code];
    showInSnackBar(errMsg,scaffoldKey);
  }
  return code;
}
