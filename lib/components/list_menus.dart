import 'package:cefcfco_app/components/list_menus_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/utils/globals.dart' as globals;


class ListMenus extends StatefulWidget{
  final List<ListMenusItem> menusList;
  const ListMenus({Key key, this.menusList}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _ListMenus();
  }
}

class _ListMenus extends State<ListMenus>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Builder(
      builder: (BuildContext context){
        var doms = <Widget>[];
        for(ListMenusItem item in widget.menusList){
          doms.add(Container(
            padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
            decoration: new BoxDecoration(
              border: new Border(bottom: BorderSide(color: Color(0xFFf2f2f2))),
              color: Colors.white,
            ),
            child: ListTile(
              title: Text(item.title),
              // item 标题
              leading: item.icon,
              // item 前置图标
              trailing: Icon(Icons.keyboard_arrow_right),
              // item 后置图标
              isThreeLine: false,
              // item 是否三行显示
              dense: true,
              // item 直观感受是整体大小
              contentPadding: EdgeInsets.all(3.0),
              // item 内容内边距
              enabled: true,
              onTap: () {
                item.onTapCallBack(context);
              },
              // item onTap 点击事件
              onLongPress: () {
                print('长按:');
              },
              // item onLongPress 长按事件
              selected: false, // item 是否选中状态
            ),
          ));
        }
        return Column(children: doms);
      },
    );
  }

}