import 'package:cefcfco_app/components/homeBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/views/page1/list_page.dart';
import 'package:cefcfco_app/views/page1/user_page.dart';
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
    List myPageTabData = [
      {'text': '编辑','isShowBadge': false, 'icon': new Icon(Icons.edit)},
      {'text': '列表','isShowBadge': false, 'icon': new Icon(Icons.dashboard)},
    ];

    setData(myPageTabData);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new TabBarView(
          physics: new NeverScrollableScrollPhysics(), // 禁用滑动
          controller: controller,
          children: <Widget>[
        new ListPage(),
        new UserPage(),
      ]),
      bottomNavigationBar: new HomeBottomNavigationBar(
          tabData: globals.myPageTabData,
          indexIsChangingCallBack: refshTabState,
          controller:controller),
    );
  }
}
