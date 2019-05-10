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
import 'package:cefcfco_app/common/utils/router_config.dart' as routerConfig;
import 'package:cefcfco_app/common/config/Config.dart';
import 'package:cefcfco_app/common/model/BollPositonsModel.dart';
import 'package:cefcfco_app/common/model/CanvasBollModel.dart';
import 'package:cefcfco_app/common/model/CanvasModel.dart';
import 'package:cefcfco_app/common/model/KLineInfoModel.dart';
import 'package:cefcfco_app/common/model/KLineModel.dart';
import 'package:cefcfco_app/common/net/Code.dart';
import 'package:cefcfco_app/common/provider/repos/ReadHistoryDbProvider.dart';
import 'package:cefcfco_app/common/utils/KLineDataInEvent.dart';
import 'package:cefcfco_app/common/utils/MockDayData.dart';
import 'package:cefcfco_app/routers/application.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/views/CustomView/DayKLineComponent.dart';
import 'package:cefcfco_app/views/CustomView/FigureComponent.dart';
import 'package:cefcfco_app/views/CustomView/VolumeComponent.dart';
import 'package:cefcfco_app/common/utils/globals.dart' as globals;
import 'package:cefcfco_app/common/utils/KLineUtils.dart';
import 'package:cefcfco_app/common/utils/mockData.dart' as mockData;

class DayKLine extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DayKLineState();
  }
}

class DayKLineState extends State<DayKLine> {
  bool isOnce = true;
  int subscript = 0;
  double onHorizontalDragDistance = 0.0; /// 滑动距离
  double minKLineWidth = 4.0;
  double maxKLineWidth = 26.0;
  double figureComponentHeight = 100.0;
  double kLineComponentHeight = 200.0;
  double canvasWidth;  /// 画布长度，用于计算渲染数据条数
  int maxKlineNum; /// 当前klin最大容量个数
  double dragDistance = 2; /// 滑动距离，用于判断多长距离请求一次
  double scaleDistance = 18.0; /// 滑动距离，用于判断多长距离请求一次
  ReadHistoryDbProvider provider = new ReadHistoryDbProvider('DB_DayKLine',Config.KLINE_DAY);
  GlobalKey anchorKey = GlobalKey();

  bool isVolume = true;

  CanvasModel _canvasModel = new CanvasModel([],[],[],[],[],[],new KLineInfoModel(0, 0, 0, 0),7.0,2.0,null,false);

  CanvasBollModel bollModel = new CanvasBollModel([],[],[],[],0.0,0.0,7.0,2.0,null,false);

  Offset _canvasOffset = Offset.zero;
  double _scale = 0.90;
  StreamSubscription stream;

  KLineModel repository;

  List<KLineModel> allKLineData;
  KLineModel firstData;
  KLineModel lastData;
  Offset startPosition;// 开始接触位置
  Offset endPosition;// 结束接触位置
  int startTouchTime;// 开始接触时间
  int endTouchTime;// 结束接触时间
  int minTouchTime = 150; // 最短接触时间，接触到滑动小于：出现十字左边，显示价格，否则滑动klin
  bool isMoveKLin = false;  // 是否在移动klin
  bool isScale = false;  // 是否缩放
  Map<num,dynamic> pointerDownPositions = {};
  Map<num,dynamic> pointerMovePositions = {};
  int pointerNum = 0; // 手指数量

