import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:cefcfco_app/common/utils/shared_preferences.dart';
import 'package:cefcfco_app/common/utils/globals.dart' as globals;
import 'package:cefcfco_app/common/utils/common.dart' as common;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

Dio dio;

class Request {
  static void setDio() async {
    var sp = await SpUtil.getInstance();
    String accessToken = sp.getString(globals.accessToken);
    if (accessToken!=null) {
      dio = new Dio(new BaseOptions(
        connectTimeout: 5000,
        receiveTimeout: 100000,
        headers: {"Authorization": 'Bearer $accessToken'},
      ));
    } else {
      dio = new Dio();
    }
  }

  static void setHttpsVerification() {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };
  }

  static Future get(String url,
      {Map<String, dynamic> params,
        Options options,
      GlobalKey<ScaffoldState> scaffoldKey}) async {
    setHttpsVerification();
    var response;
    try {
      response = await dio.get(url,queryParameters: params,options:options);
    } on DioError catch (e) {
      if (e.response != null && scaffoldKey != null) {
        var code = common.getCatchErrCode(e.response, scaffoldKey);
        return code;
      }
    }
    return response.data;
  }

  static Future post(String url,
      {Map<String, dynamic> params,
      Options options,
      GlobalKey<ScaffoldState> scaffoldKey}) async {
    setHttpsVerification();
    Response response;
    try {
      response = await dio.post(url, data: params, options: options);
    } on DioError catch (e) {
      if (e.response != null && scaffoldKey != null) {
        var code = common.getCatchErrCode(e.response, scaffoldKey);
        return code;
      }
    }
    return response.data;
  }
}
