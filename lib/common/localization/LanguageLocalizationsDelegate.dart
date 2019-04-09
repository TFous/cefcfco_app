import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/common/localization/DefaultLocalizations.dart';


class LanguageLocalizationsDelegate extends LocalizationsDelegate<LanguageLocalizations> {

  LanguageLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    ///支持中文和英语
    return ['en', 'zh'].contains(locale.languageCode);
  }

  ///根据locale，创建一个对象用于提供当前locale下的文本显示
  @override
  Future<LanguageLocalizations> load(Locale locale) {
    return new SynchronousFuture<LanguageLocalizations>(new LanguageLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<LanguageLocalizations> old) {
    return false;
  }

  ///全局静态的代理
  static LanguageLocalizationsDelegate delegate = new LanguageLocalizationsDelegate();
}
