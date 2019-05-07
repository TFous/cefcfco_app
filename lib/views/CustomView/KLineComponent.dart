import 'dart:ui';

import 'package:cefcfco_app/common/net/Code.dart';
import 'package:cefcfco_app/common/utils/KLineDataInEvent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';

///自定义  饼状图
/// @author yinl
class KLineComponent extends StatelessWidget{
  //数据源
  List datas;
  double initPrice;
  double kLineWidth;
  Offset onTapDownDtails;
  double kLineMargin;
  bool isShowCross;

  KLineComponent(this.datas,this.initPrice,this.kLineWidth,this.kLineMargin,this.onTapDownDtails,this.isShowCross);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      child: CustomPaint(
          painter: MyView(datas,initPrice,kLineWidth,kLineMargin,onTapDownDtails,isShowCross)
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
  List mData;
  bool isShowCross;
  double initPrice;
  double kLineWidth;
  double kLineMargin;
  List kLineOffsets = []; /// k线位置[[dx,dy]]
  double lineWidth = 1.4;/// 线的宽度  譬如十字坐标
  Offset onTapDownDtails;

  var startAngles=[];

  MyView(this.mData,this.initPrice,this.kLineWidth,this.kLineMargin,this.onTapDownDtails,this.isShowCross);


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

    var kLineDistance = kLineWidth + kLineMargin;
    double dayMaxPrice = initPrice*1.1;
    double dayMinPrice = initPrice*0.9;

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

    TextPainter newVerticalAxisTextPainter(String text) {
      return textPainter
        ..text = TextSpan(
          text: text,
          style: new TextStyle(
            color: Colors.black,
            fontSize: 13.0,
          ),
        );
    }

    TextPainter priceVerticalAxisTextPainter(String text) {
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
    mData.asMap().forEach((i, line) {
//      var time = line.kLineDate;
//      var now = DateTime.parse(time);
      double startPrice = line.startPrice;
      double endPrice = line.endPrice;
      double maxPrice = line.maxPrice;
      double minPrice = line.minPrice;

      var top;
      var bottom;
      var left = kLineDistance*i+kLineMargin;
      var right = kLineDistance*i+kLineDistance;

      top = canvasHeight/2-(startPrice-initPrice)/(dayMaxPrice-initPrice) * canvasHeight/2;
      bottom = canvasHeight/2-((endPrice-initPrice)/(dayMaxPrice-initPrice) * canvasHeight/2);
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
          ((maxPrice - initPrice) / (dayMaxPrice - initPrice) * canvasHeight /
              2);
      var minBottom = canvasHeight / 2 -
          ((minPrice - initPrice) / (dayMaxPrice - initPrice) * canvasHeight /
              2);

      canvas.drawLine(
          new Offset((left + right) / 2, maxTop),
          new Offset((left + right) / 2, minBottom),
          _linePaint);
    });

    var initPriceText = newVerticalAxisTextPainter(initPrice.toStringAsFixed(2))..layout();
    initPriceText.paint(canvas, Offset(0, canvasHeight/2- initPriceText.height / 2));

    var dayMinPriceText = newVerticalAxisTextPainter(dayMinPrice.toStringAsFixed(2))..layout();
    dayMinPriceText.paint(canvas, Offset(0, canvasHeight-dayMinPriceText.height));

    var dayMaxPriceText = newVerticalAxisTextPainter(dayMaxPrice.toStringAsFixed(2))..layout();
    dayMaxPriceText.paint(canvas, Offset(0, 0));

    /// 点击后画的十字
    if(onTapDownDtails!=null && isShowCross){
      _linePaint..strokeWidth = lineWidth;
      _linePaint..color = Colors.blueAccent;

      /// 修正dy 上下边界
      if(onTapDownDtails.dy<0){
        lineDy = 0.0;
      }else if(onTapDownDtails.dy>canvasHeight){
        lineDy = canvasHeight;
      }else{
        lineDy = onTapDownDtails.dy;
      }



      /// 竖线
      canvas.drawLine(
          new Offset(0, lineDy),
          new Offset(canvasWidth,lineDy), _linePaint);

      /// 修正dx 为每个klin 的中心
      var kLineLength = kLineOffsets.length;
      var i = 0;
      for(;i<kLineLength;i++){
        var dx = kLineOffsets[i][0];
        lineDx = dx+kLineWidth/2;

        if(dx>onTapDownDtails.dx){
          /// 横线
          canvas.drawLine(
              new Offset(lineDx, 0),
              new Offset(lineDx,canvasHeight ), _linePaint);

          var data = kLineOffsets[i][2];

          Code.eventBus.fire(KLineDataInEvent(data));

          lineDyPrice = (dayMaxPrice-dayMinPrice)*((canvasHeight-lineDy)/canvasHeight)+dayMinPrice;
          var initPriceText = priceVerticalAxisTextPainter(lineDyPrice.toStringAsFixed(2))..layout();
          drawPrice(canvas,lineDyPrice,initPriceText,lineDx,lineDy,canvasWidth,canvasHeight);
          return;
        }
        else if(onTapDownDtails.dx>kLineOffsets[kLineLength-1][0]){
          /// 最后的一个线
          lineDx = kLineOffsets[kLineLength-1][0]+kLineWidth/2;
          /// 横线
          canvas.drawLine(
              new Offset(lineDx, 0),
              new Offset(lineDx,canvasHeight ), _linePaint);

          lineDyPrice = (dayMaxPrice-dayMinPrice)*((canvasHeight-lineDy)/canvasHeight)+dayMinPrice;
          var initPriceText = priceVerticalAxisTextPainter(lineDyPrice.toStringAsFixed(2))..layout();
          drawPrice(canvas,lineDyPrice,initPriceText,lineDx,lineDy,canvasWidth,canvasHeight);
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