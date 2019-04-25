import 'dart:ui';

import 'package:cefcfco_app/common/model/KLineModel.dart';
import 'package:cefcfco_app/common/net/Code.dart';
import 'package:cefcfco_app/common/utils/KLineDataInEvent.dart';
import 'package:cefcfco_app/common/utils/monotonex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';

///自定义  饼状图
/// @author yinl
class FigureComponent extends StatelessWidget{
  //数据源
  var canvasModel;
  List day10Data;
  List day5Data;
  double initPrice;
  double kLineWidth;
  Offset onTapDownDtails;
  double kLineMargin;
  bool isShowCross;
  double dayMinPrice;
  double dayMaxPrice;

  FigureComponent(this.canvasModel);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      child: CustomPaint(
          painter: MyView(canvasModel)
      ),
    );
  }

}

class MyView extends CustomPainter{
  double animValue;
  Paint _mPaint;
  Paint _linePaint;
  Paint TextPaint;
  Paint _EqualLinePaint;
  double initPrice;
  List kLineOffsets = []; /// k线位置[[dx,dy]]
  double lineWidth = 1.4;/// 线的宽度  譬如十字坐标
  var canvasModel;

  var startAngles=[];

  MyView(this.canvasModel);

  void _drawSmoothLine(Canvas canvas, Paint paint, List<Point> points) {
    final path = new Path()
      ..moveTo(points.first.x.toDouble(), points.first.y.toDouble());
    MonotoneX.addCurve(path, points);
    canvas.drawPath(path, paint);
  }

  /// 取得相应天数的平均数和所在的 位置 公式：当前时间加上当前的前day-1天的数据/day
  ///  averagePricesData  用于算平均数的数据:比当前画布的数据多出 day-1 条，如果不多出的话，则前几天是没有平均数的
  ///  day  几天的平均
  ///  canvasHeight 画布高度
  ///  kLineDataLength  当前画布中的数据
  ///
  List<Point> getAverageLineData(List<KLineModel>averagePricesData,int day,canvasHeight,int kLineDataLength) {
    int length = averagePricesData.length; //平均数的数据
    if(length<day){
      print('getAverageLineData:当前数据数量太少！');
      return [];
    }
    List<Point> averagePrices= [];
    int i = 0;
    int index = 0;
    for(;i<length;i++){
      if(i<=length-day){
        List<KLineModel> listForDay = averagePricesData.sublist(i,i+day);
        if(length<kLineDataLength+day){
          index = i+(day-(length-kLineDataLength)-1);
        }else{
          index = i;
        }
        Point averagePricePoint = getAveragePricePoint(listForDay,day,index,canvasHeight);
        averagePrices.add(averagePricePoint);
      }

    }
    return averagePrices;
  }




  List<Point> getUPPointList(List<KLineModel>averagePricesData,int day,canvasHeight,int kLineDataLength) {
    int length = averagePricesData.length; //平均数的数据
    if(length<day){
      print('getAverageLineData:当前数据数量太少！');
      return [];
    }
    List<Point> pointList= [];
    int i = 0;
    int index = 0;
    for(;i<length;i++){
      if(i<=length-day){
        List<KLineModel> listForDay = averagePricesData.sublist(i,i+day);
        if(length<kLineDataLength+day){
          index = i+(day-(length-kLineDataLength)-1);
        }else{
          index = i;
        }
        Point mdPoint = getUPPoint(listForDay,day,index,canvasHeight);
        pointList.add(mdPoint);
      }

    }
    return pointList;
  }

  List<Point> getDNPointList(List<KLineModel>averagePricesData,int day,canvasHeight,int kLineDataLength) {
    int length = averagePricesData.length; //平均数的数据
    if(length<day){
      print('getAverageLineData:当前数据数量太少！');
      return [];
    }
    List<Point> pointList= [];
    int i = 0;
    int index = 0;
    for(;i<length;i++){
      if(i<=length-day){
        List<KLineModel> listForDay = averagePricesData.sublist(i,i+day);
        if(length<kLineDataLength+day){
          index = i+(day-(length-kLineDataLength)-1);
        }else{
          index = i;
        }
        Point mdPoint = getDNPoint(listForDay,day,index,canvasHeight);
        pointList.add(mdPoint);
      }
    }
    return pointList;
  }

  double getVariance(c,ma){
    double num = c-ma;
    return num*num;
  }

  /// length 几日
  double getMdData(List<KLineModel> list,int length){
    double addAll=0; // 累加总数，用于计算平均数
    double allVariance=0;  // 累加差值，用于计算md
    list.asMap().forEach((index,num){
      addAll+=num.endPrice;
      double ma = addAll/(index+1);
      double a = getVariance(num.endPrice,ma);
      allVariance+=a;
    });
    return sqrt(allVariance/length);
  }


