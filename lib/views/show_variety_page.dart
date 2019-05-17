import 'dart:convert';

import 'package:cefcfco_app/common/model/SinaDustryModel.dart';
import 'package:cefcfco_app/common/net/Code.dart';
import 'package:cefcfco_app/common/net/ResultData.dart';
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
class ShowVarietyPage extends StatefulWidget {
  @override
  ShowVarietyPageState createState() => new ShowVarietyPageState();
}

class ShowVarietyPageState extends State<ShowVarietyPage> with AutomaticKeepAliveClientMixin,SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TabController _tabController;


  List<SinaDustryModel> dustryList = [];

//  final List<String> tabs= ["行业","沪深A股","沪市A股","深市A股","创业板","中小板"];
  final Map<String,String> tabs= {
    "分时":"all",
    "五日":"sh",
    "日K":"sz",
    "周K":"gem",
    "月K":"sme",
    "1分":"sme",
    "5分":"sme",
    "15分":"sme",
    "30分":"sme",
    "60分":"sme",
    "年K":"sme"
  };
  Map varietyMsg ={
    "changeRate": -5.93080724876442,
    "curPrice": 5.71,
    "floatValue": 4346402288.74,
    "hasCollected": false,
    "highPrice": 6.07,
    "highPrice52w": 8.58,
    "lowPrice": 5.67,
    "lowPrice52w": 2.56,
    "openPrice": 6.01,
    "preClosePrice": 6.07,
    "priceBookRatio": 2.6836490106687974,
    "priceEarningRatio": -45.826645264847514,
    "priceUpdown1": -0.3600000000000003,
    "sortIndex": 0,
    "stkCode": "002177.SZ",
    "stkShortName": "御银股份",
    "stkUniCode": 101000303,
    "totValue": 4346402288.74,
    "tradeAmut": 271312887.66,
    "tradeVol": 463893,
    "turnoverRate": 6.094302492114419,
    "type": "A"
  }; // 品种详情
  List<Tab> myTabs = <Tab>[];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    tabs.forEach((key,value){
      myTabs.add(new Tab(text: key,));
    });
    _tabController = new TabController(
        vsync: this,     //动画效果的异步处理，默认格式，背下来即可
        length: myTabs.length      //需要控制的Tab页数量
    )
      ..addListener((){

      });
  }
  @override
  void dispose() {
    super.dispose();
  }

  initData() async{
    ResultData result = await SinaDustryServices.getCodeData(widget.stkUniCode);
    varietyMsg = result.data['data'];
  }

  @override
  Widget build(BuildContext context) {
    initData();
    super.build(context);
    return new Scaffold(
        key: _scaffoldKey,
        body: Container(
          child: SingleChildScrollView(
            child: Column(children: <Widget>[
              Container(
                  margin: EdgeInsets.symmetric(vertical: globals.sidesDistance,
                      horizontal: globals.horizontalDistance),
                  child: Stack(
                    alignment:Alignment.bottomRight ,
                    children: <Widget>[
                      new Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Text( varietyMsg['curPrice'].toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 26.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500)),
                                  Text( "${varietyMsg['priceUpdown1'].toStringAsFixed(2)}  ${varietyMsg['changeRate'].toStringAsFixed(2)}%",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 13.0,
                                          color: Colors.black,
                                          fontWeight: null)),
                                ],),
                            ),
                            Expanded(
                              child: Column(
                                  children: <Widget>[
                                    new Row(
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 4,),
                                            child: Text(
                                                "高",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(fontSize: 16.0,
                                                    color: Color(0xFF666666),
                                                    fontWeight: FontWeight.w600)),
                                          )
                                          ,
                                          Container(
                                            child: Text(
                                                varietyMsg['highPrice'].toStringAsFixed(2),
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    height: 1.2,
                                                    fontSize: 16.0,
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.w700)),
                                          )

                                        ]),
                                    new Row(
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 4,),
                                            child: Text(
                                                "低",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(fontSize: 16.0,
                                                    color: Color(0xFF666666),
                                                    fontWeight: FontWeight.w600)),
                                          )
                                          ,
                                          Container(
                                            child: Text(
                                                varietyMsg['lowPrice'].toStringAsFixed(2),
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    height: 1.2,
                                                    fontSize: 16.0,
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.w700)),
                                          )

                                        ]),
                                  ]),
                            ),
                            Expanded(
                              child: Column(
                                  children: <Widget>[
                                    new Row(
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 4,),
                                            child: Text(
                                                "开",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(fontSize: 16.0,
                                                    color: Color(0xFF666666),
                                                    fontWeight: FontWeight.w600)),
                                          )
                                          ,
                                          Container(
                                            child: Text(
                                                varietyMsg['openPrice'].toStringAsFixed(2),
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    height: 1.2,
                                                    fontSize: 16.0,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w700)),
                                          )

                                        ]),
                                    new Row(
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 4,),
                                            child: Text(
                                                "换",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(fontSize: 16.0,
                                                    color: Color(0xFF666666),
                                                    fontWeight: FontWeight.w600)),
                                          )
                                          ,
                                          Container(
                                            child: Text(
                                                varietyMsg['openPrice'].toStringAsFixed(2),
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    height: 1.2,
                                                    fontSize: 16.0,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w700)),
                                          )

                                        ]),
                                  ]),
                            ),
                            Expanded(
                              child: Column(
                                  children: <Widget>[
                                    new Row(
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 4,),
                                            child: Text(
                                                "量",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(fontSize: 16.0,
                                                    color: Color(0xFF666666),
                                                    fontWeight: FontWeight.w600)),
                                          )
                                          ,
                                          Container(
                                            padding: EdgeInsets.fromLTRB(0,0,12,0),
                                            child: Text(
                                                "27.55",
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    height: 1.2,
                                                    fontSize: 16.0,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w700)),
                                          )

                                        ]),
                                    new Row(
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 4,),
                                            child: Text(
                                                "额",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(fontSize: 16.0,
                                                    color: Color(0xFF666666),
                                                    fontWeight: FontWeight.w600)),
                                          )
                                          ,
                                          Container(
                                            padding: EdgeInsets.fromLTRB(0,0,12,0),
                                            child: Text(
                                                "27.55",
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                    height: 1.2,
                                                    fontSize: 16.0,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w700)),
                                          )

                                        ]),
                                  ]),
                            ),
                          ]),
                      Positioned(
                          right: -12.0,
                          bottom: -22.0,
                          child: new IconButton(
                            icon: const Icon(Icons.network_cell),
                            iconSize: 8,
                            color: Colors.black26,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          )
                      ),
                    ],)
              ),
              Container(
                height: 400,
                child: new Scaffold(
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
                  body: Container(
                    child: new TabBarView(
                      controller: _tabController,
                      children: myTabs.map((Tab tab) {    //遍历List<Tab>类型的对象myTabs并提取其属性值作为子控件的内容
                        return new StoreBuilder<AppStates>(
                            builder: (context, store) {
                              return Builder(
                                builder: (BuildContext context){
                                  var doms = <Widget>[];
                                  return Text('444444444');
                                },
                              );
                            }
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              Text('66666666666')
            ],),
          ),
        )//      bottomNavigationBar: new HomeBottomNavigationBar(tabData:globals.homePageTabData,activeIndex:1),
    );
  }
}
