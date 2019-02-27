import 'dart:async';
import 'package:cefcfco_app/components/homeBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/utils/globals.dart' as globals;
import 'package:cefcfco_app/utils/shared_preferences.dart';
import 'package:cefcfco_app/services/keyValue.dart';
import 'package:cefcfco_app/components/list_view_item.dart';
import 'package:cefcfco_app/components/list_refresh.dart' as listComp;
import 'package:cefcfco_app/style/theme.dart' as Theme;

class AboutPage extends StatefulWidget {
  @override
  AboutPageState createState() => new AboutPageState();
}

class AboutPageState extends State<AboutPage>
    with AutomaticKeepAliveClientMixin {
  var _keyValueList = {};

  String _user = '', _accessToken = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _getUserName();
  }

  _getUserName() async {
    SpUtil sp = await SpUtil.getInstance();
    setState(() {
      _user = sp.getString(globals.userName);
      _accessToken = sp.getString(globals.accessToken);
    });
  }

  headerView() {
    return Column(
      children: <Widget>[],
    );
  }

  Widget makeCard(index, item) {
    var myTitle = '${item['displayName']}';
    var myUsername = '${'👲'}: ${item['keyName']} ';
    return new ListViewItem(
      itemTitle: myTitle,
      data: myUsername,
    );
  }

  Future getIndexListData([Map<String, dynamic> params]) async {
    var dd = await keyValuesServices.getKeyValueList();
    Map<String, dynamic> result = {
      "list": dd['result'],
      'total': 20,
      'pageIndex': 0
    };
    return result;
  }

  _submit() {
    getIndexListData();
  }

  _getList() async {
    var data = await keyValuesServices.getKeyValueList();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.blue,//设置标题栏的背景颜色
          title: new Title(
            child:new Text(
              '我的',
              style: new TextStyle(
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
            color: Colors.white,//设置标题栏文字的颜色(new title的时候color不能为null不然会报错一般可以不用new title 直接new text,不过最终的文字里面还是以里面new text的style样式文字颜色为准)
          ),
//          centerTitle: true,//设置标题居中
          elevation: 0,//设置标题栏下面阴影的高度
//        brightness:Brightness.dark,//设置明暗模式（不过写了没看出变化，后面再看）
          primary: true,//是否设置内容避开状态栏
//        flexibleSpace: ,//伸缩控件后面再看
//        automaticallyImplyLeading: true,
          actions: <Widget>[ //设置显示在右边的控件
            new Padding(
              child: new Icon(Icons.settings),
              padding: EdgeInsets.all(10.0),
            ),
          ],
        ),
      body:new  ListView.separated(
        scrollDirection: Axis.vertical,
        itemCount: 100, // item 的个数
        separatorBuilder: (BuildContext context, int index) => Divider(height:1.0,color: Colors.black12),  // 添加分割线
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title:  Text("title $index"), // item 标题
            leading: Icon(Icons.keyboard), // item 前置图标
            trailing: Icon(Icons.keyboard_arrow_right),// item 后置图标
            isThreeLine:false,  // item 是否三行显示
            dense:true,                // item 直观感受是整体大小
            contentPadding: EdgeInsets.all(3.0),// item 内容内边距
            enabled:true,
            onTap:(){print('点击:$index');},// item onTap 点击事件
            onLongPress:(){print('长按:$index');},// item onLongPress 长按事件
            selected:false,     // item 是否选中状态
          );
        },
      ),
      bottomNavigationBar: new HomeBottomNavigationBar(tabData:globals.myPageTabData,activeIndex:2),
    );
  }
}
