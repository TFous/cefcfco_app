import 'package:cefcfco_app/utils/request.dart';
import 'package:cefcfco_app/utils/globals.dart' as globals;
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';

Dio dio = new Dio(); // 使用默认配置
class UserServices {
  static Future<Map> userLogin(String username, String password) async {
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
    Response response = await dio.post(
        url,
        data:data,
        options:new Options(
            contentType: ContentType.parse("application/x-www-form-urlencoded"),
            headers: {"Authorization": "Basic $base64Secret"}));

    return response.data;
  }

  static Future<Map> getUser(Map<String, dynamic> params) async {
    var url = '${globals.identityUrl}/connect/userinfo';
    var accessToken = params['access_token'];
    Response response = await dio.get(
        url, options:new Options(headers: {"Authorization": "Bearer $accessToken"}));
    return response.data;
  }
}