  @override
  initState(){
    super.initState();
    allKLineData = mockData.mockData(MockDayData.list000001);
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
    var kLineDistance = _canvasModel.kLineWidth+_canvasModel.kLineMargin;
    var minLeve = width~/kLineDistance; // k线数量
    firstData = allKLineData.first;
    lastData = allKLineData.last;

    List<KLineModel> newList = getKLineData(allKLineData,[], minLeve,null);
    List<KLineModel> day5Datas = getKLineData(allKLineData,[], minLeve,null,otherDay: 5);
    List<KLineModel> day10Datas = getKLineData(allKLineData,[], minLeve,null,otherDay: 10);
    List<KLineModel> day15Datas = getKLineData(allKLineData,[], minLeve,null,otherDay: 15);
    List<KLineModel> day20Datas = getKLineData(allKLineData,[], minLeve,null,otherDay: 20);

    canvasWidth = width;
    maxKlineNum = minLeve;

    KLineInfoModel kLineListInfo= getKLineInfoModel(newList);
    CanvasModel newCanvasModel = new CanvasModel(
        allKLineData,
        newList,
        day5Datas,
        day10Datas,
        day15Datas,
        day20Datas,
        kLineListInfo,
        _canvasModel.kLineWidth,
        _canvasModel.kLineMargin,
        _canvasModel.onTapDownDtails,
        _canvasModel.isShowCross);

    BollPositonsModel bollData = bollDataToPosition(allKLineData,day20Datas,20,newList,figureComponentHeight,newCanvasModel);
    CanvasBollModel newBollModel = new CanvasBollModel(
        newList,
        bollData.maPointList,
        bollData.upPointList,
        bollData.dnPointList,
        bollData.maxUP,
        bollData.minDN,
        _canvasModel.kLineWidth,
        _canvasModel.kLineMargin,
        _canvasModel.onTapDownDtails,
        _canvasModel.isShowCross);


    setState(() {
      _canvasModel = newCanvasModel;
      bollModel = newBollModel;
    });

  }

  /// type 1:缩放 2：放大
  scaleGetData(width, type) async {
    var kLineWidth,kLineMargin;
    var skipDistance = 0.5;
    if (type == 1) {
      if (_canvasModel.kLineWidth <= minKLineWidth) {
        return;
      }
      dragDistance -= skipDistance;
      if(dragDistance<skipDistance){
        dragDistance = skipDistance;
      }

      kLineWidth = _canvasModel.kLineWidth * _scale;
      kLineMargin = _canvasModel.kLineMargin * _scale;
    } else if (type == 2) {
      if (_canvasModel.kLineWidth >= maxKLineWidth) {
        return;
      }
      dragDistance += skipDistance;
      kLineWidth = _canvasModel.kLineWidth * (2 - _scale);
      kLineMargin = _canvasModel.kLineMargin * (2 - _scale);
    }
    var kLineDistance = kLineWidth + kLineMargin;
    var minLeve = width ~/ kLineDistance;
    var lastItemTime = _canvasModel.showKLineData.last.date;

    List<KLineModel> newList = getScaleDatasByLastTime(allKLineData,lastItemTime, minLeve);
    List<KLineModel> day5Datas = getScaleDatasByLastTime(allKLineData,lastItemTime, minLeve,averageDay: 5);
    List<KLineModel> day10Datas = getScaleDatasByLastTime(allKLineData,lastItemTime, minLeve,averageDay: 10);
    List<KLineModel> day15Datas = getScaleDatasByLastTime(allKLineData,lastItemTime, minLeve,averageDay: 15);
    List<KLineModel> day20Datas = getScaleDatasByLastTime(allKLineData,lastItemTime, minLeve,averageDay: 20);

    KLineInfoModel kLineListInfo= getKLineInfoModel(newList);
    CanvasModel newCanvasModel = new CanvasModel(allKLineData,newList,
        day5Datas,
        day10Datas,
        day15Datas,
        day20Datas,
        kLineListInfo,
        kLineWidth,
        kLineMargin,
        _canvasModel.onTapDownDtails,
        _canvasModel.isShowCross);

    BollPositonsModel bollData = bollDataToPosition(allKLineData,day20Datas,20,newList,100,newCanvasModel);
    CanvasBollModel newBollModel = new CanvasBollModel(
        newList,
        bollData.maPointList,
        bollData.upPointList,
        bollData.dnPointList,
        bollData.maxUP,
        bollData.minDN,
        kLineWidth,
        kLineMargin,
        _canvasModel.onTapDownDtails,
        _canvasModel.isShowCross);

    setState(() {
      _canvasModel = newCanvasModel;
      bollModel = newBollModel;
    });

    maxKlineNum = minLeve;
  }

