import 'dart:convert';

import 'package:cefcfco_app/common/model/SinaDustryModel.dart';
import 'package:cefcfco_app/common/model/dd.dart';
import 'package:cefcfco_app/common/net/Code.dart';
import 'package:cefcfco_app/common/net/ResultData.dart';
import 'package:cefcfco_app/common/utils/HandelOnPointerDownEvent.dart';
import 'package:cefcfco_app/common/utils/HandelOnPointerMoveEvent.dart';
import 'package:cefcfco_app/common/utils/HandelOnPointerUpEvent.dart';
import 'package:cefcfco_app/components/AppWrap.dart';
import 'package:cefcfco_app/redux/AppState.dart';
import 'package:cefcfco_app/redux/ThemeRedux.dart';
import 'package:cefcfco_app/common/utils/common.dart';
import 'package:cefcfco_app/routers/application.dart';
import 'package:cefcfco_app/views/KlinePage/DayKLine_page.dart';
import 'package:cefcfco_app/views/KlinePage/MinKLine_page.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/common/utils/globals.dart' as globals;
import 'package:cefcfco_app/services/get_dustry_list.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:cefcfco_app/common/utils/router_config.dart' as routerConfig;
class ShowVarietyPage extends StatefulWidget {

  String title;
  String code;
  String stkUniCode;

  ShowVarietyPage({this.title,this.code,this.stkUniCode});

  @override
  ShowVarietyPageState createState() => new ShowVarietyPageState();
}

class ShowVarietyPageState extends State<ShowVarietyPage> with AutomaticKeepAliveClientMixin,SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TabController _tabController;


  List<SinaDustryModel> dustryList = [];
  bool isFocus = true;
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

  String tabName = '分时';  // 当前选中的tab

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
  double openPrice;

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
        if (_tabController.indexIsChanging) {
          tabName = tabs.keys.toList()[_tabController.index];
        }
      });

    initData();

  }
  @override
  void dispose() {
    super.dispose();
  }

  initData() async{
    ResultData result = await SinaDustryServices.getCodeData(widget.stkUniCode);
    setState(() {
      varietyMsg = result.data['data'];
      openPrice = result.data['data']['preClosePrice'];
    });
  }


  void _handelOnPointerDown(PointerDownEvent details){
    Code.eventBus.fire(HandelOnPointerDownEvent(details,tabName));
  }

  Future _handelOnPointerUp(PointerUpEvent details) async {
    Code.eventBus.fire(HandelOnPointerUpEvent(details,tabName));
  }
  Future _handelOnPointerMove(PointerMoveEvent details) async {
    Code.eventBus.fire(HandelOnPointerMoveEvent(details,tabName));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return new StoreBuilder<AppStates>(builder: (context, store) {
          return new Scaffold(
              key: _scaffoldKey,
              appBar: new AppBar(
                leading: Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      iconSize: 16,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
                automaticallyImplyLeading: false,
                //设置标题栏的背景颜色
                title: new Title(
                  child: new Row(
                      children: <Widget>[
                        Expanded(
                          child: new Icon(Icons.arrow_left),
                        ),
                        Expanded(
                          child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 3.0),
                                  child: Text(
                                      widget.title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18.0,
                                          color: Colors.white,
                                          fontWeight: null)),
                                ),
                                Text(
                                    widget.code,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 13.0,
                                        color: Colors.white,
                                        fontWeight: null))
                              ]),
                        ),
                        Expanded(
                          child: new Icon(Icons.arrow_right),
                        ),
                      ]
                  ),
                  color: Colors .white, //设置标题栏文字的颜色(new title的时候color不能为null不然会报错一般可以不用new title 直接new text,不过最终的文字里面还是以里面new text的style样式文字颜色为准)
                ),
                centerTitle: true,//设置标题居中
                elevation: 0,
                actions: <Widget>[
                  //设置显示在右边的控件
                  new Padding(
                    child: new Icon(Icons.search),
                    padding: EdgeInsets.all(10.0),
                  ),
                ],
                //设置标题栏下面阴影的高度
