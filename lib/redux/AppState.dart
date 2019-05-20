import 'package:cefcfco_app/redux/IsFocusCanvasRedux.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/redux/LocaleRedux.dart';
import 'package:cefcfco_app/redux/ThemeRedux.dart';

class AppStates {
  ThemeData themeData;

  ///语言
  Locale locale;
  ///当前手机平台默认语言
  Locale platformLocale;
  bool isFocus;
  AppStates({this.themeData, this.locale,this.isFocus});
}

AppStates appReducer(AppStates state, action) {
  return AppStates(
    themeData: ThemeDataReducer(state.themeData, action),
    locale: LocaleReducer(state.locale, action),
    isFocus: IsFocusCanvasReducer(state.isFocus, action),
  );
}
