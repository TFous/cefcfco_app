import 'dart:async';
import 'package:cefcfco_app/common/utils/request.dart';
import 'package:cefcfco_app/common/utils/globals.dart' as globals;
import 'package:flutter/material.dart';

class KeyValuesServices {
  static Future getKeyValueList([GlobalKey<ScaffoldState> scaffoldKey]) async {
    var url = '${globals.keyValueUrl}/hrservice/api/keyValue';
    var response = await Request.get(url,scaffoldKey:scaffoldKey);
    return response;
  }
}
