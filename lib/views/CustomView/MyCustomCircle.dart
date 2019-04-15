import 'dart:ui';

import 'package:cefcfco_app/common/model/Repository.dart';
import 'package:cefcfco_app/common/net/Code.dart';
import 'package:cefcfco_app/common/utils/KLineDataInEvent.dart';
import 'package:cefcfco_app/common/utils/mockData.dart' as mockData;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'PieData.dart';
import 'dart:math';

///自定义  饼状图
/// @author yinl
class MyCustomCircle extends StatelessWidget{
  //数据源
  List datas;
  double initPrice;
  double kLineWidth;
  Offset onTapDownDtails;
  double kLineMargin;


  MyCustomCircle(this.datas,this.initPrice,this.kLineWidth,this.kLineMargin,this.onTapDownDtails);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: CustomPaint(
          painter: MyView(datas,initPrice,kLineWidth,kLineMargin,onTapDownDtails)
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
  double initPrice;
  double kLineWidth;
  double kLineMargin;
  List kLineOffsets = []; /// k线位置[[dx,dy]]
  double lineWidth = 1.4;/// 线的宽度  譬如十字坐标
  Offset onTapDownDtails;

  var startAngles=[];

  MyView(this.mData,this.initPrice,this.kLineWidth,this.kLineMargin,this.onTapDownDtails);

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
    var cavansWidth = size.width;
    var cavansHeight = size.height;
    double lineDyPrice;  //横线指的价格
    double copyLineDyPrice; // 判断是否一样，防止不不停刷新
    double lineDy;
    double lineDx;

    Rect rect2 = Rect.fromLTRB(0,0,cavansWidth,cavansHeight);
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

    var _EqualWidth = cavansWidth;
    var _EqualHeight = cavansHeight;
    canvas.drawLine(new Offset(_EqualWidth/4, 0),
        new Offset(_EqualWidth/4, cavansHeight), _EqualLinePaint);
    canvas.drawLine(new Offset(_EqualWidth/4*2, 0),
        new Offset(_EqualWidth/4*2, cavansHeight), _EqualLinePaint);
    canvas.drawLine(new Offset(_EqualWidth/4*3, 0),
        new Offset(_EqualWidth/4*3, cavansHeight), _EqualLinePaint);

    canvas.drawLine(new Offset(0, _EqualHeight/4),
        new Offset(cavansWidth, _EqualHeight/4), _EqualLinePaint);
    canvas.drawLine(new Offset(0, _EqualHeight/4*2),
        new Offset(cavansWidth, _EqualHeight/4*2), _EqualLinePaint);
    canvas.drawLine(new Offset(0, _EqualHeight/4*3),
        new Offset(cavansWidth, _EqualHeight/4*3), _EqualLinePaint);

    _linePaint..strokeWidth =1.3;
    mData.asMap().forEach((i, line) {
      var time = line.kLineDate;
      var now = DateTime.parse(time);
      double startPrice = line.startPrice;
      double endPrice = line.endPrice;
      double maxPrice = line.maxPrice;
      double minPrice = line.minPrice;

      var top;
      var bottom;
      var left = kLineDistance*i+kLineMargin;
      var right = kLineDistance*i+kLineDistance;

      top = cavansHeight/2-(startPrice-initPrice)/(dayMaxPrice-initPrice) * cavansHeight/2;
      bottom = cavansHeight/2-((endPrice-initPrice)/(dayMaxPrice-initPrice) * cavansHeight/2);
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

      var maxTop = cavansHeight / 2 -
          ((maxPrice - initPrice) / (dayMaxPrice - initPrice) * cavansHeight /
              2);
      var minBottom = cavansHeight / 2 -
          ((minPrice - initPrice) / (dayMaxPrice - initPrice) * cavansHeight /
              2);

      canvas.drawLine(
          new Offset((left + right) / 2, maxTop),
          new Offset((left + right) / 2, minBottom),
          _linePaint);
    });

    var initPriceText = _newVerticalAxisTextPainter(initPrice.toStringAsFixed(2))..layout();
    initPriceText.paint(canvas, Offset(0, cavansHeight/2- initPriceText.height / 2));

    var dayMinPriceText = _newVerticalAxisTextPainter(dayMinPrice.toStringAsFixed(2))..layout();
    dayMinPriceText.paint(canvas, Offset(0, cavansHeight-dayMinPriceText.height));

    var dayMaxPriceText = _newVerticalAxisTextPainter(dayMaxPrice.toStringAsFixed(2))..layout();
    dayMaxPriceText.paint(canvas, Offset(0, 0));

    /// 点击后画的十字
    if(onTapDownDtails!=null){
      _linePaint..strokeWidth = lineWidth;
      _linePaint..color = Colors.blueAccent;

      /// 修正dy 上下边界
      if(onTapDownDtails.dy<0){
        lineDy = 0.0;
      }else if(onTapDownDtails.dy>cavansHeight){
        lineDy = cavansHeight;
      }else{
        lineDy = onTapDownDtails.dy;
      }



      /// 竖线
      canvas.drawLine(
          new Offset(0, lineDy),
          new Offset(cavansWidth,lineDy), _linePaint);

      /// 修正dx 为每个klin 的中心
      var kLineLength = kLineOffsets.length;
      var i = 0;
      for(;i<kLineLength;i++){
        var dx = kLineOffsets[i][0];
        lineDx = dx+kLineWidth/2;
        if(dx>onTapDownDtails.dx){
          if(dx>kLineOffsets[kLineLength-1][0]){
            dx = kLineOffsets[kLineLength-2][0];
          }
          /// 横线
          canvas.drawLine(
              new Offset(lineDx, 0),
              new Offset(lineDx,cavansHeight ), _linePaint);

          var a = kLineOffsets[i][2];

          Code.eventBus.fire(KLineDataInEvent(a));

          /// 当前横线位置的价格
          lineDyPrice = (dayMaxPrice-dayMinPrice)*((cavansHeight-lineDy)/cavansHeight)+dayMinPrice;
          if(lineDyPrice!=copyLineDyPrice){
            copyLineDyPrice = lineDyPrice;
            var initPriceText = _priceVerticalAxisTextPainter(lineDyPrice.toStringAsFixed(2))..layout();
            var initPriceTextHeight = initPriceText.height/2;

            var top = lineDy - initPriceTextHeight;
            var bottom = lineDy + initPriceTextHeight;
            print('lineDyPrice------${top}');
            /// 上下边界价格显示
            if(lineDy<initPriceTextHeight){
              top = 0;
              bottom = initPriceText.height;
            }

            if(lineDy>cavansHeight-initPriceText.height){
              top = cavansHeight-initPriceText.height;
              bottom = cavansHeight;
            }
            var lineDyPriceReact = Rect.fromLTRB(0, top, initPriceText.width, bottom);
            canvas.drawRect(lineDyPriceReact, _linePaint);
            initPriceText.paint(canvas, Offset(0, top));
          }

          return;
        }else if(onTapDownDtails.dx>kLineOffsets[kLineLength-1][0]){
          /// 最后的一个线
          lineDx = kLineOffsets[kLineLength-1][0]+kLineWidth/2;
          /// 横线
          canvas.drawLine(
              new Offset(lineDx, 0),
              new Offset(lineDx,cavansHeight ), _linePaint);
          return ;
        }
      }


    }


    ///绘制逻辑与Android差不多
    canvas.save();
    // 将坐标点移动到View的中心
    canvas.restore();

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}