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
class VolumeComponent extends StatelessWidget{
  CanvasBollModel canvasModel;
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
  CanvasBollModel canvasModel;
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

    double volume = 0.0; // 成交量
    double turnover = 0.0;
    canvasModel.showKLineData.forEach((item){
      if(item.volume>volume){
        volume = item.volume;
      }

      if(item.turnover>turnover){
        turnover = item.turnover;
      }
    });

    canvasModel.showKLineData.asMap().forEach((i, line) {

      double startPrice = line.startPrice;
      double endPrice = line.endPrice;

      double top;
      double bottom;
      double left = kLineDistance*i+canvasModel.kLineMargin;
      double right = kLineDistance*i+kLineDistance;
      if(isVolume){
        top = priceToPositionDy(line.volume,canvasHeight,volume,0);
        bottom = priceToPositionDy(line.volume,canvasHeight,volume,0);
      }else{
        top = priceToPositionDy(line.turnover,canvasHeight,turnover,0);
        bottom = priceToPositionDy(line.turnover,canvasHeight,turnover,0);
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

//          var data = kLineOffsets[i][2];
//          Code.eventBus.fire(KLineDataInEvent(data));

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