/**
 *
 *  缩放动作，计算两点之间的距离（直角三角形斜边），移动前的距离和移动后的距离
 *  通过计算两距离的差值，是否大于 货值（scaleDistance）
 *
 *   477 条
 *
 *
 *
 *
 */



import 'dart:async';

import 'package:cefcfco_app/common/config/Config.dart';
import 'package:cefcfco_app/common/model/BollPositonsModel.dart';
import 'package:cefcfco_app/common/model/CanvasBollModel.dart';
import 'package:cefcfco_app/common/model/CanvasModel.dart';
import 'package:cefcfco_app/common/model/KLineInfoModel.dart';
import 'package:cefcfco_app/common/model/KLineModel.dart';
import 'package:cefcfco_app/common/model/MInLineModel.dart';
import 'package:cefcfco_app/common/model/MinCanvasModel.dart';
import 'package:cefcfco_app/common/net/Code.dart';
import 'package:cefcfco_app/common/provider/repos/ReadHistoryDbProvider.dart';
import 'package:cefcfco_app/common/utils/KLineDataInEvent.dart';
import 'package:cefcfco_app/common/utils/MockDayData.dart';
import 'package:cefcfco_app/common/utils/MockMinData.dart';
import 'package:cefcfco_app/routers/application.dart';
import 'package:cefcfco_app/views/CustomView/MinKLineComponent.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/views/CustomView/DayKLineComponent.dart';
import 'package:cefcfco_app/views/CustomView/FigureComponent.dart';
import 'package:cefcfco_app/views/CustomView/MinVolumeComponent.dart';
import 'package:cefcfco_app/common/utils/globals.dart' as globals;
import 'package:cefcfco_app/common/utils/KLineUtils.dart';
import 'package:cefcfco_app/common/utils/mockData.dart' as mockData;
import 'package:cefcfco_app/common/utils/router_config.dart' as routerConfig;
class MinKLine extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MinKLineState();
  }
}

class MinKLineState extends State<MinKLine> {
  bool isOnce = true;
  int subscript = 0;
  double onHorizontalDragDistance = 0.0; /// 滑动距离
  double minKLineWidth = 4.0;
  double maxKLineWidth = 26.0;
  double figureComponentHeight = 100.0;
  double kLineComponentHeight = 200.0;

  int minTouchTime = 150; // 最短接触时间，接触到滑动小于：出现十字左边，显示价格，否则滑动klin


  double canvasWidth;  /// 画布长度，用于计算渲染数据条数
  int maxKlineNum; /// 当前klin最大容量个数
  double dragDistance = 2; /// 滑动距离，用于判断多长距离请求一次
  double scaleDistance = 18.0; /// 滑动距离，用于判断多长距离请求一次
  ReadHistoryDbProvider provider = new ReadHistoryDbProvider('DB_DayKLine',Config.KLINE_DAY);
  GlobalKey anchorKey = GlobalKey();

  bool isVolume = true;

  MinCanvasModel _canvasModel = new MinCanvasModel([],12.60,null,false);


  CanvasBollModel bollModel = new CanvasBollModel([],[],[],[],0.0,0.0,7.0,2.0,null,false);
  Offset _canvasOffset = Offset.zero;
  StreamSubscription stream;

  KLineModel repository;

  List<MInLineModel> allMinLineData;

  KLineModel firstData;
  KLineModel lastData;
  Offset startPosition;// 开始接触位置
  Offset endPosition;// 结束接触位置
  int startTouchTime;// 开始接触时间
  int endTouchTime;// 开始接触时间


  @override
  initState(){
    super.initState();
    allMinLineData = mockData.mockMinData(MockMinData.list000001);
//    print('所有数据长度----${allKLineData.length}');

    // evenbus内不能用setstate,不然无限刷新
    stream = Code.eventBus.on<KLineDataInEvent>().listen((event) {
      setState(() {
        repository = event.repository;
      });
    });

  }

  @override
  void dispose() {
    super.dispose();
    if(stream != null) {
      stream.cancel();
      stream = null;
      _canvasModel = null;
    }
  }


  /// 获取初始化 画布数据
  initCanvasData(width) async{

    canvasWidth = width;

    _canvasModel = new MinCanvasModel(allMinLineData,12.60,null,false);
    setState(() {

    });

  }


  void  _handelOnPointerDownVolume(PointerDownEvent details) {
      setState(() {
        isVolume = !isVolume;
      });
  }

  /// 开始触摸
  void _handelOnPointerDown(PointerDownEvent details) {
    /// 元素位置
    RenderBox renderBox = anchorKey.currentContext.findRenderObject();
    _canvasOffset =  renderBox.localToGlobal(Offset.zero);

    startTouchTime = getMillisecondsSinceEpoch();
    startPosition = details.position;

  }

