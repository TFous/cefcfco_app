import 'dart:async';
import 'package:cefcfco_app/common/net/request.dart';
import 'package:cefcfco_app/common/utils/globals.dart' as globals;
import 'package:flutter/material.dart';

class SinaDustryServices {
  static Future getDustryList({type,page,size,isAsc,mar}) async {
    var url = '${globals.dustryUrl}/StockRankEx?mar=$mar&type=${type??"changeRate"}&page=${page??1}&size=${size??20}&isAsc=${isAsc??false}';
    var response = await Request.netFetch(
        url);
    return response;
  }


  static Future getMinuteData(stkUniCode,{minute:1}) async {
    var url = '${globals.dustryUrl}/StockRealTimeLineFiveData?code=$stkUniCode&minute=$minute';
    var response = await Request.netFetch(
        url);
    return response;
  }

  static Future getCodeData(stkUniCode,{minute:1}) async {
    var url = '${globals.dustryUrl}/StockDetails?code=$stkUniCode';
    var response = await Request.netFetch(
        url);
    return response;
  }

  /// 6 k 为日数据
  /// 5 r 为分时
  static Future getDataByCode(String code,{type:"k",rtntype='6'}) async {
    String codeText;
    if(code[0]=='6'){
      codeText = '${code}1';
    }else if(code[0]=='3'){
      codeText = '${code}2';
    }else{
      codeText = '${code}2';
    }
    var url = '${globals.kUrl}?rtntype=$rtntype&id=$codeText&type=$type';
    var response = await Request.netFetch(
        url);
    return response;
  }



}
