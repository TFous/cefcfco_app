import 'dart:ui';

import 'package:cefcfco_app/common/utils/mockData.dart' as mockData;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'PieData.dart';
import 'dart:math';

///自定义  饼状图
/// @author yinl
class MyCustomCircle extends StatelessWidget{

  //数据源
  List datas;
  double initPrice;
  double kLineWidth;
  double kLineMargin;
  //当前选中
  var currentSelect;

  MyCustomCircle(this.datas,this.initPrice,this.kLineWidth,this.kLineMargin);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: CustomPaint(
          painter: MyView(datas,initPrice,kLineWidth,kLineMargin)
      ),
    );
  }

}

class MyView extends CustomPainter{

  //中间文字
  var text='111';
  bool isChange=false;
  //当前选中的扇形
  var currentSelect=0;

  double animValue;
  Paint _mPaint;
  Paint _linePaint;
  Paint TextPaint;
  Paint _EqualLinePaint;
  int mWidth, mHeight;
  Rect mOval,mBigOval;
  List mData;
  double initPrice;
  double kLineWidth;
  double kLineMargin;

  var startAngles=[];

  MyView(this.mData,this.initPrice,this.kLineWidth,this.kLineMargin);


  @override
  void paint(Canvas canvas, Size size) {
    var nowTime;
    /// 如果是分钟图，则分别是 时间，
    /// 当前分钟开盘价格，
    /// 当前分钟收盘价格，
    /// 当前分钟最高价格，
    /// 当前分钟最低价格，
    /// 55.19 ==> initPrice

//    var kLineWidth = 8.0;
//    var kLineMargin = 2.0;
    var kLineDistance = kLineWidth + kLineMargin;
//    double initPrice = 55.19;
    double dayMaxPrice = initPrice*1.1;
    double dayMinPrice = initPrice*0.9;//.toStringAsFixed(2)

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

    var initPriceText = _newVerticalAxisTextPainter(initPrice.toStringAsFixed(2))..layout();

    initPriceText.paint(canvas, Offset(0, cavansHeight/2- initPriceText.height / 2));

    var dayMinPriceText = _newVerticalAxisTextPainter(dayMinPrice.toStringAsFixed(2))..layout();
    dayMinPriceText.paint(canvas, Offset(0, cavansHeight-dayMinPriceText.height));

    var dayMaxPriceText = _newVerticalAxisTextPainter(dayMaxPrice.toStringAsFixed(2))..layout();
    dayMaxPriceText.paint(canvas, Offset(0, 0));

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


    mData.asMap().forEach((i, line) {
      var time = line.kLineDate;
      var now = DateTime.parse(time);
      double startPrice = line.startPrice;
      double endPrice = line.endPrice;
      double maxPrice = line.maxPrice;
      double minPrice = line.minPrice;

      _linePaint..strokeWidth =1.3;
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
      if(top==bottom){ /// 如果开始价格等于结束价格，显示的是一条横线
        kLineReact =Rect.fromLTRB(left, top+1, right, bottom-1);
      }else{
        kLineReact =Rect.fromLTRB(left, top, right, bottom);
      }

//      print(kLineReact);
      canvas.drawRect(kLineReact, _linePaint);

        var maxTop = cavansHeight/2-((maxPrice-initPrice)/(dayMaxPrice-initPrice) * cavansHeight/2);
        var minBottom = cavansHeight/2-((minPrice-initPrice)/(dayMaxPrice-initPrice) * cavansHeight/2);
    canvas.drawLine(new Offset((left+right)/2, maxTop),
        new Offset((left+right)/2, minBottom), _linePaint);
    });


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