import 'package:cefcfco_app/utils/request.dart';
import 'package:cefcfco_app/utils/globals.dart' as globals;
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';


// ignore: camel_case_types
class keyValuesServices {
  static Future<Map> getKeyValueList() async {
    var url = '${globals.keyValueUrl}/hrservice/api/keyValue';
    var response = await Request.get(url,{});
    return response;
  }
}
