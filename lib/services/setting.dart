import 'dart:async';
import 'package:cefcfco_app/common/utils/request.dart';
import 'package:cefcfco_app/common/utils/globals.dart' as globals;
import 'package:flutter/material.dart';

class SettingServices {
  static Future changeAndSetSecondPassword(params,[GlobalKey<ScaffoldState> scaffoldKey]) async {
    var url = '${globals.wuccUrl}/api/services/app/SecondPassword/CreateOrUpdate';
    var response = await Request.post(url,params:params,scaffoldKey:scaffoldKey);
    return response;
  }
}