  /// 移动
  Future _handelOnPointerMove(details) async {


    endPosition = details.position;
    /// 滑动Klin, 两个手指的时候不能滑动
    setState(() {
      bollModel.onTapDownDtails = _canvasModel.onTapDownDtails = details.position - _canvasOffset;
    });
    /// 缩放动作
  }

  /// 结束触摸
  Future _handelOnPointerUp(details) async {
    endTouchTime = getMillisecondsSinceEpoch();
    if(endTouchTime-startTouchTime< minTouchTime ){
      setState(() {
        _canvasModel.isShowCross = !_canvasModel.isShowCross;
        if(_canvasModel.isShowCross){
          _canvasModel.onTapDownDtails = details.position - _canvasOffset;
        }
      });
    }

  }

  void _handelOnPointerCancel(details) {
    print('_handelOnPointerCancel --------$details');
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    if(isOnce==true){
      initCanvasData(width-globals.horizontalDistance*2);
      isOnce = false;
    }
    return new Scaffold(
      appBar: new AppBar(
//        automaticallyImplyLeading: false,
        //设置标题栏的背景颜色
        title: new Title(
          child: new Text(
            '分时图',
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
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: kLineComponentHeight,
              margin: EdgeInsets.symmetric(vertical: globals.sidesDistance,horizontal: globals.horizontalDistance),
              child: Listener(
                  child: ClipRect(
                    key: anchorKey,
                    child: new MinKLineComponent(_canvasModel),
                  ),
                  onPointerDown: _handelOnPointerDown,
                  onPointerUp: _handelOnPointerUp,
                  onPointerMove: _handelOnPointerMove,
                  onPointerCancel: _handelOnPointerCancel
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: globals.horizontalDistance),
              height: figureComponentHeight ,
              child: Listener(
                  child: ClipRect(
                    child: new MinVolumeComponent(_canvasModel,isVolume),
                  ),
                  onPointerDown: _handelOnPointerDownVolume,
              ),
            ),
            Container(
                height: 40,
                padding: EdgeInsets.symmetric(vertical: globals.sidesDistance),
                child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: globals.sidesDistance),
                          decoration: new BoxDecoration(
                            border: new Border(
                                bottom: BorderSide(color: Color(0xFFf2f2f2))),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            title: new Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                        repository != null ? repository.date
                                            .toString(): '00',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Color(0xFF333333))),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '时间',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(fontSize: 13.0,
                                          color: Color(0xFF999999),
                                          fontWeight: null),),
                                  ),
                                ]
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: globals.sidesDistance),
                          decoration: new BoxDecoration(
                            border: new Border(
                                bottom: BorderSide(color: Color(0xFFf2f2f2))),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            title: new Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                        repository != null ? repository.open
                                            .toStringAsFixed(2) : '00',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Color(0xFF333333))),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "当前分钟开盘价格", textAlign: TextAlign.right,
                                      style: TextStyle(fontSize: 13.0,
                                          color: Color(0xFF999999),
                                          fontWeight: null),),
                                  ),
                                ]
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: globals.sidesDistance),
                          decoration: new BoxDecoration(
                            border: new Border(
                                bottom: BorderSide(color: Color(0xFFf2f2f2))),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            title: new Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                        repository != null ? repository.close
                                            .toStringAsFixed(2) : '00',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Color(0xFF333333))),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "当前分钟收盘价格", textAlign: TextAlign.right,
                                      style: TextStyle(fontSize: 13.0,
                                          color: Color(0xFF999999),
                                          fontWeight: null),),
                                  ),
                                ]
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: globals.sidesDistance),
                          decoration: new BoxDecoration(
                            border: new Border(
                                bottom: BorderSide(color: Color(0xFFf2f2f2))),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            title: new Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                        repository != null ? repository.high
                                            .toStringAsFixed(2) : '00',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Color(0xFF333333))),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "当前分钟最高价格", textAlign: TextAlign.right,
                                      style: TextStyle(fontSize: 13.0,
                                          color: Color(0xFF999999),
                                          fontWeight: null),),
                                  ),
                                ]
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: globals.sidesDistance),
                          decoration: new BoxDecoration(
                            border: new Border(
                                bottom: BorderSide(color: Color(0xFFf2f2f2))),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            title: new Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                        repository != null ? repository.low
                                            .toStringAsFixed(2) : '00',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Color(0xFF333333))),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "当前分钟最低价格", textAlign: TextAlign.right,
                                      style: TextStyle(fontSize: 13.0, color: Color(0xFF999999),
                                          fontWeight: null),),
                                  ),
                                ]
                            ),
                          ),
                        ),
                      ],
                    )
                )
            ),
//          ListMenus(menusList: menusList)
          ],
        ),
      ),
    );

  }
}
