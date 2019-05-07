import 'dart:ui';

import 'package:cefcfco_app/common/config/KLineConfig.dart';
import 'package:cefcfco_app/common/model/CanvasBollModel.dart';
import 'package:cefcfco_app/common/net/Code.dart';
import 'package:cefcfco_app/common/utils/KLineDataInEvent.dart';
import 'package:cefcfco_app/common/utils/KLineUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// @author xiaolei.teng
class FigureComponent extends StatelessWidget{
  CanvasBollModel canvasModel;
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
  Paint _linePaint;
  Paint TextPaint;
  double initPrice;
  List kLineOffsets = []; /// k线位置[[dx,dy]]
  double lineWidth = KLineConfig.CROSS_LINE_WIDTH;/// 线的宽度  譬如十字坐标
  CanvasBollModel canvasModel;

  MyView(this.canvasModel);


  @override
  void paint(Canvas canvas, Size size) {
    double kLineDistance = canvasModel.kLineWidth + canvasModel.kLineMargin;
    double initPrice = (canvasModel.dayMaxPrice+canvasModel.dayMinPrice)/2;

    TextPaint = new Paint()
    ..color = KLineConfig.WRAP_BORDER_COLOR
      ..style=PaintingStyle.stroke
    ..strokeWidth =1.0;

    double canvasWidth = size.width;
    double canvasHeight = size.height;
    double lineDyPrice;  //横线指的价格
    double lineDy;
    double lineDx;
    Rect rect2 = Rect.fromLTRB(0,0,canvasWidth,canvasHeight);
    canvas.drawRect(rect2, TextPaint);

    _linePaint = new Paint();


    // 区域等分线三横三竖

    drawDashLine(canvas,new Offset(0, canvasHeight/4*2),
        new Offset(canvasWidth, canvasHeight/4*2));

    // 区域等分线三横三竖 --end


    _linePaint..strokeWidth =1.3;
    canvasModel.showKLineData.asMap().forEach((i, line) {

      double startPrice = line.startPrice;
      double endPrice = line.endPrice;
      double maxPrice = line.maxPrice;
      double minPrice = line.minPrice;

      double top;
      double bottom;
      double left = kLineDistance*i+canvasModel.kLineMargin;
      double right = kLineDistance*i+kLineDistance;

      top = priceToPositionDy(startPrice,canvasHeight,canvasModel.dayMaxPrice,canvasModel.dayMinPrice);
      bottom = priceToPositionDy(endPrice,canvasHeight,canvasModel.dayMaxPrice,canvasModel.dayMinPrice);

      if(endPrice>startPrice){
        _linePaint..color = KLineConfig.KLINE_UP_COLOR;
      }else{
        _linePaint..color = KLineConfig.KLINE_DOWN_COLOR;
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

      double maxTop = priceToPositionDy(maxPrice,canvasHeight,canvasModel.dayMaxPrice,canvasModel.dayMinPrice);
      double minBottom = priceToPositionDy(minPrice,canvasHeight,canvasModel.dayMaxPrice,canvasModel.dayMinPrice);

      canvas.drawLine(
          new Offset((left + right) / 2, maxTop),
          new Offset((left + right) / 2, minBottom),
          _linePaint);
    });

    var initPriceText = newVerticalAxisTextPainter(initPrice.toStringAsFixed(2))..layout();
    initPriceText.paint(canvas, Offset(KLineConfig.EQUAL_PRICE_MARGIN, canvasHeight/2- initPriceText.height / 2));

    var dayMinPriceText = newVerticalAxisTextPainter(canvasModel.dayMinPrice.toStringAsFixed(2))..layout();
    dayMinPriceText.paint(canvas, Offset(KLineConfig.EQUAL_PRICE_MARGIN, canvasHeight-dayMinPriceText.height));

    var dayMaxPriceText = newVerticalAxisTextPainter(canvasModel.dayMaxPrice.toStringAsFixed(2))..layout();
    dayMaxPriceText.paint(canvas, Offset(KLineConfig.EQUAL_PRICE_MARGIN, 0));

    /// boll 线
    if(canvasModel.maPointList.isNotEmpty){
      TextPaint.color = KLineConfig.BOLL_MA_COLOR;
      drawSmoothLine(canvas,TextPaint,canvasModel.maPointList);

      TextPaint.color = KLineConfig.BOLL_UP_COLOR;
      drawSmoothLine(canvas,TextPaint,canvasModel.upPointList);

      TextPaint.color = KLineConfig.BOLL_DN_COLOR;
      drawSmoothLine(canvas,TextPaint,canvasModel.dnPointList);
    }


    /// 点击后画的十字
    if(canvasModel.onTapDownDtails!=null && canvasModel.isShowCross){
      _linePaint..strokeWidth = lineWidth;
      _linePaint..color = KLineConfig.CROSS_LINE_COLOR;

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
//          var initPriceText = priceVerticalAxisTextPainter(lineDyPrice.toStringAsFixed(2))..layout();
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
//          var initPriceText = priceVerticalAxisTextPainter(lineDyPrice.toStringAsFixed(2))..layout();
//          drawPrice(canvas,lineDyPrice,initPriceText,lineDx,lineDy,canvasWidth,canvasHeight);
          return ;
        }
      }
    }

//    canvas.save();
//    // 将坐标点移动到View的中心
//    canvas.restore();

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}