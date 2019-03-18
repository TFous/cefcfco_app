import 'package:flutter/material.dart';
import 'package:cefcfco_app/redux/LocaleRedux.dart';
import 'package:cefcfco_app/redux/ThemeRedux.dart';

class AppStates {
  ThemeData themeData;

  ///语言
  Locale locale;

  AppStates({this.themeData, this.locale});
}

AppStates appReducer(AppStates state, action) {
  return AppStates(
    themeData: ThemeDataReducer(state.themeData, action),
    locale: LocaleReducer(state.locale, action),
  );
}
