import 'package:cefcfco_app/utils/request.dart';
import 'package:cefcfco_app/utils/globals.dart' as globals;
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';

Dio dio = new Dio(); // 使用默认配置
class UserServices {
  static Future userLogin(String username, String password) async {
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
      //404
      response = await dio.post(
          url,
          data:data,
          options:new Options(
              contentType: ContentType.parse("application/x-www-form-urlencoded"),
              headers: {"Authorization": "Basic $base64Secret"}));
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        return e.response.statusCode;
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.request);
        print(e.message);
      }
    }


    return response.data;
  }

  static Future getUser(Map<String, dynamic> params) async {
    var url = '${globals.identityUrl}/connect/userinfo';
    var accessToken = params['access_token'];
    Response response = await dio.get(
        url, options:new Options(headers: {"Authorization": "Bearer $accessToken"}));
    return response.data;
  }
}