  double getUP(double mb,double md){
    double num = mb+md*2;
    return num;
  }

  double getDN(double mb,double md){
    double num = mb-md*2;
    return num;
  }
  /// 获取平均数 并 转换成点
  /// data 行情数据
  /// day 几天，5日行情，10日行情
  Point getAveragePricePoint(List<KLineModel>kLineDatas,int day,int lineIndex,canvasHeight){
    int length = kLineDatas.length;
    if(length<day){
      print('当前数据数量太少！-----length:$length');
      return null;
    }
    var averagePrice=0.0;
    int i = 0;
    for(;i<length;i++){
      averagePrice+=kLineDatas[i].endPrice;
    }

    var kLineDistance = canvasModel.kLineWidth + canvasModel.kLineMargin;
    double dx = (kLineDistance*lineIndex+canvasModel.kLineMargin + kLineDistance*lineIndex+kLineDistance)/2;

    double dy = priceToPositionDy(averagePrice/day,canvasHeight);
    Point position =  Point(dx,dy);
//    print('当前数据数量太少！-----:$kLineDatas---$lineIndex');
//    print('当前数据数量太少！-----:$position---$lineIndex');
    return position;
  }

  Point getUPPoint(List<KLineModel>kLineDatas,int day,int lineIndex,canvasHeight){
    int length = kLineDatas.length;
    if(length<day){
      print('当前数据数量太少！-----length:$length');
      return null;
    }
    var averagePrice=0.0;
    int i = 0;
    for(;i<length;i++){
      averagePrice+=kLineDatas[i].endPrice;
    }

    var kLineDistance = canvasModel.kLineWidth + canvasModel.kLineMargin;
    double dx = (kLineDistance*lineIndex+canvasModel.kLineMargin + kLineDistance*lineIndex+kLineDistance)/2;
    double mb = averagePrice/day;


    print('$day-----------$length');
    double c = kLineDatas.last.endPrice;
    double md = getMdData(kLineDatas, day);
    double up = getUP(mb, md);

    double dy = priceToPositionDy(up,canvasHeight);

    Point position =  Point(dx,dy);
//    print('当前数据数量太少！-----:$kLineDatas---$lineIndex');
//    print('当前数据数量太少！-----:$position---$lineIndex');
    return position;
  }
  Point getDNPoint(List<KLineModel>kLineDatas,int day,int lineIndex,canvasHeight){
    int length = kLineDatas.length;
    if(length<day){
      print('当前数据数量太少！-----length:$length');
      return null;
    }
    var averagePrice=0.0;
    int i = 0;
    for(;i<length;i++){
      averagePrice+=kLineDatas[i].endPrice;
    }

    var kLineDistance = canvasModel.kLineWidth + canvasModel.kLineMargin;
    double dx = (kLineDistance*lineIndex+canvasModel.kLineMargin + kLineDistance*lineIndex+kLineDistance)/2;
    double mb = averagePrice/day;
    double c = kLineDatas.last.endPrice;
    double md = getMdData(kLineDatas, day);
    double dn = getDN(mb, md);
    double dy = priceToPositionDy(dn,canvasHeight);

    Point position =  Point(dx,dy);
//    print('当前数据数量太少！-----:$kLineDatas---$lineIndex');
//    print('当前数据数量太少！-----:$position---$lineIndex');
    return position;
  }




  double priceToPositionDy(nowPrice,canvasHeight){
    double initPrice = (canvasModel.dayMaxPrice+canvasModel.dayMinPrice)/2;
    double dy = canvasHeight / 2 - ((nowPrice - initPrice) / (canvasModel.dayMaxPrice - initPrice) * canvasHeight /
            2);
    return dy;
  }




  /// 当前横线位置的价格
  void drawPrice(Canvas canvas,lineDyPrice,initPriceText,lineDx,lineDy,canvasWidth,canvasHeight){
    double copyLineDyPrice; // 判断是否一样，防止不不停刷新
    if(lineDyPrice!=copyLineDyPrice){
      copyLineDyPrice = lineDyPrice;
      var initPriceTextHeight = initPriceText.height/2;

      var left = 0.0;
      var right = initPriceText.width;
      var top = lineDy - initPriceTextHeight;
      var bottom = lineDy + initPriceTextHeight;
      /// 上下边界价格显示
      if(lineDy<initPriceTextHeight){
        top = 0.0;
        bottom = initPriceText.height;
      }else if(lineDy>canvasHeight-initPriceText.height){
        top = canvasHeight-initPriceText.height;
        bottom = canvasHeight;
      }

      /// 价格显示在左还是右边 ，canvas 一半
      if(lineDx<canvasWidth/2){
        right = canvasWidth;
        left = canvasWidth - initPriceText.width;

      }

      var lineDyPriceReact = Rect.fromLTRB(left, top, right, bottom);
      canvas.drawRect(lineDyPriceReact, _linePaint);
      initPriceText.paint(canvas, Offset(left, top));
    }
  }



