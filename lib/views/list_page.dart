import 'package:cefcfco_app/components/list_menus.dart';
import 'package:cefcfco_app/components/list_menus_item.dart';
import 'package:cefcfco_app/routers/application.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/common/utils/globals.dart' as globals;
import 'package:cefcfco_app/common/utils/router_config.dart' as routerConfig;

import 'package:cefcfco_app/views/dayKLine_page.dart';

class ListPage extends StatefulWidget {
  @override
  ListPageState createState() => new ListPageState();
}

class ListPageState extends State<ListPage> with AutomaticKeepAliveClientMixin,SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TabController _tabController;
  final List<Tab> myTabs = <Tab>[
    new Tab(text: '日行情'),
    new Tab(text: '分钟行情'),
  ];
  final List list = [
    {
      'title': '平安银行',
      'icon': Icon(Icons.assignment, color: Color(0xfff49c2e)),
      'onTapCallBack': (context) =>
      {
      Application.router.navigateTo(
          context,routerConfig.dayKlinePage,
          transition: TransitionType.fadeIn)
      },
    }, {
      'title': '伊利股份',
      'icon': Icon(Icons.keyboard,color: Color(0xff108ee9)),
      'onTapCallBack': (context) =>
      {
      Application.router.navigateTo(
          context,routerConfig.dayKlinePage,
          transition: TransitionType.fadeIn)
      },
    }, {
      'title': '分时图',
      'icon': Icon(Icons.assessment,color: Color(0xff108ee9)),
      'onTapCallBack': (context) =>
      {
      Application.router.navigateTo(
          context,routerConfig.minKlinePage,
          transition: TransitionType.fadeIn)
      },
    },{
      'title': '账单',
      'icon': Icon(Icons.assignment, color: Color(0xfff49c2e)),
      'onTapCallBack': (context) =>
      {
      Application.router.navigateTo(
          context,routerConfig.dayKlinePage,
          transition: TransitionType.fadeIn)
      },
    }, {
      'title': '输入相关',
      'icon': Icon(Icons.keyboard,color: Color(0xff108ee9)),
      'onTapCallBack': (context) =>
      {
      Application.router.navigateTo(
          context,routerConfig.dayKlinePage,
          transition: TransitionType.fadeIn)
      },
    }, {
      'title': '统计',
      'icon': Icon(Icons.assessment,color: Color(0xff108ee9)),
      'onTapCallBack': (context) =>
      {
      Application.router.navigateTo(
          context,routerConfig.dayKlinePage,
          transition: TransitionType.fadeIn)
      },
    },{
      'title': '账单',
      'icon': Icon(Icons.assignment, color: Color(0xfff49c2e)),
      'onTapCallBack': (context) =>
      {
      Application.router.navigateTo(
          context,routerConfig.dayKlinePage,
          transition: TransitionType.fadeIn)
      },
    }, {
      'title': '输入相关',
      'icon': Icon(Icons.keyboard,color: Color(0xff108ee9)),
      'onTapCallBack': (context) =>
      {
      Application.router.navigateTo(
          context,routerConfig.dayKlinePage,
          transition: TransitionType.fadeIn)
      },
    }, {
      'title': '统计',
      'icon': Icon(Icons.assessment,color: Color(0xff108ee9)),
      'onTapCallBack': (context) =>
      {
      Application.router.navigateTo(
          context,routerConfig.dayKlinePage,
          transition: TransitionType.fadeIn)
      },
    }];
  List<ListMenusItem> menusList = [];
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _getUserName();
    _tabController = new TabController(
        vsync: this,     //动画效果的异步处理，默认格式，背下来即可
        length: myTabs.length      //需要控制的Tab页数量
    );


    for(var i=0;i<list.length;i++){
      ListMenusItem cellData =new ListMenusItem.fromJson(list[i]);
      menusList.add(cellData);
    }
  }

  _getUserName() async {

  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
          automaticallyImplyLeading: false,
          //设置标题栏的背景颜色
          title: new Title(
            child: new Text(
              '列表',
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
          //是否设置内容避开状态栏
//        flexibleSpace: ,//伸缩控件后面再看
//        automaticallyImplyLeading: true,
          actions: <Widget>[
            //设置显示在右边的控件
            new Padding(
              child: new Icon(Icons.menu),
              padding: EdgeInsets.all(10.0),
            ),
          ],
        ),
      body: SingleChildScrollView(
        child: new Container(
            decoration: new BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: <Widget>[
                ListMenus(menusList: menusList)
              ],
            )),
      ),
//      bottomNavigationBar: new HomeBottomNavigationBar(tabData:globals.homePageTabData,activeIndex:1),
    );
  }
}
