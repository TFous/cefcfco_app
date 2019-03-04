import 'package:flutter/material.dart';
import 'package:cefcfco_app/utils/globals.dart' as globals;

class ListPage extends StatefulWidget {
  @override
  ListPageState createState() => new ListPageState();
}

class ListPageState extends State<ListPage> with AutomaticKeepAliveClientMixin,SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TabController _tabController;
  final List<Tab> myTabs = <Tab>[
    new Tab(text: 'Tab1'),
    new Tab(text: 'Tab2'),
    new Tab(text: 'Tab3'),
    new Tab(text: 'Tab4'),
    new Tab(text: 'Tab5'),
    new Tab(text: 'Tab6'),
    new Tab(text: 'Tab7'),
    new Tab(text: 'Tab8'),
    new Tab(text: 'Tab9'),
    new Tab(text: 'Tab10'),
    new Tab(text: 'Tab11'),
  ];

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
          backgroundColor: Color(0xff1b82d2),
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
      body: new Scaffold(
        appBar: new AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xff1b82d2),
          //设置标题栏的背景颜色
          title: new TabBar(
            controller: _tabController,
            tabs: myTabs,    //使用Tab类型的数组呈现Tab标签
            indicatorColor: Colors.white,
            isScrollable: true,
          ),
          elevation: 0,
          primary: true,

        ),
        body: new TabBarView(
          controller: _tabController,
          children: myTabs.map((Tab tab) {    //遍历List<Tab>类型的对象myTabs并提取其属性值作为子控件的内容
            return new Center(child: new Text(tab.text)); //使用参数值
          }).toList(),
        ),
      )
//      bottomNavigationBar: new HomeBottomNavigationBar(tabData:globals.homePageTabData,activeIndex:1),
    );
  }
}
