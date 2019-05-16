import 'dart:convert';

import 'package:cefcfco_app/common/model/SinaDustryModel.dart';
import 'package:cefcfco_app/common/net/Code.dart';
import 'package:cefcfco_app/components/AppWrap.dart';
import 'package:cefcfco_app/redux/AppState.dart';
import 'package:cefcfco_app/redux/ThemeRedux.dart';
import 'package:cefcfco_app/common/utils/common.dart';
import 'package:cefcfco_app/routers/application.dart';
import 'package:cefcfco_app/views/KlinePage/MinKLine_page.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/common/utils/globals.dart' as globals;
import 'package:cefcfco_app/services/get_dustry_list.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:cefcfco_app/common/utils/router_config.dart' as routerConfig;
class ListDustryPage extends StatefulWidget {
  @override
  ListDustryPageState createState() => new ListDustryPageState();
}

class ListDustryPageState extends State<ListDustryPage> with AutomaticKeepAliveClientMixin,SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TabController _tabController;


  List<SinaDustryModel> dustryList = [];

//  final List<String> tabs= ["行业","沪深A股","沪市A股","深市A股","创业板","中小板"];
  final Map<String,String> tabs= {
    "沪深A股":"all",
    "沪市A股":"sh",
    "深市A股":"sz",
    "创业板":"gem",
    "中小板":"sme"
  };

  List<Tab> myTabs = <Tab>[];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    tabs.forEach((key,value){
      myTabs.add(new Tab(text: key,));
    });
    getList(mar:tabs.values.toList()[0]);
    _tabController = new TabController(
        vsync: this,     //动画效果的异步处理，默认格式，背下来即可
        length: myTabs.length      //需要控制的Tab页数量
    )
      ..addListener((){
        getList(mar: tabs.values.toList()[_tabController.index]);
      });
  }
  @override
  void dispose() {
    super.dispose();
  }
  getList({type,page,size,isAsc,mar}) async {
    var result = await SinaDustryServices.getDustryList(mar:mar,page:page,size: size,type: type,isAsc: isAsc);
    List<SinaDustryModel> list = [];
    var data = result.data['data']['list'];
    data.forEach((item){
      list.add(new SinaDustryModel(item['stkShortName'],item['stkCode'].toString(),item['stkUniCode'].toString(),item['highPrice'],item['highPrice'],item['highPrice'],item['highPrice'],item['highPrice']));
    });

    if (this.mounted){
      setState((){
        dustryList = list;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Scaffold(
        key: _scaffoldKey,
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
              return new StoreBuilder<AppStates>(
                  builder: (context, store) {
                    return Builder(
                      builder: (BuildContext context){
                        var doms = <Widget>[];
                        for(var i = 0;i<dustryList.length;i++){
                          doms.add(Container(
                            padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
                            decoration: new BoxDecoration(
                              border: new Border(bottom: BorderSide(color: Color(0xFFf2f2f2))),
                              color: Colors.white,
                            ),
                            child: ListTile(
                              title: Text('${dustryList[i].name}         ${dustryList[i].code}'),
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
                                Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context){
                                  return new AppWrap( child:new MinKLine(title:dustryList[i].name,code:dustryList[i].code,stkUniCode:dustryList[i].stkUniCode));
                                }));
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
                        return SingleChildScrollView(
                          child: Column(children: doms),
                        );
                      },
                    );
                  }
              );
            }).toList(),
          ),
        )
//      bottomNavigationBar: new HomeBottomNavigationBar(tabData:globals.homePageTabData,activeIndex:1),
    );
  }
}
