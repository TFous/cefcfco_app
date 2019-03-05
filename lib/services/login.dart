import 'package:cefcfco_app/utils/common.dart' as common;
import 'package:cefcfco_app/utils/globals.dart' as globals;
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

Dio dio = new Dio(); // 使用默认配置
class UserServices {
  static Future userLogin(String username, String password,{GlobalKey<ScaffoldState> scaffoldKey}) async {
    var url = '${globals.identityUrl}/connect/token';
    var data = {
      'username': username.toString().toLowerCase().trim(),
      'password': password.toString().trim(),
      'grant_type': globals.grantType,
      'scope': globals.scope
    };
    var bytes = utf8.encode('${globals.clientId}:${globals.clientSecret}');
    var base64Secret = base64.encode(bytes);
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };
    Response response;
    try {
      response = await dio.post(
          url,
          data:data,
          options:new Options(
              contentType: ContentType.parse("application/x-www-form-urlencoded"),
              headers: {"Authorization": "Basic $base64Secret"}));
    } on DioError catch (e) {
      if(e.response!=null && scaffoldKey !=null){
        var code = common.getCatchErrCode(e.response,scaffoldKey);
        return code;
      }
    }
    return response.data;
  }

  static Future getUser(Map<String, dynamic> params,[GlobalKey<ScaffoldState> scaffoldKey]) async {
    var url = '${globals.identityUrl}/connect/userinfo';
    var accessToken = params['access_token'];
    Response response;
    try {
      response = await dio.get(
          url, options:new Options(headers: {"Authorization": "Bearer $accessToken"}));
    } on DioError catch (e) {
      if(e.response!=null && scaffoldKey !=null){
        var code = common.getCatchErrCode(e.response,scaffoldKey);
        return code;
      }
    }
    return response.data;
  }
}