  @override
  void paint(Canvas canvas, Size size) {
    var nowTime;
    /// 如果是分钟图，则分别是 时间，
    /// 当前分钟开盘价格，
    /// 当前分钟收盘价格，
    /// 当前分钟最高价格，
    /// 当前分钟最低价格，
    /// 55.19 ==> initPrice

    var kLineDistance = canvasModel.kLineWidth + canvasModel.kLineMargin;
    double initPrice = (canvasModel.dayMaxPrice+canvasModel.dayMinPrice)/2;

    TextPaint = new Paint()
    ..color = Colors.black
      ..style=PaintingStyle.stroke
    ..strokeWidth =1.0;

    _mPaint = new Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill //填充
      ..color = Colors.blueAccent; //背景为纸黄色
    var canvasWidth = size.width;
    var canvasHeight = size.height;
    double lineDyPrice;  //横线指的价格
    double lineDy;
    double lineDx;

    Rect rect2 = Rect.fromLTRB(0,0,canvasWidth,canvasHeight);
    canvas.drawRect(rect2, TextPaint);


    _linePaint = new Paint();

    /// 生成纵轴文字的TextPainter
    TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    TextPainter _newVerticalAxisTextPainter(String text) {
      return textPainter
        ..text = TextSpan(
          text: text,
          style: new TextStyle(
            color: Colors.black,
            fontSize: 13.0,
          ),
        );
    }

    TextPainter _priceVerticalAxisTextPainter(String text) {
      return textPainter
        ..text = TextSpan(
          text: text,
          style: new TextStyle(
            color: Colors.white,
            fontSize: 13.0,
          ),
        );
    }

    _EqualLinePaint = new Paint()
      ..color = Colors.black12
      ..style=PaintingStyle.stroke
      ..strokeWidth =1.0;

    var _EqualWidth = canvasWidth;
    var _EqualHeight = canvasHeight;
    canvas.drawLine(new Offset(_EqualWidth/4, 0),
        new Offset(_EqualWidth/4, canvasHeight), _EqualLinePaint);
    canvas.drawLine(new Offset(_EqualWidth/4*2, 0),
        new Offset(_EqualWidth/4*2, canvasHeight), _EqualLinePaint);
    canvas.drawLine(new Offset(_EqualWidth/4*3, 0),
        new Offset(_EqualWidth/4*3, canvasHeight), _EqualLinePaint);

    canvas.drawLine(new Offset(0, _EqualHeight/4),
        new Offset(canvasWidth, _EqualHeight/4), _EqualLinePaint);
    canvas.drawLine(new Offset(0, _EqualHeight/4*2),
        new Offset(canvasWidth, _EqualHeight/4*2), _EqualLinePaint);
    canvas.drawLine(new Offset(0, _EqualHeight/4*3),
        new Offset(canvasWidth, _EqualHeight/4*3), _EqualLinePaint);




    _linePaint..strokeWidth =1.3;
    canvasModel.showKLineData.asMap().forEach((i, line) {
//      var time = line.kLineDate;
//      var now = DateTime.parse(time);
      double startPrice = line.startPrice;
      double endPrice = line.endPrice;
      double maxPrice = line.maxPrice;
      double minPrice = line.minPrice;

      var top;
      var bottom;
      var left = kLineDistance*i+canvasModel.kLineMargin;
      var right = kLineDistance*i+kLineDistance;

      top = canvasHeight/2-(startPrice-initPrice)/(canvasModel.dayMaxPrice-initPrice) * canvasHeight/2;
      bottom = canvasHeight/2-((endPrice-initPrice)/(canvasModel.dayMaxPrice-initPrice) * canvasHeight/2);
      if(endPrice>startPrice){
        _linePaint..color = Colors.red;
      }else{
        _linePaint..color = Colors.green;
      }

      Rect kLineReact;
      if (top == bottom) {
        /// 如果开始价格等于结束价格，显示的是一条横线
        kLineReact = Rect.fromLTRB(left, top + 1, right, bottom - 1);
      } else {
        kLineReact = Rect.fromLTRB(left, top, right, bottom);
      }
      kLineOffsets.add([left,right,line]);

      canvas.drawRect(kLineReact, _linePaint);

      var maxTop = canvasHeight / 2 -
          ((maxPrice - initPrice) / (canvasModel.dayMaxPrice - initPrice) * canvasHeight /
              2);
      var minBottom = canvasHeight / 2 -
          ((minPrice - initPrice) / (canvasModel.dayMaxPrice - initPrice) * canvasHeight /
              2);

      canvas.drawLine(
          new Offset((left + right) / 2, maxTop),
          new Offset((left + right) / 2, minBottom),
          _linePaint);
    });

//    var initPriceText = _newVerticalAxisTextPainter(initPrice.toStringAsFixed(2))..layout();
//    initPriceText.paint(canvas, Offset(0, canvasHeight/2- initPriceText.height / 2));
//
//    var dayMinPriceText = _newVerticalAxisTextPainter(canvasModel.dayMinPrice.toStringAsFixed(2))..layout();
//    dayMinPriceText.paint(canvas, Offset(0, canvasHeight-dayMinPriceText.height));
//
//    var dayMaxPriceText = _newVerticalAxisTextPainter(canvasModel.dayMaxPrice.toStringAsFixed(2))..layout();
//    dayMaxPriceText.paint(canvas, Offset(0, 0));

    /// 20均线
    if(canvasModel.day20Data.isNotEmpty){
      TextPaint.color = Colors.cyanAccent;
      int kLineDataLength = canvasModel.showKLineData.length;
      final day20 = getAverageLineData(canvasModel.day20Data,20,canvasHeight,kLineDataLength);
      final up = getUPPointList(canvasModel.day20Data,20,canvasHeight,kLineDataLength);
      final dn = getDNPointList(canvasModel.day20Data,20,canvasHeight,kLineDataLength);
      _drawSmoothLine(canvas,TextPaint,day20);

      TextPaint.color = Colors.redAccent;
      _drawSmoothLine(canvas,TextPaint,up);


      TextPaint.color = Colors.brown;
      _drawSmoothLine(canvas,TextPaint,dn);













    }







    /// 点击后画的十字
    if(canvasModel.onTapDownDtails!=null && canvasModel.isShowCross){
      _linePaint..strokeWidth = lineWidth;
      _linePaint..color = Colors.blueAccent;

      /// 修正dy 上下边界
      if(canvasModel.onTapDownDtails.dy<0){
        lineDy = 0.0;
      }else if(canvasModel.onTapDownDtails.dy>canvasHeight){
        lineDy = canvasHeight;
      }else{
        lineDy = canvasModel.onTapDownDtails.dy;
      }



      /// 横线
//      canvas.drawLine(
//          new Offset(0, lineDy),
//          new Offset(canvasWidth,lineDy), _linePaint);

      /// 修正dx 为每个klin 的中心
      var kLineLength = kLineOffsets.length;
      var i = 0;
      for(;i<kLineLength;i++){
        var dx = kLineOffsets[i][0];
        lineDx = dx+canvasModel.kLineWidth/2;

        if(dx>canvasModel.onTapDownDtails.dx){
          /// 竖线
          canvas.drawLine(
              new Offset(lineDx, 0),
              new Offset(lineDx,canvasHeight ), _linePaint);

          var data = kLineOffsets[i][2];

          Code.eventBus.fire(KLineDataInEvent(data));

//          lineDyPrice = (canvasModel.dayMaxPrice-canvasModel.dayMinPrice)*((canvasHeight-lineDy)/canvasHeight)+canvasModel.dayMinPrice;
//          var initPriceText = _priceVerticalAxisTextPainter(lineDyPrice.toStringAsFixed(2))..layout();
//          drawPrice(canvas,lineDyPrice,initPriceText,lineDx,lineDy,canvasWidth,canvasHeight);
          return;
        }
        else if(canvasModel.onTapDownDtails.dx>kLineOffsets[kLineLength-1][0]){
          /// 最后的一个线
          lineDx = kLineOffsets[kLineLength-1][0]+canvasModel.kLineWidth/2;
          /// 竖线
          canvas.drawLine(
              new Offset(lineDx, 0),
              new Offset(lineDx,canvasHeight ), _linePaint);

//          lineDyPrice = (canvasModel.dayMaxPrice-canvasModel.dayMinPrice)*((canvasHeight-lineDy)/canvasHeight)+canvasModel.dayMinPrice;
//          var initPriceText = _priceVerticalAxisTextPainter(lineDyPrice.toStringAsFixed(2))..layout();
//          drawPrice(canvas,lineDyPrice,initPriceText,lineDx,lineDy,canvasWidth,canvasHeight);
          return ;
        }
      }
    }

    ///绘制逻辑与Android差不多
//    canvas.save();
//    // 将坐标点移动到View的中心
//    canvas.restore();

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}