import 'package:cefcfco_app/components/homeBottomNavigationBar.dart';
import 'package:cefcfco_app/components/search_input.dart';
import 'package:cefcfco_app/views/list_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cefcfco_app/routers/application.dart';
import 'package:cefcfco_app/views/about_page.dart';
import 'package:cefcfco_app/views/first_page.dart';
import 'package:cefcfco_app/views/user_page.dart';

import 'package:cefcfco_app/utils/globals.dart' as globals;

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

  Map badge = {
    'msgNum': 33,
    'index': 0,
    'right': -5,
    'top': -5
  };
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
          'num': 1,
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
      body: new TabBarView(
          physics: new NeverScrollableScrollPhysics(), // 禁用滑动
          controller: controller,
          children: <Widget>[
        new FirstPage(),
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
