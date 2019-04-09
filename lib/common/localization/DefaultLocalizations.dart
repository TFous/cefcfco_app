import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cefcfco_app/common/language/AppLanguageBase.dart';
import 'package:cefcfco_app/common/language/AppLanguageEn.dart';
import 'package:cefcfco_app/common/language/AppLanguageZh.dart';

///自定义多语言实现
class LanguageLocalizations {
  final Locale locale;

  LanguageLocalizations(this.locale);

  ///根据不同 locale.languageCode 加载不同语言对应
  ///GSYStringEn和GSYStringZh都继承了GSYStringBase
  static Map<String, AppLanguageBase> _localizedValues = {
    'en': new AppLanguageEn(),
    'zh': new AppLanguageZh(),
  };

  AppLanguageBase get currentLocalized {
    return _localizedValues[locale.languageCode];
  }

  ///通过 Localizations 加载当前的 GSYLocalizations
  ///获取对应的 GSYStringBase
  static LanguageLocalizations of(BuildContext context) {
    return Localizations.of(context, LanguageLocalizations);
  }
}
