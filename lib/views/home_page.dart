import 'package:cefcfco_app/components/homeBottomNavigationBar.dart';
import 'package:cefcfco_app/components/search_input.dart';
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

  Map msgTipInfo = {
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

  Widget buildSearchInput(BuildContext context) {
    return new SearchInput((value) async {
      if (value != '') {
        List list = [];
        return list
            .map((item) => new MaterialSearchResult<String>(
                  value: item.name,
                  icon: null,
                  text: 'widget',
                  onTap: () {},
                ))
            .toList();
      } else {
        return null;
      }
    }, (value) {}, () {});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: buildSearchInput(context),
        automaticallyImplyLeading: false,
      ),
      body: new TabBarView(
          physics: new NeverScrollableScrollPhysics(), // 警用滑动
          controller: controller,
          children: <Widget>[
        new FirstPage(),
        new AboutPage(),
        new UserPage(),
      ]),
      bottomNavigationBar: new HomeBottomNavigationBar(
          tabData: globals.homePageTabData,
          activeIndex: 0,
          controller:controller,
          msgTipInfo: msgTipInfo),
    );
  }
}
