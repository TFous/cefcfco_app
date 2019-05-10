import 'dart:math';
import 'dart:ui';

import 'package:cefcfco_app/common/config/KLineConfig.dart';
import 'package:cefcfco_app/common/model/BollListModel.dart';
import 'package:cefcfco_app/common/model/CanvasBollModel.dart';
import 'package:cefcfco_app/common/model/CanvasModel.dart';
import 'package:cefcfco_app/common/model/KLineModel.dart';
import 'package:cefcfco_app/common/model/MInLineModel.dart';
import 'package:cefcfco_app/common/model/MinCanvasModel.dart';
import 'package:cefcfco_app/common/net/Code.dart';
import 'package:cefcfco_app/common/utils/KLineDataInEvent.dart';
import 'package:cefcfco_app/common/utils/KLineUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// @author xiaolei.teng
class MinVolumeComponent extends StatelessWidget{
  MinCanvasModel canvasModel;
  bool isVolume;
  MinVolumeComponent(this.canvasModel,this.isVolume);

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
  MinCanvasModel canvasModel;
  bool isVolume;

  MyView(this.canvasModel,this.isVolume);


  @override
  void paint(Canvas canvas, Size size) {

    TextPaint = new Paint()
    ..color = KLineConfig.WRAP_BORDER_COLOR
      ..style=PaintingStyle.stroke
    ..strokeWidth =1.0;

    double canvasWidth = size.width;
    double canvasHeight = size.height;

    int minLength = 242;// 全天的开盘分钟数 开始的930 和结束的3.00
    double minWidth = canvasWidth/minLength;
    
    double lineDyPrice;  //横线指的价格
    double lineDy;
    double lineDx;
    Rect rect2 = Rect.fromLTRB(0,0,canvasWidth,canvasHeight);
    canvas.drawRect(rect2, TextPaint);

    _linePaint = new Paint();
    _linePaint..strokeWidth =1.3;
    _linePaint..color = KLineConfig.KLINE_UP_COLOR;
    // 区域等分线三横三竖

    drawDashLine(canvas,new Offset(0, canvasHeight/4*2),
        new Offset(canvasWidth, canvasHeight/4*2));

    // 区域等分线三横三竖 --end

    int maxVolume = 0; // 成交量
    canvasModel.minLineData.forEach((item){
      if(item.volume>maxVolume){
        maxVolume = item.volume;
      }
    });



    canvasModel.minLineData.asMap().forEach((i, line) {
      double dx;
      double endDy;
      if(i== minLength-1){
        dx = canvasWidth-minWidth;
        endDy = priceToPositionDy(line.volume.toDouble(),canvasHeight,maxVolume.toDouble(),0);
        canvas.drawLine(
            new Offset(dx, canvasHeight),
            new Offset(dx, endDy),
            _linePaint);
      }else{
        endDy = priceToPositionDy(line.volume.toDouble(),canvasHeight,maxVolume.toDouble(),0);
        dx = minWidth*i;
        canvas.drawLine(
            new Offset(dx, canvasHeight),
            new Offset(dx, endDy),
            _linePaint);
      }

      kLineOffsets.add([dx,line]);

    });

    // 成交量均线及其信息

    if(!canvasModel.isShowCross){
      var volumeText = volumeTextPainter(isVolume?'成交量':'成交额',KLineConfig.VOLUME_MAX_COLOR)..layout();
      volumeText.paint(canvas, Offset(KLineConfig.EQUAL_PRICE_MARGIN,0.0));
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
        lineDx = dx+minWidth/2;

        if(dx>canvasModel.onTapDownDtails.dx){
          /// 竖线
          canvas.drawLine(
              new Offset(lineDx, 0),
              new Offset(lineDx,canvasHeight ), _linePaint);


//          Code.eventBus.fire(KLineDataInEvent(data));

          if(canvasModel.isShowCross){
            MInLineModel data = kLineOffsets[i][1];

            var turn = volumeTextPainter('当前价格:${data.price}',KLineConfig.TURN_COLOR)..layout();
            turn.paint(canvas, Offset(canvasWidth/5*3+8,0.0)); // 换手率字太长，加了8像素好看点

          }

          return;
        }
        else if(canvasModel.onTapDownDtails.dx>kLineOffsets.last[0]){
          /// 最后的一个线
          lineDx = kLineOffsets.last[0]-minWidth/2;
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