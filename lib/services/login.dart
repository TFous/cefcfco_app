import 'package:cefcfco_app/utils/globals.dart' as globals;
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/utils/request.dart';

class LoginServices {
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
    var response = await Request.post(
        url,
        params:data,
        options:new Options(
            contentType: ContentType.parse("application/x-www-form-urlencoded"),
            headers: {"Authorization": "Basic $base64Secret"}));
    return response;
  }

  static Future getUser(Map<String, dynamic> params,[GlobalKey<ScaffoldState> scaffoldKey]) async {
    var url = '${globals.identityUrl}/connect/userinfo';
    var accessToken = params['access_token'];
    var response = await Request.get(
        url, options: new Options(
        headers: {"Authorization": "Bearer $accessToken"}));
    return response;
  }
}
