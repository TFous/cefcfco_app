import 'dart:ui';
import 'package:cefcfco_app/common/config/KLineConfig.dart';
import 'package:cefcfco_app/common/model/BollListModel.dart';
import 'package:cefcfco_app/common/model/CanvasModel.dart';
import 'package:cefcfco_app/common/model/KLineModel.dart';
import 'package:cefcfco_app/common/net/Code.dart';
import 'package:cefcfco_app/common/utils/KLineDataInEvent.dart';
import 'package:cefcfco_app/common/utils/KLineUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';


/// @author xiaolei.teng
class DayKLineComponent extends StatelessWidget{
  CanvasModel canvasModel;
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
  Paint _linePaint;
  Paint crossPricePaint;
  Paint TextPaint;
  double initPrice;
  List kLineOffsets = []; /// k线位置[[dx,dy]]
  double lineWidth = KLineConfig.CROSS_LINE_WIDTH;/// 线的宽度  譬如十字坐标
  CanvasModel canvasModel;

  KLineModel maxItem; //当前最大的一个kline 信息 ，便于 标注当前屏幕最高价和最低价
  KLineModel minItem;

  MyView(this.canvasModel);

  @override
  void paint(Canvas canvas, Size size) {
    double kLineDistance = canvasModel.kLineWidth + canvasModel.kLineMargin;
    double initPrice = (canvasModel.kLineListInfo.maxPrice+canvasModel.kLineListInfo.minPrice)/2;

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


      double left = kLineDistance*i+canvasModel.kLineMargin;
      double right = kLineDistance*i+kLineDistance;

      double top = priceToPositionDy(startPrice,canvasHeight,canvasModel.kLineListInfo.maxPrice,canvasModel.kLineListInfo.minPrice);
      double bottom = priceToPositionDy(endPrice,canvasHeight,canvasModel.kLineListInfo.maxPrice,canvasModel.kLineListInfo.minPrice);

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

      double maxTop = priceToPositionDy(maxPrice,canvasHeight,canvasModel.kLineListInfo.maxPrice,canvasModel.kLineListInfo.minPrice);
      double minBottom = priceToPositionDy(minPrice,canvasHeight,canvasModel.kLineListInfo.maxPrice,canvasModel.kLineListInfo.minPrice);

      canvas.drawLine(
          new Offset((left + right) / 2, maxTop),
          new Offset((left + right) / 2, minBottom),
          _linePaint);


      // 标注每个线的序号
//      var iText = priceTextPainter(i.toStringAsFixed(0))..layout();
//      iText.paint(canvas, Offset(left, maxTop));
      // 标注每个线的序号 ---end

    });


    // 标注五段等分价格
    var initPriceText = newVerticalAxisTextPainter(initPrice.toStringAsFixed(2))..layout();
    initPriceText.paint(canvas, Offset(KLineConfig.EQUAL_PRICE_MARGIN, canvasHeight/2- initPriceText.height / 2));

    var dayMinPriceText = newVerticalAxisTextPainter(canvasModel.kLineListInfo.minPrice.toStringAsFixed(2))..layout();
    dayMinPriceText.paint(canvas, Offset(KLineConfig.EQUAL_PRICE_MARGIN, canvasHeight-dayMinPriceText.height));

    var dayMaxPriceText = newVerticalAxisTextPainter(canvasModel.kLineListInfo.maxPrice.toStringAsFixed(2))..layout();
    dayMaxPriceText.paint(canvas, Offset(KLineConfig.EQUAL_PRICE_MARGIN, 0));

    double price1 = (canvasModel.kLineListInfo.maxPrice+initPrice)/2;
    var priceText1 = newVerticalAxisTextPainter(price1.toStringAsFixed(2))..layout();
    priceText1.paint(canvas, Offset(KLineConfig.EQUAL_PRICE_MARGIN, canvasHeight/4-priceText1.height/2));

    double price2 = (canvasModel.kLineListInfo.minPrice+initPrice)/2;
    var priceText2 = newVerticalAxisTextPainter(price2.toStringAsFixed(2))..layout();
    priceText2.paint(canvas, Offset(KLineConfig.EQUAL_PRICE_MARGIN, canvasHeight/4*3-priceText2.height/2));
    // 标注五段等分价格 ---end
    List<Point> ma5PointList = [];
    List<Point> ma10PointList = [];
    /// 五日均线
    if(canvasModel.day5Data.isNotEmpty){
      TextPaint.color = KLineConfig.MA5_COLOR;
      BollListModel bollList = getBollDataList(canvasModel.allKLineData,canvasModel.day5Data, 5,canvasModel.showKLineData);
      bollList.list.forEach((item){
        double dx = getDx(canvasModel, item.positionIndex);
        double maDy = priceToPositionDy(item.ma, canvasHeight, canvasModel.kLineListInfo.maxPrice,canvasModel.kLineListInfo.minPrice);
        ma5PointList.add(new Point(dx, maDy));
      });
      drawSmoothLine(canvas,TextPaint,ma5PointList);
    }

    /// 十日均线
    if(canvasModel.day10Data.isNotEmpty){
      TextPaint.color = KLineConfig.MA10_COLOR;
      BollListModel bollList = getBollDataList(canvasModel.allKLineData,canvasModel.day10Data,10,canvasModel.showKLineData);
      bollList.list.forEach((item){
        double dx = getDx(canvasModel, item.positionIndex);
        double maDy = priceToPositionDy(item.ma, canvasHeight, canvasModel.kLineListInfo.maxPrice,canvasModel.kLineListInfo.minPrice);
        ma10PointList.add(new Point(dx, maDy));
      });
      drawSmoothLine(canvas,TextPaint,ma10PointList);
    }

    ma5PointList.forEach((Point ma5){
      ma10PointList.forEach((Point ma10){
          if(ma5.x==ma10.x && ma5.y>ma10.y){
            _linePaint.color=KLineConfig.BLOCK_A_COLOR;
            canvas.drawLine(
                new Offset(ma5.x,ma5.y),
                new Offset(ma10.x,ma10.y),
                _linePaint);
          }

          if(ma5.x==ma10.x && ma5.y<ma10.y){
            _linePaint.color=KLineConfig.BLOCK_B_COLOR;
            canvas.drawLine(
                new Offset(ma5.x,ma5.y),
                new Offset(ma10.x,ma10.y),
                _linePaint);
          }
      });
    });



    /// 15均线
    if(canvasModel.day15Data.isNotEmpty){
      TextPaint.color = KLineConfig.MA15_COLOR;
      List<Point> maPointList = [];
      BollListModel bollList = getBollDataList(canvasModel.allKLineData,canvasModel.day15Data,15,canvasModel.showKLineData);
      bollList.list.forEach((item){
        double dx = getDx(canvasModel, item.positionIndex);
        double maDy = priceToPositionDy(item.ma, canvasHeight, canvasModel.kLineListInfo.maxPrice,canvasModel.kLineListInfo.minPrice);
        maPointList.add(new Point(dx, maDy));
      });
      drawSmoothLine(canvas,TextPaint,maPointList);

    }

    /// 20均线
    if(canvasModel.day20Data.isNotEmpty){
      TextPaint.color = KLineConfig.MA20_COLOR;
      List<Point> maPointList = [];
      BollListModel bollList = getBollDataList(canvasModel.allKLineData,canvasModel.day20Data,20,canvasModel.showKLineData);
      bollList.list.forEach((item){
        double dx = getDx(canvasModel, item.positionIndex);
        double maDy = priceToPositionDy(item.ma, canvasHeight, canvasModel.kLineListInfo.maxPrice,canvasModel.kLineListInfo.minPrice);
        maPointList.add(new Point(dx, maDy));
      });
      drawSmoothLine(canvas,TextPaint,maPointList);
    }


    // 标注当前屏幕最高价和最低价
    int kLineLength = canvasModel.showKLineData.length;
    _linePaint.color = KLineConfig.ARROW_COLOR;
    _linePaint..strokeWidth =0.8;

    var top = priceToPositionDy(maxItem.maxPrice,canvasHeight,canvasModel.kLineListInfo.maxPrice,canvasModel.kLineListInfo.minPrice);
    var bottom = priceToPositionDy(minItem.minPrice,canvasHeight,canvasModel.kLineListInfo.maxPrice,canvasModel.kLineListInfo.minPrice);
    var max = kLineDistance*canvasModel.kLineListInfo.maxIndex;
    var min = kLineDistance*canvasModel.kLineListInfo.minIndex;

    var maxPriceText = priceTextPainter(maxItem.maxPrice.toStringAsFixed(2))
      ..layout();
    if(canvasModel.kLineListInfo.maxIndex > kLineLength/2){
      drawArrow(canvas, _linePaint, Offset(max-KLineConfig.ARROW_WIDTH+kLineDistance/2,top),Offset(max+kLineDistance/2,top));
      maxPriceText.paint(canvas, Offset(max-maxPriceText.width-KLineConfig.ARROW_WIDTH+kLineDistance/2,top-maxPriceText.height/2));
    }else{
      drawArrow(canvas, _linePaint, Offset(max+KLineConfig.ARROW_WIDTH+kLineDistance/2,top),Offset(max+kLineDistance/2,top));
      maxPriceText.paint(canvas, Offset(max+KLineConfig.ARROW_WIDTH+kLineDistance/2,top-maxPriceText.height/2));
    }

    var minPriceText = priceTextPainter(minItem.minPrice.toStringAsFixed(2))
      ..layout();
    if(canvasModel.kLineListInfo.minIndex > kLineLength/2){
      drawArrow(canvas, _linePaint, Offset(min-KLineConfig.ARROW_WIDTH+kLineDistance/2,bottom),Offset(min+kLineDistance/2,bottom));
      minPriceText.paint(canvas, Offset(min-minPriceText.width-KLineConfig.ARROW_WIDTH+kLineDistance/2,bottom-minPriceText.height/2));
    }else{
      drawArrow(canvas, _linePaint, Offset(min+KLineConfig.ARROW_WIDTH+kLineDistance/2,bottom),Offset(min+kLineDistance/2,bottom));
      minPriceText.paint(canvas, Offset(min+KLineConfig.ARROW_WIDTH+kLineDistance/2,bottom-minPriceText.height/2));
    }
    // 标注当前屏幕最高价和最低价 ---end

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
        lineDx = dx+canvasModel.kLineWidth/2;

        if(dx>canvasModel.onTapDownDtails.dx){
          /// 竖线
          canvas.drawLine(
              new Offset(lineDx, 0),
              new Offset(lineDx,canvasHeight ), _linePaint);

          var data = kLineOffsets[i][2];

          Code.eventBus.fire(KLineDataInEvent(data));

          lineDyPrice = (canvasModel.kLineListInfo.maxPrice-canvasModel.kLineListInfo.minPrice)*((canvasHeight-lineDy)/canvasHeight)+canvasModel.kLineListInfo.minPrice;
          var initPriceText = priceVerticalAxisTextPainter(lineDyPrice.toStringAsFixed(2))..layout();

          drawPrice(canvas,lineDyPrice,initPriceText,lineDx,lineDy,canvasWidth,canvasHeight,crossPricePaint);
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