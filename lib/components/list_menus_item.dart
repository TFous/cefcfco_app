import 'package:flutter/cupertino.dart';

class ListMenusItem {
  String title;
  Icon icon;
  Function onTapCallBack;

  ListMenusItem({this.title, this.icon, this.onTapCallBack})
      : assert(title != null),
        assert(onTapCallBack != null),
        assert(icon != null);

  factory ListMenusItem.fromJson(Map<String, dynamic> json) {
    return ListMenusItem(
        title: json['title'],
        icon: json['icon'],
        onTapCallBack: json['onTapCallBack']);
  }
}
