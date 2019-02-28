import 'package:cefcfco_app/components/homeBottomNavigationBar.dart';
import 'package:cefcfco_app/components/search_input.dart';
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
    with SingleTickerProviderStateMixin {
  TabController controller;
  bool isSearch = false;
  String data = '无';
  String data2ThirdPage = '这是传给ThirdPage的值';
  String appBarTitle = tabData[0]['text'];
  static List tabData = [
    {'text': '首页', 'icon': new Icon(Icons.language)},
    {'text': '动态', 'icon': new Icon(Icons.extension)},
    {'text': '我的', 'icon': new Icon(Icons.favorite)},
  ];

  List<Widget> myTabs = [];

  @override
  void initState() {
    super.initState();
    controller = new TabController(
        initialIndex: 1, vsync: this, length: 3); // 这里的length 决定有多少个底导 submenus
    for (int i = 0; i < tabData.length; i++) {
      myTabs.add(new Tab(text: tabData[i]['text'], icon: tabData[i]['icon']));
    }
    controller.addListener(() {
      if (controller.indexIsChanging) {
        _onTabChange();
      }
    });
    Application.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildSearchInput(BuildContext context) {
    return new SearchInput((value) async {
      if (value != '') {
        List list = [];
        return list
            .map((item) => new MaterialSearchResult<String>(
          value: item.name,
          icon:null,
          text: 'widget',
          onTap: () {
          },
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
      appBar: new AppBar(title: buildSearchInput(context),
        automaticallyImplyLeading: false,
      ),
      body: new TabBarView(controller: controller, children: <Widget>[
        new FirstPage(),
      ]),
      bottomNavigationBar: new HomeBottomNavigationBar(tabData:globals.homePageTabData,activeIndex:0),
    );
  }

  void _onTabChange() {
    if (this.mounted) {
      this.setState(() {
        appBarTitle = tabData[controller.index]['text'];
      });
    }
  }
}