  /// 左右移动
  moveKLine(details) async {
    onHorizontalDragDistance += details.delta.dx;
    if(details.delta.dx < 0){  /// 向左滑动，新数据
      if(onHorizontalDragDistance.abs()>dragDistance){
        onHorizontalDragDistance = 0 ;
        /// 如果是最后时间则没有数据
        if(_canvasModel.showKLineData.last.date == lastData.date){
          return ;
        }

        List<KLineModel> newList = getKLineData(allKLineData,_canvasModel.showKLineData, maxKlineNum,'left');
        List day5Datas = getKLineData(allKLineData,_canvasModel.day5Data, maxKlineNum,'left',otherDay: 5);
        List day10Datas = getKLineData(allKLineData,_canvasModel.day10Data, maxKlineNum,'left',otherDay: 10);
        List day15Datas = getKLineData(allKLineData,_canvasModel.day15Data, maxKlineNum,'left',otherDay: 15);
        List day20Datas = getKLineData(allKLineData,_canvasModel.day20Data, maxKlineNum,'left',otherDay: 20);


        KLineInfoModel kLineListInfo= getKLineInfoModel(newList);
        CanvasModel newCanvasModel = new CanvasModel(
            allKLineData,
            newList,
            day5Datas,
            day10Datas,
            day15Datas,
            day20Datas,
            kLineListInfo,
            _canvasModel.kLineWidth,
            _canvasModel.kLineMargin,
            _canvasModel.onTapDownDtails,
            _canvasModel.isShowCross);

        BollPositonsModel bollData = bollDataToPosition(allKLineData,day20Datas,20,newList,figureComponentHeight,newCanvasModel);
        CanvasBollModel newBollModel = new CanvasBollModel(
            newList,
            bollData.maPointList,
            bollData.upPointList,
            bollData.dnPointList,
            bollData.maxUP,
            bollData.minDN,
            _canvasModel.kLineWidth,
            _canvasModel.kLineMargin,
            _canvasModel.onTapDownDtails,
            _canvasModel.isShowCross);

        setState(() {
          bollModel = newBollModel;
          _canvasModel = newCanvasModel;
        });
      }
    }else{  /// 向右滑动，旧数据
      if(_canvasModel.showKLineData.first.date == firstData.date){
        return;
      }
        if(onHorizontalDragDistance.abs()>dragDistance){
          onHorizontalDragDistance = 0 ;

          List<KLineModel> newList = getKLineData(allKLineData,_canvasModel.showKLineData, maxKlineNum,'right');
          List day5Datas = getKLineData(allKLineData,_canvasModel.day5Data, maxKlineNum,'right',otherDay: 5);
          List day10Datas = getKLineData(allKLineData,_canvasModel.day10Data, maxKlineNum,'right',otherDay: 10);
          List day15Datas = getKLineData(allKLineData,_canvasModel.day15Data, maxKlineNum,'right',otherDay: 15);
          List day20Datas = getKLineData(allKLineData,_canvasModel.day20Data, maxKlineNum,'right',otherDay: 20);

          KLineInfoModel kLineListInfo= getKLineInfoModel(newList);
          CanvasModel newCanvasModel = new CanvasModel(
              allKLineData,
              newList,
              day5Datas,
              day10Datas,
              day15Datas,
              day20Datas,
              kLineListInfo,
              _canvasModel.kLineWidth,
              _canvasModel.kLineMargin,
              _canvasModel.onTapDownDtails,
              _canvasModel.isShowCross);
          
          BollPositonsModel bollData = bollDataToPosition(allKLineData,day20Datas,20,newList,figureComponentHeight,newCanvasModel);

          CanvasBollModel newBollModel = new CanvasBollModel(
              newList,
              bollData.maPointList,
              bollData.upPointList,
              bollData.dnPointList,
              bollData.maxUP,
              bollData.minDN,
              _canvasModel.kLineWidth,
              _canvasModel.kLineMargin,
              _canvasModel.onTapDownDtails,
              _canvasModel.isShowCross);

          setState(() {
            bollModel = newBollModel;
            _canvasModel = newCanvasModel;
          });
        }
    }
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
    pointerNum++;
    pointerDownPositions[details.pointer] = details;

    if(pointerDownPositions.length>=2){
      isScale = true;
      setState(() {
        bollModel.isShowCross=_canvasModel.isShowCross = false;  //两个手指的时候不显示十字坐标
      });
    }else{
      isScale = false;
    }

  }

