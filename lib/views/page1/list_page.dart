import 'package:cefcfco_app/net/Code.dart';
import 'package:cefcfco_app/redux/AppState.dart';
import 'package:cefcfco_app/redux/ThemeRedux.dart';
import 'package:cefcfco_app/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/utils/globals.dart' as globals;
import 'package:flutter_redux/flutter_redux.dart';

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
//          automaticallyImplyLeading: false,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            );
          },
        ),

          //设置标题栏的背景颜色
          title: new Title(
            child: new Text(
              CommonUtils.getLocale(context).dongtai,
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
            if (tab.text == 'Tab1') {
              return new StoreBuilder<AppStates>(
              builder: (context, store) {
                return Builder(
                  builder: (BuildContext context){
                    var doms = <Widget>[];
                    var items  = CommonUtils.getThemeListColor();
                    for(var i = 0;i<items.length;i++){
                      doms.add(Container(
                        padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
                        decoration: new BoxDecoration(
                          border: new Border(bottom: BorderSide(color: Color(0xFFf2f2f2))),
                          color: Colors.white,
                        ),
                        child: ListTile(
                          title: Text('点击切换主题'),
                          // item 前置图标
                          trailing: Icon(Icons.keyboard_arrow_right,color: Color(0xFFcccccc),),
                          // item 后置图标
                          isThreeLine: false,
                          // item 是否三行显示
                          dense: true,
                          // item 直观感受是整体大小
                          contentPadding: EdgeInsets.all(3.0),
                          // item 内容内边距
                          enabled: true,
                          onTap: () {
                            CommonUtils.pushTheme(store,i);
                            CommonUtils.changeLocale(store,i);
                            Code.errorHandleFunction(1,'123',false);
//                            store.dispatch(new RefreshThemeDataAction(item));
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
              );
            } else {
              return new Center(child: new Text(tab.text)); //使用参数值

            }
          }).toList(),
        ),
      )
//      bottomNavigationBar: new HomeBottomNavigationBar(tabData:globals.homePageTabData,activeIndex:1),
    );
  }
}
