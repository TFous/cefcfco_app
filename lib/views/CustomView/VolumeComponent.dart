import 'dart:math';
import 'dart:ui';

import 'package:cefcfco_app/common/config/KLineConfig.dart';
import 'package:cefcfco_app/common/model/BollListModel.dart';
import 'package:cefcfco_app/common/model/CanvasBollModel.dart';
import 'package:cefcfco_app/common/model/CanvasModel.dart';
import 'package:cefcfco_app/common/model/KLineModel.dart';
import 'package:cefcfco_app/common/net/Code.dart';
import 'package:cefcfco_app/common/utils/KLineDataInEvent.dart';
import 'package:cefcfco_app/common/utils/KLineUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// @author xiaolei.teng
class VolumeComponent extends StatelessWidget{
  CanvasModel canvasModel;
  bool isVolume;
  VolumeComponent(this.canvasModel,this.isVolume);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      child: CustomPaint(
          painter: MyView(canvasModel,isVolume)
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
  CanvasModel canvasModel;
  bool isVolume;

  MyView(this.canvasModel,this.isVolume);


  @override
  void paint(Canvas canvas, Size size) {
    double kLineDistance = canvasModel.kLineWidth + canvasModel.kLineMargin;

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

    drawDashLine(canvas,new Offset(0, canvasHeight/4*2),
        new Offset(canvasWidth, canvasHeight/4*2));

    // 区域等分线三横三竖 --end

    double maxVolume = 0.0; // 成交量
    double maxTurnover = 0.0;
    canvasModel.showKLineData.forEach((item){
      if(item.volume>maxVolume){
        maxVolume = item.volume;
      }

      if(item.amount>maxTurnover){
        maxTurnover = item.amount;
      }
    });

    canvasModel.showKLineData.asMap().forEach((i, line) {

      double startPrice = line.open;
      double endPrice = line.close;

      double top;
      double bottom;
      double left = kLineDistance*i+canvasModel.kLineMargin;
      double right = kLineDistance*i+kLineDistance;
      if(isVolume){
        top = priceToPositionDy(line.volume,canvasHeight,maxVolume,0);
        bottom = priceToPositionDy(line.volume,canvasHeight,maxVolume,0);
      }else{
        top = priceToPositionDy(line.amount,canvasHeight,maxTurnover,0);
        bottom = priceToPositionDy(line.amount,canvasHeight,maxTurnover,0);
      }


      if(endPrice>startPrice){
        _linePaint..color = KLineConfig.KLINE_UP_COLOR;
      }else{
        _linePaint..color = KLineConfig.KLINE_DOWN_COLOR;
      }

      Rect kLineReact;
      if (top == bottom) {
        /// 如果开始价格等于结束价格，显示的是一条横线
        kLineReact = Rect.fromLTRB(left, top + 1, right, canvasHeight);
      } else {
        kLineReact = Rect.fromLTRB(left, top, right, canvasHeight);
      }
      kLineOffsets.add([left,right,line]);

      canvas.drawRect(kLineReact, _linePaint);

    });

    // 成交量均线及其信息

    if(!canvasModel.isShowCross){
      var volumeText = volumeTextPainter(isVolume?'成交量':'成交额',KLineConfig.VOLUME_MAX_COLOR)..layout();
      volumeText.paint(canvas, Offset(KLineConfig.EQUAL_PRICE_MARGIN,0.0));
    }
    var volumeMaxNum = volumeTextPainter(isVolume?priceToWan(maxVolume):priceToYi(maxTurnover),KLineConfig.VOLUME_MAX_COLOR)..layout();
    volumeMaxNum.paint(canvas, Offset(canvasWidth-volumeMaxNum.width-KLineConfig.EQUAL_PRICE_MARGIN,0.0));







    List<Point> ma5PointList = [];
    List<Point> ma10PointList = [];
    BollListModel m5;
    BollListModel m10;

    if(isVolume){
      m5 = getBollDataList(canvasModel.allKLineData,canvasModel.day5Data, 5,canvasModel.showKLineData,'volume');
      m10 = getBollDataList(canvasModel.allKLineData,canvasModel.day10Data, 10,canvasModel.showKLineData,'volume');
    }else{
      m5 = getBollDataList(canvasModel.allKLineData,canvasModel.day5Data, 5,canvasModel.showKLineData,'turnover');
      m10 = getBollDataList(canvasModel.allKLineData,canvasModel.day10Data, 10,canvasModel.showKLineData,'turnover');
    }

    /// 五日均线
    if(canvasModel.day5Data.isNotEmpty){
      TextPaint.color = KLineConfig.VOLUME_M5_COLOR;
      m5.list.forEach((item){
        double dx = getDx(canvasModel, item.positionIndex);
        double maDy = priceToPositionDy(item.ma, canvasHeight,isVolume?maxVolume:maxTurnover,0);
        ma5PointList.add(new Point(dx, maDy));
      });
      drawSmoothLine(canvas,TextPaint,ma5PointList);
    }
    /// 十日均线
    if(canvasModel.day10Data.isNotEmpty){
      TextPaint.color = KLineConfig.VOLUME_M10_COLOR;
      m10.list.forEach((item){
        double dx = getDx(canvasModel, item.positionIndex);
        double maDy = priceToPositionDy(item.ma, canvasHeight, isVolume?maxVolume:maxTurnover,0);
        ma10PointList.add(new Point(dx, maDy));
      });
      drawSmoothLine(canvas,TextPaint,ma10PointList);
    }

    // 成交量均线及其信息---end
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


//          Code.eventBus.fire(KLineDataInEvent(data));

          if(canvasModel.isShowCross){
            KLineModel data = kLineOffsets[i][2];
            Color color;
            if(data.close>data.open){
              color = KLineConfig.KLINE_UP_COLOR;
            }else{
              color = KLineConfig.KLINE_DOWN_COLOR;
            }
            var volumeText = volumeTextPainter(isVolume?'量:${priceToWan(data.volume)}':'额:${priceToYi(data.amount)}',color)..layout();
            volumeText.paint(canvas, Offset(KLineConfig.EQUAL_PRICE_MARGIN,0.0));

            var turnoverRate = volumeTextPainter('换手率:${data.turn}',KLineConfig.TURNOVER_RATE_COLOR)..layout();
            turnoverRate.paint(canvas, Offset(canvasWidth/5*3+8,0.0)); // 换手率字太长，加了8像素好看点

            // 均线数据，i就是对应的存放数据index
            var item5 = m5.list[i];
            var m5Text = volumeTextPainter(isVolume?'M5:${priceToWan(item5.ma)}':'M5:${priceToYi(item5.ma)}',KLineConfig.VOLUME_M5_COLOR)..layout();
            m5Text.paint(canvas, Offset(canvasWidth / 5, 0.0));


            var item10 = m10.list[i];
            var m10Text = volumeTextPainter(isVolume?'M10:${priceToWan(item10.ma)}':'M10:${priceToYi(item10.ma)}',KLineConfig.VOLUME_M10_COLOR)..layout();
            m10Text.paint(canvas, Offset(canvasWidth / 5 * 2, 0.0));


          }

          return;
        }
        else if(canvasModel.onTapDownDtails.dx>kLineOffsets[kLineLength-1][0]){
          /// 最后的一个线
          lineDx = kLineOffsets[kLineLength-1][0]+canvasModel.kLineWidth/2;
          /// 竖线
          canvas.drawLine(
              new Offset(lineDx, 0),
              new Offset(lineDx,canvasHeight ), _linePaint);


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