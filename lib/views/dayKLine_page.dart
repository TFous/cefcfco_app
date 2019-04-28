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
import 'dart:math';

import 'package:cefcfco_app/common/config/Config.dart';
import 'package:cefcfco_app/common/config/KLineConfig.dart';
import 'package:cefcfco_app/common/model/BollPositonsModel.dart';
import 'package:cefcfco_app/common/model/CanvasBollModel.dart';
import 'package:cefcfco_app/common/model/CanvasModel.dart';
import 'package:cefcfco_app/common/model/KLineModel.dart';
import 'package:cefcfco_app/common/net/Code.dart';
import 'package:cefcfco_app/common/provider/repos/ReadHistoryDbProvider.dart';
import 'package:cefcfco_app/common/utils/KLineDataInEvent.dart';
import 'package:event_bus/event_bus.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/views/CustomView/DayKLineComponent.dart';
import 'package:cefcfco_app/views/CustomView/FigureComponent.dart';
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
  double maxKLineWidth = 50.0;
  double canvasWidth;  /// 画布长度，用于计算渲染数据条数
  int maxKlineNum; /// 当前klin最大容量个数
  double dragDistance = 2; /// 滑动距离，用于判断多长距离请求一次
  double scaleDistance = 18.0; /// 滑动距离，用于判断多长距离请求一次
  ReadHistoryDbProvider provider = new ReadHistoryDbProvider('DB_DayKLine',Config.KLINE_DAY);
  GlobalKey anchorKey = GlobalKey();
  GlobalKey anchorKey1 = GlobalKey();

  CanvasModel _canvasModel = new CanvasModel([],[],[],[],[],0.0,0.0,38.0,2.0,null,false);

  CanvasBollModel bollModel = new CanvasBollModel([], [],[],[],[],0.0,0.0,38.0,2.0,null,false);

  Offset _canvasOffset = Offset.zero;
  Offset _canvasOffset1 = Offset.zero;
  double _scale = 0.90;
  StreamSubscription stream;

  KLineModel repository;

  List<KLineModel> allKLineData;
  KLineModel firstData;
  KLineModel lastData;
  Offset startPosition;// 开始接触位置
  Offset endPosition;// 结束接触位置
  int startTouchTime;// 开始接触时间
  int endTouchTime;// 开始接触时间
  int minTouchTime = 150; // 最短接触时间，接触到滑动小于：出现十字左边，显示价格，否则滑动klin
  bool isMoveKLin = false;  // 是否在移动klin
  bool isScale = false;  // 是否缩放
  Map<num,dynamic> pointerDownPositions = {};
  Map<num,dynamic> pointerMovePositions = {};
  int pointerNum = 0; // 手指数量

  @override
  initState(){
    super.initState();
    allKLineData = mockData.mockData(globals.kLine);
    print('所有数据长度----${allKLineData.length}');
    stream = Code.eventBus.on<KLineDataInEvent>().listen((event) {
      setState(() {
        repository = event.repository;
      });
    });
  }


  /// 初始化获取适应屏幕的数据
  List<KLineModel> getLimitDatas(List<KLineModel> allData,int start,int end){
    List<KLineModel> list = allData.sublist(start,end);
    return list;
  }

  /// 缩放后根据最后一个item 的时间 获取数据
  List<KLineModel> getScaleDatasByLastTime(List<KLineModel> allData,String lastItemTime,int length,{averageDay}){
    int dataLength = allData.length;
    List<KLineModel> list = [];
    int i=0;
    if(averageDay!=null){
      for(;i<dataLength;i++){
        if(allData[i].kLineDate == lastItemTime){
          /// 当最后的index（前面数据的条数）小于 要获取的条数
          if(i<length){
            list = allData.sublist(0,length);
          }else{
            if (i - length-averageDay + 1 <=0) { /// 当最后的index（前面数据的条数）小于（length+averageDay - 1 ）所需要划线的数据，则直接取前面所有的数据
              list = allData.sublist(0, i + 1);
            } else {
              list = allData.sublist(i - length - averageDay + 1, i + 1);
            }
          }
        }
      }
    }else{
      for(;i<dataLength;i++){
        if(allData[i].kLineDate == lastItemTime){
          /// 当最后的index（前面数据的条数）小于 要获取的条数
          if(i<length){
            list = allData.sublist(0,length);
          }else{
            list = allData.sublist(i-length+1,i+1);
          }
        }
      }
    }
    return list;
  }


  /// 左右移动的数据
  /// averageDay 有志的话则为 均价 天数
  List<KLineModel> getPointerMoveDatas(List<KLineModel> allData,String time,int length,String direction,{averageDay}){
    List<KLineModel> list = [];
    int allDataLength = allData.length;
    int i=0;
    /// 先取得正常的数据
    for(;i<allDataLength;i++){
      if(allData[i].kLineDate == time){
        if(direction=='right'){
          int start = i-length-1;
          int end = i;
          if(start<0){
            start = 0;
            end = length;
          }
          list = allData.sublist(start,end);
        }else{
          int start = i+1;
          int end = i+length+1;
          if(end>allDataLength){
            start = allDataLength-length-1;
            end = allDataLength-1;
          }
          list = allData.sublist(start,end);
        }
      }
    }


    List<KLineModel> averageDayList = [];
    /// 是否是均价数据
    if(averageDay!=null){
      var listFirstTime = list.first.kLineDate;
      int dayLength = averageDay-1;
      if(direction=='right'){
        int j = 0;
        for (; j < allDataLength; j++) {
          if (allData[j].kLineDate == listFirstTime) {
            int start = j - dayLength;
            int end = j;
            /// 当在最左边是，如果start 小于0，则前面的数据不够，所以要获取前面的所有数据
            if (start < 0) {
              if (j != 0) {
                averageDayList = allData.sublist(0, j);
                list = averageDayList + list;
              }
            } else {
              averageDayList = allData.sublist(start, end);
              list = averageDayList + list;
            }
          }
        }
      }else{
        int j=0;
        for (; j < allDataLength; j++) {
          if (allData[j].kLineDate == listFirstTime) {
            int start = j - dayLength;
            int end = j;
            if (start < 0) {
              averageDayList = allData.sublist(0, j);
              list = averageDayList + list;
            } else {
              averageDayList = allData.sublist(start, end);
              list = averageDayList + list;
            }
          }
        }
      }
    }
    return list;
  }


  /// 获取当前所有数据中最高和最低值
  Map<String, double> getMaxAndMin(lineData) {
    double maxPrice;
    double minPrice;
    lineData.forEach((item) {
      if (maxPrice != null) {
        if (maxPrice < item.maxPrice) {
          maxPrice = item.maxPrice;
        }
        if (minPrice > item.minPrice) {
          minPrice = item.minPrice;
        }
      } else {
        maxPrice = item.maxPrice;
        minPrice = item.minPrice;
      }
    });

    return {
      "maxPrice": maxPrice*(1+KLineConfig.HEIGHT_LIMIT),
      "minPrice": minPrice*(1-KLineConfig.HEIGHT_LIMIT)
    };
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

    Map maxAndMin = getMaxAndMin(newList);

    canvasWidth = width;
    maxKlineNum = minLeve;

    var dayMaxPrice = maxAndMin['maxPrice']??0.0;
    var dayMinPrice = maxAndMin['minPrice']??0.0;
    CanvasModel newCanvasModel = new CanvasModel(newList,
        day5Datas,
        day10Datas,
        day15Datas,
        day20Datas,
        dayMaxPrice,
        dayMinPrice,
        _canvasModel.kLineWidth,
        _canvasModel.kLineMargin,
        _canvasModel.onTapDownDtails,
        _canvasModel.isShowCross);

    BollPositonsModel bollData = bollDataToPosition(day20Datas,20,newList,100,newCanvasModel);
    CanvasBollModel newBollModel = new CanvasBollModel(
        bollData.historyData,
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
    var lastItemTime = _canvasModel.showKLineData.last.kLineDate;

    List<KLineModel> newList = getScaleDatasByLastTime(allKLineData,lastItemTime, minLeve);
    List<KLineModel> day5Datas = getScaleDatasByLastTime(allKLineData,lastItemTime, minLeve,averageDay: 5);
    List<KLineModel> day10Datas = getScaleDatasByLastTime(allKLineData,lastItemTime, minLeve,averageDay: 10);
    List<KLineModel> day15Datas = getScaleDatasByLastTime(allKLineData,lastItemTime, minLeve,averageDay: 15);
    List<KLineModel> day20Datas = getScaleDatasByLastTime(allKLineData,lastItemTime, minLeve,averageDay: 20);



    Map maxAndMin = getMaxAndMin(newList);

    var dayMaxPrice = maxAndMin['maxPrice']??0.0;
    var dayMinPrice = maxAndMin['minPrice']??0.0;
    CanvasModel newCanvasModel = new CanvasModel(newList,
        day5Datas,
        day10Datas,
        day15Datas,
        day20Datas,
        dayMaxPrice,
        dayMinPrice,
        kLineWidth,
        kLineMargin,
        _canvasModel.onTapDownDtails,
        _canvasModel.isShowCross);

    BollPositonsModel bollData = bollDataToPosition(day20Datas,20,newList,100,newCanvasModel);
    CanvasBollModel newBollModel = new CanvasBollModel(
        bollData.historyData,
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

    maxKlineNum = minLeve;
  }

  /// 左右移动
  moveKLine(details) async {
    onHorizontalDragDistance += details.delta.dx;
    if(details.delta.dx < 0){  /// 向<----滑动，历史数据
      if(onHorizontalDragDistance.abs()>dragDistance){
        onHorizontalDragDistance = 0 ;
        /// 如果是最后时间则没有数据
        if(_canvasModel.showKLineData.last.kLineDate == lastData.kLineDate){
          return ;
        }
          var time = _canvasModel.showKLineData.first.kLineDate;
          var newList = getPointerMoveDatas(allKLineData,time,maxKlineNum,'left');
          List day5Datas = getPointerMoveDatas(allKLineData,time,maxKlineNum,'left',averageDay:5);
          List day10Datas = getPointerMoveDatas(allKLineData,time,maxKlineNum,'left',averageDay:10);
          List day15Datas = getPointerMoveDatas(allKLineData,time,maxKlineNum,'left',averageDay:15);
          List day20Datas = getPointerMoveDatas(allKLineData,time,maxKlineNum,'left',averageDay:20);


        List<KLineModel> newList2 = getKLineData(allKLineData,_canvasModel.showKLineData, maxKlineNum,'left');
        List<KLineModel> day5Datas2 = getKLineData(allKLineData,_canvasModel.day5Data, maxKlineNum,'left',otherDay: 5);

        print('${_canvasModel.day5Data.first.kLineDate}');
        print('last-----${_canvasModel.day5Data.last.kLineDate}');
//        print('newList2---${newList.length}--${newList2.length}--${newList.first.kLineDate==newList2.first.kLineDate}--${newList.last.kLineDate==newList2.last.kLineDate}');
        print('day5Datas2---${day5Datas.length}--${day5Datas2.length}--${day5Datas.first.kLineDate==day5Datas2.first.kLineDate}--${day5Datas.last.kLineDate==day5Datas2.last.kLineDate}');
        print('day5Datas2---${day5Datas.first.kLineDate}--${day5Datas2.first.kLineDate}--${day5Datas.last.kLineDate}--${day5Datas2.last.kLineDate}');
//        print('${newList.length}--${newList2.length}--${newList.first.kLineDate}--${newList2.first.kLineDate}--${newList.last.kLineDate}--${newList2.last.kLineDate}');


        Map maxAndMin = getMaxAndMin(newList);

          var dayMaxPrice = maxAndMin['maxPrice']??0.0;
          var dayMinPrice = maxAndMin['minPrice']??0.0;
          CanvasModel newCanvasModel = new CanvasModel(newList,
              day5Datas,
              day10Datas,
              day15Datas,
              day20Datas,
              dayMaxPrice,
              dayMinPrice,
              _canvasModel.kLineWidth,
              _canvasModel.kLineMargin,
              _canvasModel.onTapDownDtails,
              _canvasModel.isShowCross);

        List<KLineModel> day22Datas = getKLineData(allKLineData,_canvasModel.day20Data, maxKlineNum,'left',otherDay: 20);
        BollPositonsModel bollData = bollDataToPosition(day22Datas,20,newList,100,newCanvasModel);



        CanvasBollModel newBollModel = new CanvasBollModel(
            bollData.historyData,
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
    }else{  /// 向--->滑动，最新数据
      if(_canvasModel.showKLineData.first.kLineDate == firstData.kLineDate){
        return;
      }
        if(onHorizontalDragDistance.abs()>dragDistance){
          onHorizontalDragDistance = 0 ;
          var time = _canvasModel.showKLineData.last.kLineDate;
//          List<KLineModel> newList = getPointerMoveDatas(allKLineData,time,maxKlineNum,'right');
          List<KLineModel> newList = getKLineData(allKLineData,_canvasModel.showKLineData, maxKlineNum,'right');

          List day5Datas = getKLineData(allKLineData,_canvasModel.day5Data, maxKlineNum,'right',otherDay: 5);
          List day10Datas = getKLineData(allKLineData,_canvasModel.day10Data, maxKlineNum,'right',otherDay: 10);
          List day15Datas = getKLineData(allKLineData,_canvasModel.day15Data, maxKlineNum,'right',otherDay: 15);
          List day20Datas = getKLineData(allKLineData,_canvasModel.day20Data, maxKlineNum,'right',otherDay: 20);

          Map maxAndMin = getMaxAndMin(newList);

          print('${_canvasModel.showKLineData.first.kLineDate}');
          print('last-----${newList.last.kLineDate}');
//        print('newList2---${newList.length}--${newList.length}--${newList.first.kLineDate==newList2.first.kLineDate}--${newList.last.kLineDate==newList2.last.kLineDate}');

          var dayMaxPrice = maxAndMin['maxPrice']??0.0;
          var dayMinPrice = maxAndMin['minPrice']??0.0;
          CanvasModel newCanvasModel = new CanvasModel(
              newList,
              day5Datas,
              day10Datas,
              day15Datas,
              day20Datas,
              dayMaxPrice,
              dayMinPrice,
              _canvasModel.kLineWidth,
              _canvasModel.kLineMargin,
              _canvasModel.onTapDownDtails,
              _canvasModel.isShowCross);


          BollPositonsModel bollData = bollDataToPosition(day20Datas,20,newList,100,newCanvasModel);
          CanvasBollModel newBollModel = new CanvasBollModel(
              bollData.historyData,
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
    }
  }

  /// 当前时间转换成秒
  int getMillisecondsSinceEpoch(){
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// 开始触摸
  void _handelOnPointerDown(PointerDownEvent details) {
    /// 元素位置
    RenderBox renderBox = anchorKey.currentContext.findRenderObject();
    _canvasOffset =  renderBox.localToGlobal(Offset.zero);
    RenderBox renderBox1 = anchorKey1.currentContext.findRenderObject();
    _canvasOffset1 =  renderBox1.localToGlobal(Offset.zero);

    startTouchTime = getMillisecondsSinceEpoch();

    startPosition = details.position;
    pointerNum++;
    pointerDownPositions[details.pointer] = details;

    if(pointerDownPositions.length>=2){
      isScale = true;
      _canvasModel.isShowCross = false;  //两个手指的时候不显示十字坐标
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
        _canvasModel.onTapDownDtails = details.position - _canvasOffset;
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
          _canvasModel.onTapDownDtails = details.position - _canvasOffset;
        }


//        bollModel.isShowCross = !bollModel.isShowCross;
//        if(bollModel.isShowCross){
//          bollModel.onTapDownDtails = details.position - _canvasOffset;
//        }
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
      initCanvasData(width);
      isOnce = false;
    }
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            height: 230,
            padding: EdgeInsets.symmetric(vertical: globals.sidesDistance),
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
            height: 100 ,
            padding: EdgeInsets.symmetric(vertical: globals.sidesDistance),
            child: ClipRect(
              key: anchorKey1,
              child: new FigureComponent(bollModel),
            ),
          ),
          Container(
              height: 150,
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
                                      repository != null ? repository.kLineDate
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
                                      repository != null ? repository.startPrice
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
                                      repository != null ? repository.endPrice
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
                                      repository != null ? repository.maxPrice
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
                                      repository != null ? repository.minPrice
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
    );
  }
}
