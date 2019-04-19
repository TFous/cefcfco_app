/**
 *
 *  缩放动作，计算两点之间的距离（直角三角形斜边），移动前的距离和移动后的距离
 *  通过计算两距离的差值，是否大于 货值（scaleDistance）
 *
 *
 *
 *
 *
 *
 */



import 'dart:async';
import 'dart:math';

import 'package:cefcfco_app/common/config/Config.dart';
import 'package:cefcfco_app/common/model/KLineRepository.dart';
import 'package:cefcfco_app/common/net/Code.dart';
import 'package:cefcfco_app/common/provider/repos/ReadHistoryDbProvider.dart';
import 'package:cefcfco_app/common/utils/KLineDataInEvent.dart';
import 'package:event_bus/event_bus.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cefcfco_app/views/CustomView/KLineComponent.dart';
import 'package:cefcfco_app/common/utils/globals.dart' as globals;
import 'package:cefcfco_app/common/utils/mockData.dart' as mockData;

class MinKLine extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MinKLineState();
  }
}

class MinKLineState extends State<MinKLine> {
  int subscript = 0;
  int index = 0;
  double onHorizontalDragDistance = 0.0; /// 滑动距离
  double initPrice = 55.19;
  double kLineWidth = 8;
  double minKLineWidth = 4.0;
  double maxKLineWidth = 10.0;
  double kLineMargin = 2;
  double canvasWidth;  /// 画布长度，用于计算渲染数据条数
  double sideWidth = 48.0;
  int maxKlinNum; /// 当前klin最大容量个数
  double dragDistance = 3.0; /// 滑动距离，用于判断多长距离请求一次
  double scaleDistance = 18.0; /// 滑动距离，用于判断多长距离请求一次
  Offset onTapDownDtails; /// 点击坐标
  ReadHistoryDbProvider provider = new ReadHistoryDbProvider("DB_minKLine",Config.KLINE_DAY);
  GlobalKey anchorKey = GlobalKey();

  List mockDatas =[];
//  List mockDatas = mockData.mockDatas(100, 60.71, 49.67);
  var historyData;
  //数据源
  List showKLineData = [];

  Offset _canvasOffset = Offset.zero;
  double _scale = 0.90;
  StreamSubscription stream;

  KLineRepository repository;

  Offset startPosition;// 开始接触位置
  Offset endPosition;// 结束接触位置
  int startTouchTime;// 开始接触时间
  int endTouchTime;// 开始接触时间
  int minTouchTime = 150; // 最短接触时间，接触到滑动小于：出现十字左边，显示价格，否则滑动klin
  bool isShowCross = false;  // 是否显示十字坐标
  bool isMoveKLin = false;  // 是否在移动klin
  bool isScale = false;  // 是否缩放
  Map<num,dynamic> pointerDownPositions = {};
  Map<num,dynamic> pointerMovePositions = {};
  int pointerNum = 0; // 手指数量

  @override
  void initState() {
    super.initState();
    mockDatas = mockData.mockKLineData('2019-04-10', initPrice);
//    mockDatas = mockData.mockData();
//    dropTable();
//    mockDatas.forEach((item) async {
//      await provider.insert(item[0],item[1],item[2],item[3],item[4]);
//    });

    stream = Code.eventBus.on<KLineDataInEvent>().listen((event) {
      setState(() {
        repository = event.repository;
      });
    });
  }

  dropTable()async{
    await provider.dropTable();
    print('删除成功');
  }

  getAllData()async{
    return await provider.getAllData();
  }

  getLimitData(limit,offset)async{
    return await provider.getInitData(limit,offset);
  }

  @override
  void dispose() {
    super.dispose();
    if(stream != null) {
      stream.cancel();
      stream = null;
    }
  }


  /// 获取初始化 画布数据
  initCanvasData(width) async{
    var kLineDistance = kLineWidth+kLineMargin;
    var minLeve = width~/kLineDistance;
    var datas = await provider.getAllData();
    var length= datas.length;
    List subList = await getLimitData(minLeve,length-minLeve);
    setState(() {
      canvasWidth = width;
      maxKlinNum = minLeve;
      showKLineData = subList;
    });
  }

