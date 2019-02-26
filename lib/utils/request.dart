import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:cefcfco_app/utils/shared_preferences.dart';
import 'package:cefcfco_app/utils/globals.dart' as globals;

Dio dio;

class Request {
  static void setDio () async {
    var sp = await SpUtil.getInstance();
    String accessToken = sp.getString(globals.accessToken);
    dio = new Dio(new BaseOptions(
      connectTimeout: 5000,
      receiveTimeout: 100000,
      // 5s
      headers: {"Authorization": 'Bearer $accessToken'},
    ));
  }

  static void setHttpsVerification (){
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };
  }

  static Future get(String url,Map<String, dynamic> params) async {
    setHttpsVerification();
    Response response;
    response = await dio.get(url, queryParameters: params);
    return response.data;
  }

  static Future post(String url, Map<String, dynamic> params,Options options) async {
    setHttpsVerification();
    var response = await dio.post(url, data: params,options:options);
    return response.data;
  }


}
