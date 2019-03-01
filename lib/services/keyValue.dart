import 'dart:async';

import 'package:cefcfco_app/utils/request.dart';
import 'package:cefcfco_app/utils/globals.dart' as globals;
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';


// ignore: camel_case_types
class keyValuesServices {
  static Future getKeyValueList([GlobalKey<ScaffoldState> scaffoldKey]) async {
    var url = '${globals.keyValueUrl}/hrservice/api/keyValue';
    var response = await Request.get(url,scaffoldKey:scaffoldKey);
    return response;
  }
}
