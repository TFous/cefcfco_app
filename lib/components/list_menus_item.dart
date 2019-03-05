import 'package:flutter/cupertino.dart';

class ListMenusItem {
  final String title;
  final String rightText;
  final Icon icon;
  final Function onTapCallBack;

  ListMenusItem({this.title, this.icon,this.rightText, this.onTapCallBack})
      : assert(title != null),
        assert(onTapCallBack != null);

  factory ListMenusItem.fromJson(Map<String, dynamic> json) {
    return ListMenusItem(
        title: json['title'],
        rightText: json['rightText']!=null?json['rightText']:'',
        icon: json['icon'],
        onTapCallBack: json['onTapCallBack']);
  }
}
