import 'dart:collection';
import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:cefcfco_app/utils/shared_preferences.dart';
import 'package:cefcfco_app/utils/globals.dart' as globals;
import 'package:cefcfco_app/net/ResultData.dart';
import 'package:cefcfco_app/net/Code.dart';
import 'package:cefcfco_app/utils/common.dart' as common;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

Dio dio = new Dio();

class Request {
  static Map optionParams = {
    "timeoutMs": 15000,
    "Authorization": null,
  };

  static void setHttpsVerification() {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };
  }

  static netFetch(url,{Map<String, dynamic> params, Options options, Map<String, dynamic> header,noTip = false}) async {
    var accessToken = await getAuthorization();
    var defaultHeaders = {
      "timeoutMs": 15000,
      "Authorization": accessToken??options.headers['Authorization'],
    };
    //没有网络
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return new ResultData(Code.errorHandleFunction(Code.NETWORK_ERROR, "", noTip), false, Code.NETWORK_ERROR);
    }

    if(accessToken!=null){
      defaultHeaders["Authorization"] = accessToken;
    }

    if (options == null) {
      options = new Options(
          method: "get",
          headers: defaultHeaders);
    }

    ///超时
    options.connectTimeout = 15000;
    setHttpsVerification();
    Response response;
    try {
      response = await dio.request(url, data: params, options: options);
    } on DioError catch (e) {
      Response errorResponse;
      if (e.response != null) {
        errorResponse = e.response;
      } else {
        errorResponse = new Response(statusCode: 666);
      }
      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        errorResponse.statusCode = Code.NETWORK_TIMEOUT;
      }
      if (globals.DEBUG) {
        print('请求异常: ' + e.toString());
        print('请求异常url: ' + url);
      }
      return new ResultData(Code.errorHandleFunction(errorResponse.statusCode, e.message, noTip), false, errorResponse.statusCode);
    }

    if (globals.DEBUG) {
      print('请求url: ' + url);
      print('请求头: ' + options.headers.toString());
      if (params != null) {
        print('请求参数: ' + params.toString());
      }
      if (response != null) {
        print('返回参数: ' + response.toString());
      }
      if (optionParams["Authorization"] != null) {
        print('Authorization: ' + optionParams["Authorization"]);
      }
    }

    try {
      if (options.contentType != null && options.contentType.primaryType == "text") {
        return new ResultData(response.data, true, Code.SUCCESS);
      } else {
        var responseJson = response.data;
        if (response.statusCode == 201 && responseJson["token"] != null) {
//          optionParams["Authorization"] = 'token ' + responseJson["token"];
//          await LocalStorage.save(Config.TOKEN_KEY, optionParams["Authorization"]);
        }
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return new ResultData(response.data, true, Code.SUCCESS, headers: response.headers);
      }
    } catch (e) {
      print(e.toString() + url);
      return new ResultData(response.data, false, response.statusCode, headers: response.headers);
    }
    return new ResultData(Code.errorHandleFunction(response.statusCode, "", noTip), false, response.statusCode);
  }
  ///获取授权token
  static getAuthorization() async {
    var sp = await SpUtil.getInstance();
    String accessToken = sp.getString(globals.accessToken);
    if (accessToken != null) {
      return 'Bearer $accessToken';
    }
  }
}