//        brightness:Brightness.dark,//设置明暗模式（不过写了没看出变化，后面再看）
                primary: true,
              ),
              body:Listener(
                onPointerDown: _handelOnPointerDown,
                onPointerUp: _handelOnPointerUp,
                onPointerMove: _handelOnPointerMove,
                child: Container(
                  child: NotificationListener(
                      onNotification: (TestNotification note) {
                        setState(() {
                          isFocus = note.isFoucs;
                        });
                      },
                      child: CustomScrollView(
//                  physics: NeverScrollableScrollPhysics(), // 禁用滑动
                          physics: isFocus?new NeverScrollableScrollPhysics():new ClampingScrollPhysics(), // 禁用滑动
                          slivers: <Widget>[
                            SliverToBoxAdapter(
                              child: Column(children: <Widget>[
                                new Text(isFocus?"true":"false"),
                                Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: globals.sidesDistance,
                                        horizontal: globals
                                            .horizontalDistance),
                                    child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: <Widget>[
                                        new Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                        varietyMsg['curPrice']
                                                            .toString(),
                                                        textAlign: TextAlign
                                                            .center,
                                                        style: TextStyle(
                                                            fontSize: 26.0,
                                                            color: Colors
                                                                .black,
                                                            fontWeight: FontWeight
                                                                .w500)),
                                                    Text(
                                                        "${varietyMsg['priceUpdown1']
                                                            .toStringAsFixed(
                                                            2)}  ${varietyMsg['changeRate']
                                                            .toStringAsFixed(
                                                            2)}%",
                                                        textAlign: TextAlign
                                                            .center,
                                                        style: TextStyle(
                                                            fontSize: 13.0,
                                                            color: Colors
                                                                .black,
                                                            fontWeight: null)),
                                                  ],),
                                              ),
                                              Expanded(
                                                child: Column(
                                                    children: <Widget>[
                                                      new Row(
                                                          children: <Widget>[
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                horizontal: 4,),
                                                              child: Text(
                                                                  "高",
                                                                  textAlign: TextAlign
                                                                      .left,
                                                                  style: TextStyle(
                                                                      fontSize: 16.0,
                                                                      color: Color(
                                                                          0xFF666666),
                                                                      fontWeight: FontWeight
                                                                          .w600)),
                                                            )
                                                            ,
                                                            Container(
                                                              child: Text(
                                                                  varietyMsg['highPrice']
                                                                      .toStringAsFixed(
                                                                      2),
                                                                  textAlign: TextAlign
                                                                      .right,
                                                                  style: TextStyle(
                                                                      height: 1.2,
                                                                      fontSize: 16.0,
                                                                      color: Colors
                                                                          .red,
                                                                      fontWeight: FontWeight
                                                                          .w700)),
                                                            )

                                                          ]),
                                                      new Row(
                                                          children: <Widget>[
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                horizontal: 4,),
                                                              child: Text(
                                                                  "低",
                                                                  textAlign: TextAlign
                                                                      .left,
                                                                  style: TextStyle(
                                                                      fontSize: 16.0,
                                                                      color: Color(
                                                                          0xFF666666),
                                                                      fontWeight: FontWeight
                                                                          .w600)),
                                                            )
                                                            ,
                                                            Container(
                                                              child: Text(
                                                                  varietyMsg['lowPrice']
                                                                      .toStringAsFixed(
                                                                      2),
                                                                  textAlign: TextAlign
                                                                      .right,
                                                                  style: TextStyle(
                                                                      height: 1.2,
                                                                      fontSize: 16.0,
                                                                      color: Colors
                                                                          .green,
                                                                      fontWeight: FontWeight
                                                                          .w700)),
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
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                horizontal: 4,),
                                                              child: Text(
                                                                  "开",
                                                                  textAlign: TextAlign
                                                                      .left,
                                                                  style: TextStyle(
                                                                      fontSize: 16.0,
                                                                      color: Color(
                                                                          0xFF666666),
                                                                      fontWeight: FontWeight
                                                                          .w600)),
                                                            )
                                                            ,
                                                            Container(
                                                              child: Text(
                                                                  varietyMsg['openPrice']
                                                                      .toStringAsFixed(
                                                                      2),
                                                                  textAlign: TextAlign
                                                                      .right,
                                                                  style: TextStyle(
                                                                      height: 1.2,
                                                                      fontSize: 16.0,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight: FontWeight
                                                                          .w700)),
                                                            )

                                                          ]),
                                                      new Row(
                                                          children: <Widget>[
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                horizontal: 4,),
                                                              child: Text(
                                                                  "换",
                                                                  textAlign: TextAlign
                                                                      .left,
                                                                  style: TextStyle(
                                                                      fontSize: 16.0,
                                                                      color: Color(
                                                                          0xFF666666),
                                                                      fontWeight: FontWeight
                                                                          .w600)),
                                                            )
                                                            ,
                                                            Container(
                                                              child: Text(
                                                                  varietyMsg['openPrice']
                                                                      .toStringAsFixed(
                                                                      2),
                                                                  textAlign: TextAlign
                                                                      .right,
                                                                  style: TextStyle(
                                                                      height: 1.2,
                                                                      fontSize: 16.0,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight: FontWeight
                                                                          .w700)),
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
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                horizontal: 4,),
                                                              child: Text(
                                                                  "量",
                                                                  textAlign: TextAlign
                                                                      .left,
                                                                  style: TextStyle(
                                                                      fontSize: 16.0,
                                                                      color: Color(
                                                                          0xFF666666),
                                                                      fontWeight: FontWeight
                                                                          .w600)),
                                                            )
                                                            ,
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .fromLTRB(
                                                                  0, 0, 12,
                                                                  0),
                                                              child: Text(
                                                                  "27.55",
                                                                  textAlign: TextAlign
                                                                      .right,
                                                                  style: TextStyle(
                                                                      height: 1.2,
                                                                      fontSize: 16.0,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight: FontWeight
                                                                          .w700)),
                                                            )

                                                          ]),
                                                      new Row(
                                                          children: <Widget>[
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                horizontal: 4,),
                                                              child: Text(
                                                                  "额",
                                                                  textAlign: TextAlign
                                                                      .left,
                                                                  style: TextStyle(
                                                                      fontSize: 16.0,
                                                                      color: Color(
                                                                          0xFF666666),
                                                                      fontWeight: FontWeight
                                                                          .w600)),
                                                            )
                                                            ,
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .fromLTRB(
                                                                  0, 0, 12,
                                                                  0),
                                                              child: Text(
                                                                  "27.55",
                                                                  textAlign: TextAlign
                                                                      .right,
                                                                  style: TextStyle(
                                                                      height: 1.2,
                                                                      fontSize: 16.0,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight: FontWeight
                                                                          .w700)),
                                                            )

                                                          ]),
                                                    ]),
                                              ),
                                            ]),
                                        Positioned(
                                            right: -12.0,
                                            bottom: -22.0,
                                            child: new IconButton(
                                              icon: const Icon(
                                                  Icons.network_cell),
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
                                  height: 500,
                                  child: new Scaffold(
                                    appBar: new AppBar(
                                      automaticallyImplyLeading: false,
                                      //设置标题栏的背景颜色
                                      title: new TabBar(
                                        controller: _tabController,
                                        tabs: myTabs, //使用Tab类型的数组呈现Tab标签
                                        indicatorColor: Colors.white,
                                        isScrollable: true,
                                      ),
                                      elevation: 0,
                                      primary: true,
                                    ),
                                    body: Container(
                                      child: new TabBarView(
                                        physics: new NeverScrollableScrollPhysics(),
                                        // 禁用滑动
                                        controller: _tabController,
                                        children: myTabs.map((
                                            Tab tab) { //遍历List<Tab>类型的对象myTabs并提取其属性值作为子控件的内容
                                          return Builder(
                                            builder: (BuildContext context) {
                                              if (tab.text == '分时') {
                                                return MinKLine(
                                                    openPrice: openPrice,
                                                    stkUniCode: widget
                                                        .stkUniCode);
                                              } else if (tab.text == '日K') {
                                                return DayKLine(
                                                  store: store,);
                                              } else {
                                                return Text('123');
                                              }
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              ),
                            ),
//                    Text('66666666666')
                          ]
                      )),
                ),
              )
          );
        });
      },
    );



  }
}