  /// type 1:缩放 2：放大
  scaleGetData(width, type) async {
    var skipDistance = 0.5;
    if (type == 1) {
      if (kLineWidth <= minKLineWidth) {
        return;
      }
      dragDistance -= skipDistance;
      if(dragDistance<skipDistance){
        dragDistance = skipDistance;
      }

      kLineWidth = kLineWidth * _scale;
      kLineMargin = kLineMargin * _scale;
    } else if (type == 2) {
      if (kLineWidth >= maxKLineWidth) {
        return;
      }
      dragDistance += skipDistance;
      kLineWidth = kLineWidth * (2 - _scale);
      kLineMargin = kLineMargin * (2 - _scale);
    }

    var kLineDistance = kLineWidth + kLineMargin;
    var minLeve = width ~/ kLineDistance;

    var lastItemTime = showKLineData.last.kLineDate;
    List subList = await provider.getScaleDataByTime(lastItemTime, minLeve);
    setState(() {
      maxKlinNum = minLeve;
      showKLineData = subList;
    });
  }



  Future moveKLine(details) async {
    onHorizontalDragDistance += details.delta.dx;
//    print('onHorizontalDragDistanceonHorizontalDragDistance --- $onHorizontalDragDistance ------- $dragDistance');
    if(details.delta.dx < 0){  /// 向<----滑动，历史数据
      if(onHorizontalDragDistance.abs()>dragDistance){
        onHorizontalDragDistance = 0 ;
        /// 如果是最后时间则没有数据
        if(showKLineData.last.kLineDate.split(' ')[1] == "14:59:59"){
          return;
        }

        var time = showKLineData.first.kLineDate;
        var newList = await provider.getDataByTime(time,maxKlinNum,direction:'left');
        setState(() {
          showKLineData = newList;
        });
      }
    }else{  /// 向--->滑动，最新数据
      if(showKLineData.first.kLineDate.split(' ')[1] == "09:30:59"){
        return;
      }
      if(onHorizontalDragDistance.abs()>dragDistance){
        onHorizontalDragDistance = 0 ;
        var time = showKLineData[showKLineData.length-1].kLineDate;
        var newList = await provider.getDataByTime(time,maxKlinNum,direction:'right');
        setState(() {
          showKLineData = newList;
        });
      }
    }
  }

  /**
   *  PointerEvent  timeStamp  4:45:05.708000
   *  如果小时前没0需要加上0
   *  转换成秒
   */
  int getSecond(Duration timeStamp){
    DateTime second;
    List s =  timeStamp.toString().split(":");
    if(s[0].length==1){
      second = DateTime.parse('2019-04-10 0$timeStamp');
    }else{
      second = DateTime.parse('2019-04-10 $timeStamp');
    }
    return second.millisecondsSinceEpoch;
  }


  /// 开始触摸
  void _handelOnPointerDown(PointerDownEvent details) {
    /// 元素位置
    RenderBox renderBox = anchorKey.currentContext.findRenderObject();
    _canvasOffset =  renderBox.localToGlobal(Offset.zero);

    startTouchTime = getSecond(details.timeStamp);

    startPosition = details.position;
    pointerNum++;
    pointerDownPositions[details.pointer] = details;

    if(pointerDownPositions.length>=2){
      isScale = true;
      isShowCross = false;  //两个手指的时候不显示十字坐标
    }else{
      isScale = false;
    }

    setState(() {
    });

  }

  /// 移动
  Future _handelOnPointerMove(details) async {
    endPosition = details.position;

    /// 滑动Klin, 两个手指的时候不能滑动
    if (!isShowCross && !isScale) {
      moveKLine(details);
    }

    setState(() {
      onTapDownDtails = details.position - _canvasOffset;
    });

    /// 缩放动作
    if(isScale){
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
    }
  }

  /// 结束触摸
  Future _handelOnPointerUp(details) async {
    pointerNum--;
    pointerDownPositions.remove(details.pointer);
    pointerMovePositions.remove(details.pointer);

    if(pointerDownPositions.length<2){
      isScale = false;
    }
    endTouchTime = getSecond(details.timeStamp);
    endPosition = details.position;
    // 十字坐标
    if(endTouchTime-startTouchTime< minTouchTime ){
      setState(() {
        isShowCross = !isShowCross;
        if(isShowCross){
          onTapDownDtails = details.position - _canvasOffset;
        }
      });
    }

  }

