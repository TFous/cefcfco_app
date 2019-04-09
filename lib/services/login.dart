import 'package:cefcfco_app/common/utils/globals.dart' as globals;
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/common/net/request.dart';

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
    var response = await Request.netFetch(
        url,
        params:data,
        options:new Options(
            method: "post",
            contentType: ContentType.parse("application/x-www-form-urlencoded"),
            headers: {
              "Authorization": "Basic $base64Secret"}));
    return response;
  }

  static Future getUser({GlobalKey<ScaffoldState> scaffoldKey}) async {
    var url = '${globals.identityUrl}/connect/userinfo';
    var response = await Request.netFetch(
        url);
    return response;
  }
}
