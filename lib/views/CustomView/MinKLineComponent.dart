import 'dart:ui';
import 'package:cefcfco_app/common/config/KLineConfig.dart';
import 'package:cefcfco_app/common/model/BollListModel.dart';
import 'package:cefcfco_app/common/model/CanvasModel.dart';
import 'package:cefcfco_app/common/model/KLineModel.dart';
import 'package:cefcfco_app/common/model/MinCanvasModel.dart';
import 'package:cefcfco_app/common/net/Code.dart';
import 'package:cefcfco_app/common/utils/KLineDataInEvent.dart';
import 'package:cefcfco_app/common/utils/KLineUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';


/// @author xiaolei.teng
class MinKLineComponent extends StatelessWidget{
  MinCanvasModel canvasModel;
  MinKLineComponent(this.canvasModel);

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
  Paint crossPricePaint;
  Paint TextPaint;
  double initPrice;
  List kLineOffsets = []; /// k线位置[[dx,dy]]
  double lineWidth = KLineConfig.CROSS_LINE_WIDTH;/// 线的宽度  譬如十字坐标
  MinCanvasModel canvasModel;

  KLineModel maxItem; //当前最大的一个kline 信息 ，便于 标注当前屏幕最高价和最低价
  KLineModel minItem;

  MyView(this.canvasModel);

  @override
  void paint(Canvas canvas, Size size) {
    double maxPrice = canvasModel.initPrice*1.11;
    double minPrice = canvasModel.initPrice*0.89;

//    double maxPrice = 13.13;
//    double minPrice = 12.07;

    TextPaint = new Paint()
    ..color = KLineConfig.WRAP_BORDER_COLOR
      ..style=PaintingStyle.stroke
    ..strokeWidth =1.0;

    int minLength = 241;// 全天的开盘分钟数 开始的930 和结束的3.00

    double canvasWidth = size.width;
    double canvasHeight = size.height;

    double minWidth = canvasWidth/minLength;
    double lineDyPrice;  //横线指的价格
    double lineDy;
    double lineDx;

    Rect rect2 = Rect.fromLTRB(0,0,canvasWidth,canvasHeight);
    canvas.drawRect(rect2, TextPaint);

    _linePaint = new Paint();
    _linePaint..strokeWidth =1.3;

    // 区域等分线三横三竖
    drawDashLine(canvas,new Offset(canvasWidth/4, 0),
        new Offset(canvasWidth/4, canvasHeight));
    drawDashLine(canvas,new Offset(canvasWidth/4*2, 0),
        new Offset(canvasWidth/4*2, canvasHeight));
    drawDashLine(canvas,new Offset(canvasWidth/4*3, 0),
        new Offset(canvasWidth/4*3, canvasHeight));


    drawDashLine(canvas,new Offset(0, canvasHeight/4),
        new Offset(canvasWidth, canvasHeight/4));
    drawDashLine(canvas,new Offset(0, canvasHeight/4*2),
        new Offset(canvasWidth, canvasHeight/4*2));
    drawDashLine(canvas,new Offset(0, canvasHeight/4*3),
        new Offset(canvasWidth, canvasHeight/4*3));

    // 区域等分线三横三竖 --end

    TextPaint.color = KLineConfig.BOLL_MA_COLOR;
    List<Point> maPointList= [];
    canvasModel.minLineData.asMap().forEach((i, line) {
      double startDy;
      double endDy;
      if(i==0){
        // 第一个点是
      }else if(i== minLength-1){
        startDy = priceToPositionDy(canvasModel.minLineData[i-1].price,canvasHeight,maxPrice,minPrice);
        endDy = priceToPositionDy(line.price,canvasHeight,maxPrice,minPrice);
        canvas.drawLine(
            new Offset(minWidth*(i-1), startDy),
            new Offset(canvasWidth, endDy),
            _linePaint);
      }else{
        startDy = priceToPositionDy(canvasModel.minLineData[i-1].price,canvasHeight,maxPrice,minPrice);
        endDy = priceToPositionDy(line.price,canvasHeight,maxPrice,minPrice);
        canvas.drawLine(
            new Offset(minWidth*(i-1), startDy),
            new Offset(minWidth*i, endDy),
            _linePaint);
      }

      // 均线
      double maPrice = getMinMA(canvasModel.minLineData.sublist(0,i+1));
      var dy = priceToPositionDy(maPrice.isNaN?0:maPrice,canvasHeight,maxPrice,minPrice);
      var dx = minWidth*i;
      maPointList.add(Point(dx, dy));

      kLineOffsets.add([dx,line]);

    });

//    kLineOffsets.add([canvasWidth,canvasModel.minLineData.last]);

//    maPointList.add(Point(canvasWidth, maPointList.last.y));
    drawSmoothLine(canvas,TextPaint,maPointList);


    // 标注五段等分价格
    var initPriceText = newVerticalAxisTextPainter(canvasModel.initPrice.toStringAsFixed(2))..layout();
    initPriceText.paint(canvas, Offset(KLineConfig.EQUAL_PRICE_MARGIN, canvasHeight/2- initPriceText.height / 2));

    var dayMinPriceText = newVerticalAxisTextPainter(minPrice.toStringAsFixed(2))..layout();
    dayMinPriceText.paint(canvas, Offset(KLineConfig.EQUAL_PRICE_MARGIN, canvasHeight-dayMinPriceText.height));

    var dayMaxPriceText = newVerticalAxisTextPainter(maxPrice.toStringAsFixed(2))..layout();
    dayMaxPriceText.paint(canvas, Offset(KLineConfig.EQUAL_PRICE_MARGIN, 0));



    /// 点击后画的十字
    if(canvasModel.onTapDownDtails!=null && canvasModel.isShowCross){
      _linePaint..strokeWidth = lineWidth;
      _linePaint..color = KLineConfig.CROSS_LINE_COLOR;


      crossPricePaint = new Paint();
      crossPricePaint..strokeWidth =lineWidth;
      crossPricePaint..color =KLineConfig.CROSS_TEXT_BG_COLOR;

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
        lineDx = dx+minWidth/2;

        if(dx>canvasModel.onTapDownDtails.dx){
          /// 竖线
          canvas.drawLine(
              new Offset(lineDx, 0),
              new Offset(lineDx,canvasHeight ), _linePaint);

//          var data = kLineOffsets[i][1];
//          Code.eventBus.fire(KLineDataInEvent(data));

          lineDyPrice = (maxPrice-minPrice)*((canvasHeight-lineDy)/canvasHeight)+minPrice;
          var initPriceText = priceVerticalAxisTextPainter(lineDyPrice.toStringAsFixed(2))..layout();

          drawPrice(canvas,lineDyPrice,initPriceText,lineDx,lineDy,canvasWidth,canvasHeight,crossPricePaint);
          return;
        }
        else if(canvasModel.onTapDownDtails.dx>kLineOffsets.last[0]){
          /// 最后的一个线
          lineDx = kLineOffsets.last[0]-minWidth/2;
          /// 竖线
          canvas.drawLine(
              new Offset(lineDx, 0),
              new Offset(lineDx,canvasHeight ), _linePaint);

          lineDyPrice = (maxPrice-minPrice)*((canvasHeight-lineDy)/canvasHeight)+minPrice;
          var initPriceText = priceVerticalAxisTextPainter(lineDyPrice.toStringAsFixed(2))..layout();
          drawPrice(canvas,lineDyPrice,initPriceText,lineDx,lineDy,canvasWidth,canvasHeight,crossPricePaint);
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