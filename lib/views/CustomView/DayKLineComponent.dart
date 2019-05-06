import 'dart:ui';

import 'package:cefcfco_app/common/model/BollListModel.dart';
import 'package:cefcfco_app/common/model/BollPositonsModel.dart';
import 'package:cefcfco_app/common/model/KLineModel.dart';
import 'package:cefcfco_app/common/net/Code.dart';
import 'package:cefcfco_app/common/utils/KLineDataInEvent.dart';
import 'package:cefcfco_app/common/utils/KLineUtils.dart';
import 'package:cefcfco_app/common/utils/monotonex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';

///自定义  饼状图
/// @author yinl
class DayKLineComponent extends StatelessWidget{
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

  DayKLineComponent(this.canvasModel);

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

  KLineModel maxItem;
  KLineModel minItem;

  MyView(this.canvasModel);

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
    double initPrice = (canvasModel.kLineListInfo.maxPrice+canvasModel.kLineListInfo.minPrice)/2;

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
      if(i==canvasModel.kLineListInfo.maxIndex){
        maxItem = line;
      }else if(i==canvasModel.kLineListInfo.minIndex){
        minItem = line;
      }

      double startPrice = line.startPrice;
      double endPrice = line.endPrice;
      double maxPrice = line.maxPrice;
      double minPrice = line.minPrice;


      var left = kLineDistance*i+canvasModel.kLineMargin;
      var right = kLineDistance*i+kLineDistance;

      var top = priceToPositionDy(startPrice,canvasHeight,canvasModel.kLineListInfo.maxPrice,canvasModel.kLineListInfo.minPrice);
      var bottom = priceToPositionDy(endPrice,canvasHeight,canvasModel.kLineListInfo.maxPrice,canvasModel.kLineListInfo.minPrice);

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

      var maxTop = priceToPositionDy(maxPrice,canvasHeight,canvasModel.kLineListInfo.maxPrice,canvasModel.kLineListInfo.minPrice);
      var minBottom = priceToPositionDy(minPrice,canvasHeight,canvasModel.kLineListInfo.maxPrice,canvasModel.kLineListInfo.minPrice);

      canvas.drawLine(
          new Offset((left + right) / 2, maxTop),
          new Offset((left + right) / 2, minBottom),
          _linePaint);
    });

    // 标注当前屏幕最高价和最低价
    _linePaint.color = Colors.deepPurple;
    var top = priceToPositionDy(maxItem.maxPrice,canvasHeight,canvasModel.kLineListInfo.maxPrice,canvasModel.kLineListInfo.minPrice);
    var bottom = priceToPositionDy(minItem.minPrice,canvasHeight,canvasModel.kLineListInfo.maxPrice,canvasModel.kLineListInfo.minPrice);
    drawArrow(canvas, _linePaint, new Offset(kLineDistance*canvasModel.kLineListInfo.maxIndex-20,top),new Offset(kLineDistance*canvasModel.kLineListInfo.maxIndex,top));
    drawArrow(canvas, _linePaint, new Offset(kLineDistance*canvasModel.kLineListInfo.minIndex-20,bottom),new Offset(kLineDistance*canvasModel.kLineListInfo.minIndex,bottom));
   // 标注当前屏幕最高价和最低价 ---end


    // 标注五段等分价格
    var initPriceText = _newVerticalAxisTextPainter(initPrice.toStringAsFixed(2))..layout();
    initPriceText.paint(canvas, Offset(0, canvasHeight/2- initPriceText.height / 2));

    var dayMinPriceText = _newVerticalAxisTextPainter(canvasModel.kLineListInfo.minPrice.toStringAsFixed(2))..layout();
    dayMinPriceText.paint(canvas, Offset(0, canvasHeight-dayMinPriceText.height));

    var dayMaxPriceText = _newVerticalAxisTextPainter(canvasModel.kLineListInfo.maxPrice.toStringAsFixed(2))..layout();
    dayMaxPriceText.paint(canvas, Offset(0, 0));

    double price1 = (canvasModel.kLineListInfo.maxPrice+initPrice)/2;
    var priceText1 = _newVerticalAxisTextPainter(price1.toStringAsFixed(2))..layout();
    priceText1.paint(canvas, Offset(0, _EqualHeight/4-priceText1.height/2));

    double price2 = (canvasModel.kLineListInfo.minPrice+initPrice)/2;
    var priceText2 = _newVerticalAxisTextPainter(price2.toStringAsFixed(2))..layout();
    priceText2.paint(canvas, Offset(0, _EqualHeight/4*3-priceText2.height/2));
    // 标注五段等分价格 ---end

    /// 五日均线
    if(canvasModel.day5Data.isNotEmpty){
      TextPaint.color = Colors.deepOrange;
      BollPositonsModel boll5Data = bollDataToPosition(canvasModel.allKLineData,canvasModel.day5Data,5,canvasModel.showKLineData,canvasHeight,canvasModel);
      drawSmoothLine(canvas,TextPaint,boll5Data.maPointList);
    }

    /// 十日均线
    if(canvasModel.day10Data.isNotEmpty){
      TextPaint.color = Colors.pinkAccent;
      BollPositonsModel day10 = bollDataToPosition(canvasModel.allKLineData,canvasModel.day10Data,10,canvasModel.showKLineData,canvasHeight,canvasModel);
      drawSmoothLine(canvas,TextPaint,day10.maPointList);
    }

    /// 15均线
    if(canvasModel.day15Data.isNotEmpty){
      TextPaint.color = Colors.brown;
      BollPositonsModel data = bollDataToPosition(canvasModel.allKLineData,canvasModel.day15Data,15,canvasModel.showKLineData,canvasHeight,canvasModel);
      drawSmoothLine(canvas,TextPaint,data.maPointList);
    }

    /// 20均线
    if(canvasModel.day20Data.isNotEmpty){
      TextPaint.color = Colors.cyanAccent;
      BollPositonsModel data = bollDataToPosition(canvasModel.allKLineData,canvasModel.day20Data,20,canvasModel.showKLineData,canvasHeight,canvasModel);
      drawSmoothLine(canvas,TextPaint,data.maPointList);
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
      canvas.drawLine(
          new Offset(0, lineDy),
          new Offset(canvasWidth,lineDy), _linePaint);

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

          lineDyPrice = (canvasModel.kLineListInfo.maxPrice-canvasModel.kLineListInfo.minPrice)*((canvasHeight-lineDy)/canvasHeight)+canvasModel.kLineListInfo.minPrice;
          var initPriceText = _priceVerticalAxisTextPainter(lineDyPrice.toStringAsFixed(2))..layout();
          drawPrice(canvas,lineDyPrice,initPriceText,lineDx,lineDy,canvasWidth,canvasHeight,_linePaint);
          return;
        }
        else if(canvasModel.onTapDownDtails.dx>kLineOffsets[kLineLength-1][0]){
          /// 最后的一个线
          lineDx = kLineOffsets[kLineLength-1][0]+canvasModel.kLineWidth/2;
          /// 竖线
          canvas.drawLine(
              new Offset(lineDx, 0),
              new Offset(lineDx,canvasHeight ), _linePaint);

          lineDyPrice = (canvasModel.kLineListInfo.maxPrice-canvasModel.kLineListInfo.minPrice)*((canvasHeight-lineDy)/canvasHeight)+canvasModel.kLineListInfo.minPrice;
          var initPriceText = _priceVerticalAxisTextPainter(lineDyPrice.toStringAsFixed(2))..layout();
          drawPrice(canvas,lineDyPrice,initPriceText,lineDx,lineDy,canvasWidth,canvasHeight,_linePaint);
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