  void _handelOnPointerCancel(details) {
    print('_handelOnPointerCancel --------$details');
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width - sideWidth;
    if(canvasWidth != width){
      initCanvasData(width);
    }

    return Container(
      child: Column(
        children: <Widget>[
          Container(
            height: 200,
            padding: EdgeInsets.symmetric(vertical: globals.sidesDistance),
            child: Row(
              children: <Widget>[
                Expanded(
                  child:Listener(
                      child: ClipRect(
                        key: anchorKey,
                        child: new KLineComponent(showKLineData,initPrice,kLineWidth,kLineMargin,onTapDownDtails,isShowCross),
                        // child: Image.network(widget.url,fit: BoxFit.cover,),
                      ),
                      onPointerDown:_handelOnPointerDown,
                      onPointerUp: _handelOnPointerUp,
                      onPointerMove: _handelOnPointerMove,
                      onPointerCancel: _handelOnPointerCancel
                  ),
                ),
                Container(
                  /// 此组件在主轴方向占据48.0逻辑像素
                  width: sideWidth,
                  height: 200,
                  color: Colors.green,
                  child: Text('33333'),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
            decoration: new BoxDecoration(
              border: new Border(bottom: BorderSide(color: Color(0xFFf2f2f2))),
              color: Colors.white,
            ),
            child: ListTile(
              title: new Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(repository!=null?repository.kLineDate.toString().split(' ')[1]:'00', textAlign: TextAlign.left,style: TextStyle(color: Color(0xFF333333))),
                    ),
                    Expanded(
                      child: Text(repository!=null?repository.kLineDate.toString().split(' ')[0]:'时间', textAlign: TextAlign.right,style: TextStyle(fontSize: 13.0,color: Color(0xFF999999),fontWeight: null),),
                    ),
                  ]
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
            decoration: new BoxDecoration(
              border: new Border(bottom: BorderSide(color: Color(0xFFf2f2f2))),
              color: Colors.white,
            ),
            child: ListTile(
              title: new Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(repository!=null?repository.startPrice.toStringAsFixed(2):'00', textAlign: TextAlign.left,style: TextStyle(color: Color(0xFF333333))),
                    ),
                    Expanded(
                      child: Text("当前分钟开盘价格", textAlign: TextAlign.right,style: TextStyle(fontSize: 13.0,color: Color(0xFF999999),fontWeight: null),),
                    ),
                  ]
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
            decoration: new BoxDecoration(
              border: new Border(bottom: BorderSide(color: Color(0xFFf2f2f2))),
              color: Colors.white,
            ),
            child: ListTile(
              title: new Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(repository!=null?repository.endPrice.toStringAsFixed(2):'00', textAlign: TextAlign.left,style: TextStyle(color: Color(0xFF333333))),
                    ),
                    Expanded(
                      child: Text("当前分钟收盘价格", textAlign: TextAlign.right,style: TextStyle(fontSize: 13.0,color: Color(0xFF999999),fontWeight: null),),
                    ),
                  ]
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
            decoration: new BoxDecoration(
              border: new Border(bottom: BorderSide(color: Color(0xFFf2f2f2))),
              color: Colors.white,
            ),
            child: ListTile(
              title: new Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(repository!=null?repository.maxPrice.toStringAsFixed(2):'00', textAlign: TextAlign.left,style: TextStyle(color: Color(0xFF333333))),
                    ),
                    Expanded(
                      child: Text("当前分钟最高价格", textAlign: TextAlign.right,style: TextStyle(fontSize: 13.0,color: Color(0xFF999999),fontWeight: null),),
                    ),
                  ]
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: globals.sidesDistance),
            decoration: new BoxDecoration(
              border: new Border(bottom: BorderSide(color: Color(0xFFf2f2f2))),
              color: Colors.white,
            ),
            child: ListTile(
              title: new Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(repository!=null?repository.minPrice.toStringAsFixed(2):'00', textAlign: TextAlign.left,style: TextStyle(color: Color(0xFF333333))),
                    ),
                    Expanded(
                      child: Text("当前分钟最低价格", textAlign: TextAlign.right,style: TextStyle(fontSize: 13.0,color: Color(0xFF999999),fontWeight: null),),
                    ),
                  ]
              ),
            ),
          ),
//          ListMenus(menusList: menusList)
        ],
      ),
    );
  }
}