  /// 移动
  Future _handelOnPointerMove(details) async {

    endPosition = details.position;
    /// 滑动Klin, 两个手指的时候不能滑动
    if (!_canvasModel.isShowCross && !isScale) {
      moveKLine(details);
    }else if(isScale){
      if(details.delta.dx!=0 && details.delta.dy!=0){
        var pointerKey = details.pointer;
        var otherOpinterKey;
        pointerMovePositions[pointerKey] = details;
        for(var key in pointerDownPositions.keys){
          if(key != pointerKey){
            otherOpinterKey = key;
          }
        }
        var px,py; /// 初始的时候一个手指动，就和另外一个初始点比较距离
        if(pointerMovePositions[otherOpinterKey] == null){
          px = pointerDownPositions[otherOpinterKey].position.dx;
          py = pointerDownPositions[otherOpinterKey].position.dy;
        }else{
          px = pointerMovePositions[otherOpinterKey].position.dx;
          py = pointerMovePositions[otherOpinterKey].position.dy;
        }

        var a = (pointerMovePositions[pointerKey].position.dx-px).abs();
        var b = (pointerMovePositions[pointerKey].position.dy-py).abs();
        var pointerMovePositionsDistance = a + b;  // 距离直角三角形斜边

        var a1 = (pointerDownPositions[pointerKey].position.dx-pointerDownPositions[otherOpinterKey].position.dx).abs();
        var b1 = (pointerDownPositions[pointerKey].position.dy-pointerDownPositions[otherOpinterKey].position.dy).abs();
        var pointerDownPositionsDistance = a1+b1;

        if(pointerDownPositionsDistance<pointerMovePositionsDistance){
          if((pointerDownPositionsDistance-pointerMovePositionsDistance).abs()>scaleDistance){
//              print('放大 ---------${pointerMovePositionsDistance - pointerDownPositionsDistance}');
            pointerDownPositions[pointerKey] = pointerMovePositions[pointerKey];
            scaleGetData(canvasWidth,2);
          }
        }else{
          if((pointerDownPositionsDistance-pointerMovePositionsDistance).abs()>scaleDistance){
//              print('缩放 ---------${pointerMovePositionsDistance - pointerDownPositionsDistance}');
            pointerDownPositions[pointerKey] = pointerMovePositions[pointerKey];
            scaleGetData(canvasWidth,1);
          }
        }
      }
    }else{
      setState(() {
        bollModel.onTapDownDtails = _canvasModel.onTapDownDtails = details.position - _canvasOffset;
      });
    }
    /// 缩放动作
  }

  /// 结束触摸
  Future _handelOnPointerUp(details) async {
    pointerNum--;
    pointerDownPositions.remove(details.pointer);
    pointerMovePositions.remove(details.pointer);

    if(pointerDownPositions.length<2){
      isScale = false;
    }
    endTouchTime = getMillisecondsSinceEpoch();
    endPosition = details.position;
    // 十字坐标
    if(endTouchTime-startTouchTime< minTouchTime ){
      setState(() {
        _canvasModel.isShowCross = !_canvasModel.isShowCross;
        if(_canvasModel.isShowCross){
          bollModel.onTapDownDtails = _canvasModel.onTapDownDtails = details.position - _canvasOffset;
        }

        bollModel.isShowCross = !bollModel.isShowCross;
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
            'K线图',
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
                    child: new DayKLineComponent(_canvasModel),
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
                    child: new VolumeComponent(_canvasModel,isVolume),
                  ),
                  onPointerDown: _handelOnPointerDownVolume,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: globals.sidesDistance,horizontal: globals.horizontalDistance),
              height: figureComponentHeight ,
              child: ClipRect(
                child: new FigureComponent(bollModel),
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
