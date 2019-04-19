import 'package:cefcfco_app/components/homeBottomNavigationBar.dart';
import 'package:cefcfco_app/components/search_input.dart';
import 'package:cefcfco_app/views/list_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cefcfco_app/routers/application.dart';
import 'package:cefcfco_app/views/about_page.dart';
import 'package:cefcfco_app/views/dayKline_page.dart';
import 'package:cefcfco_app/views/user_page.dart';

import 'package:cefcfco_app/common/utils/globals.dart' as globals;

const int ThemeColor = 0xFFC91B3A;

class AppPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<AppPage>
    with SingleTickerProviderStateMixin,AutomaticKeepAliveClientMixin {
  bool isSearch = false;
  TabController controller;
  List<Widget> myTabs = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller = new TabController(
        initialIndex: 0, vsync: this, length: globals.homePageTabData.length); // 这里的length 决定有多少个底导 submenus
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  refshTabState(setData){
    var newTabData = [
      {
        'text': '首页',
        'router':'/home',
        'icon': new Icon(Icons.home),
        'isShowBadge': true,
        'badgeData':{
            'right':-20.0,
            'top':-5.0,
          'num': 'new',
        }
      },
      {'text': '动态', 'router':'/about','isShowBadge': false, 'icon': new Icon(Icons.filter_vintage)},
      {'text': '列表', 'router':'/about','isShowBadge': false, 'icon': new Icon(Icons.list)},
      {'text': '我的','router':'/user', 'isShowBadge': false,'icon': new Icon(Icons.person)},
    ];

    setData(newTabData);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        automaticallyImplyLeading: false,

        //设置标题栏的背景颜色
        title: new Title(
          child: new Text(
            '行情',
            style: new TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
          color: Colors
              .white, //设置标题栏文字的颜色(new title的时候color不能为null不然会报错一般可以不用new title 直接new text,不过最终的文字里面还是以里面new text的style样式文字颜色为准)
        ),
//          centerTitle: true,//设置标题居中
        elevation: 0,
        //设置标题栏下面阴影的高度
//        brightness:Brightness.dark,//设置明暗模式（不过写了没看出变化，后面再看）
        primary: true,
      ),
      body: new TabBarView(
          physics: new NeverScrollableScrollPhysics(), // 禁用滑动
          controller: controller,
          children: <Widget>[
        new DayKLine(),
        new AboutPage(),
        new ListPage(),
        new UserPage(),
      ]),
      bottomNavigationBar: new HomeBottomNavigationBar(
          tabData: globals.homePageTabData,
          indexIsChangingCallBack: refshTabState,
          controller:controller),
    );
  }
}
