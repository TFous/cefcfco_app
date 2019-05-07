import 'dart:math';
import 'dart:ui';

import 'package:cefcfco_app/common/config/KLineConfig.dart';
import 'package:cefcfco_app/common/model/BollListModel.dart';
import 'package:cefcfco_app/common/model/BollModel.dart';
import 'package:cefcfco_app/common/model/BollPositonsModel.dart';
import 'package:cefcfco_app/common/model/CanvasModel.dart';
import 'package:cefcfco_app/common/model/KLineInfoModel.dart';
import 'package:cefcfco_app/common/model/KLineModel.dart';
import 'package:cefcfco_app/common/utils/monotonex.dart';
import 'package:flutter/material.dart';
/*
k线图的一些公用方法


 */


/// 缩放后根据最后一个item 的时间 获取数据
List<KLineModel> getScaleDatasByLastTime(List<KLineModel> allData,String lastItemTime,int length,{averageDay}){
  int dataLength = allData.length;
  List<KLineModel> list = [];
  int i=0;
  if(averageDay!=null){
    for(;i<dataLength;i++){
      if(allData[i].kLineDate == lastItemTime){
        /// 当最后的index（前面数据的条数）小于 要获取的条数
        if(i<length){
          list = allData.sublist(0,length);
        }else{
          if (i - length-averageDay + 1 <=0) { /// 当最后的index（前面数据的条数）小于（length+averageDay - 1 ）所需要划线的数据，则直接取前面所有的数据
            list = allData.sublist(0, i + 1);
          } else {
            list = allData.sublist(i - length - averageDay + 1, i + 1);
          }
        }
      }
    }
  }else{
    for(;i<dataLength;i++){
      if(allData[i].kLineDate == lastItemTime){
        /// 当最后的index（前面数据的条数）小于 要获取的条数
        if(i<length){
          list = allData.sublist(0,length);
        }else{
          list = allData.sublist(i-length+1,i+1);
        }
      }
    }
  }
  return list;
}


/// 获取当前所有数据中最高和最低值
KLineInfoModel getKLineInfoModel(List<KLineModel> lineData) {
  double maxPrice = 0.0;
  double minPrice = 0.0;

  int i = 0;
  int maxIndex = 0;
  int minIndex = 0;
  int length = lineData.length;

  for (; i < length; i++) {
    KLineModel item = lineData[i];
    if (maxPrice != 0.0) {
      if (maxPrice < item.maxPrice) {
        maxPrice = item.maxPrice;
        maxIndex = i;
      }
      if (minPrice > item.minPrice) {
        minPrice = item.minPrice;
        minIndex = i;
      }
    } else {
      maxPrice = item.maxPrice;
      minPrice = item.minPrice;
      maxIndex = i;
      minIndex = i;
    }
  }

  return new KLineInfoModel(maxIndex, minIndex, maxPrice*(1+KLineConfig.HEIGHT_LIMIT), minPrice*(1-KLineConfig.HEIGHT_LIMIT));
}


// 每次调用返回比原先数据多一条
List<KLineModel> getKLineData(List<KLineModel> allData,
    List<KLineModel> historyData, int day, String direction,
    {num: 1, otherDay=0}) {
  int length = day;
  if (otherDay > 0) {
    length = day + otherDay - 1;
  }
  int allDataLength = allData.length;
  List<KLineModel> list = [];
  if(historyData.isEmpty){ // 没有历史数据则是初始化，去最新数据
    list = allData.sublist(allDataLength - length);
  }else {
    KLineModel historyFirstItem = historyData.first;
    KLineModel historyLastItem = historyData.last;
    List<KLineModel> otherList = [];
    if (direction == 'right') {
      //向右滑动，数据向前拿⬅
      for (int i = 0; i < allDataLength; i++) {
        if (historyFirstItem.kLineDate == allData[i].kLineDate) {
          if(i==0){
            for (int j = 0; j < allDataLength; j++) {
              if (historyLastItem.kLineDate == allData[j].kLineDate) {
                list = allData.sublist(0, j);
              }
            }
          }else{
            int start;
            start = i-1<0?0:i-1;
            otherList = allData.sublist(start, start+1);
            list = otherList+historyData.sublist(0, historyData.length-1);
          }
        }
      }
    } else {
      // 向左滑动，数据向后→
      for (int i = 0; i < allDataLength; i++) {
        if (historyLastItem.kLineDate == allData[i].kLineDate) {
          // 等于最后一个
          if(i==allDataLength-1){
            list = allData.sublist(i-length, i);
          }else if(i<=length){
            list = allData.sublist(0, i+2);
          }else{
            int start;
            start = i+1>=allDataLength?allDataLength:i+1;
            otherList = allData.sublist(start, start+1);
            list = historyData.sublist(1, historyData.length)+otherList;
//            if(otherDay==20){
//              print('${list.length}-${historyData.length}----${historyData.sublist(1, historyData.length).length}-----${otherList.length}');
//            }
          }
        }
      }
    }
  }

  return list;

}

double priceToPositionDy(double nowPrice, double canvasHeight,double dayMaxPrice,double dayMinPrice) {
  double initPrice = (dayMaxPrice + dayMinPrice) / 2;
  double dy = canvasHeight / 2 - ((nowPrice - initPrice) / (dayMaxPrice - initPrice) * canvasHeight / 2);
  return dy;
}

/// 当前时间转换成秒
int getMillisecondsSinceEpoch() {
  return DateTime.now().millisecondsSinceEpoch;
}

/// MA=N日内的收盘价之和除以N(kLineDatas.length)
/// 传入多少数据，计算多少数据的平均数
double getMA(List<KLineModel> kLineDatas) {
  int length = kLineDatas.length;
  double total = 0.0;
  int i = 0;
  for (; i < length; i++) {
    total += kLineDatas[i].endPrice;
  }
  return total / length;
}

double getVariance(c, ma) {
  double num = c - ma;
  return num * num;
}

double getUP(double mb, double md) {
  double num = mb + md * 2;
  return num;
}

double getDN(double mb, double md) {
  double num = mb - md * 2;
  return num;
}

// 获取x轴的位置
double getDx(CanvasModel canvasModel, int lineIndex) {
  double kLineDistance = canvasModel.kLineWidth + canvasModel.kLineMargin;
  double dx = (kLineDistance * lineIndex +
          canvasModel.kLineMargin +
          kLineDistance * lineIndex +
          kLineDistance) /
      2;
  return dx;
}

/// length 几日
double getMdData(List<KLineModel> list, int length) {
  double addAll = 0; // 累加总数，用于计算平均数
  double allVariance = 0; // 累加差值，用于计算md
  list.asMap().forEach((index, num) {
    addAll += num.endPrice;
    double ma = addAll / (index + 1);
    double a = getVariance(num.endPrice, ma);
    allVariance += a;
  });
  return sqrt(allVariance / length);
}

BollModel getBollData(List<KLineModel> slotDatas, int positionIndex) {
  int length = slotDatas.length;

  double mb = getMA(slotDatas); // 这里放也就是ma,平均数
  double md = getMdData(slotDatas, length);

  double up = getUP(mb, md);
  double dn = getDN(mb, md);

  return new BollModel(positionIndex, mb, up, dn);
}

/// 获取几天的平均值数组， 便于计算最高值和最低值
/// n 几天的平局值
/// auxiliaryDatas  画辅助线的总数据
/// kLineDataLength  k线图的数据长度，长度要少于auxiliaryDatas长度，相减值为n-1，
/// 如果相等或不为n-1,则index向后移 index = i+(n-(length-kLineDataLength)-1);
BollListModel getBollDataList(
    List<KLineModel> allKLineData,
    List<KLineModel> auxiliaryDatas,
    int n, List<KLineModel> kLineData) {
  KLineInfoModel kLineListInfo= getKLineInfoModel(kLineData);
  int length = auxiliaryDatas.length; //28  20  9
  int i = 0;
  int index = -1;  // 默认不在屏幕上显示
  int kLineDataLength = kLineData.length;
  double maxUP; // 最大的上轨
  double minDN; // 最低的下轨
  List<BollModel> list = [];
//  print('${listForN.first.kLineDate}--${listForN.last.kLineDate}---${listForN.length}');
//  print('kLineData${kLineData.first.kLineDate}--${kLineData.last.kLineDate}---${kLineData.length}');
//  print('auxiliaryDatas${auxiliaryDatas.first.kLineDate}--${auxiliaryDatas.last.kLineDate}---${auxiliaryDatas.length}');
//  print('***************');
  for (; i <= length; i++) {
    if (i >= n) {
      List<KLineModel> listForN = auxiliaryDatas.sublist(i-n, i);
      KLineModel last = listForN.last;
      for(var p=0;p<kLineDataLength;p++){
        if(last.kLineDate==kLineData[p].kLineDate){
          index = p;
        }
      }

      BollModel bollData = getBollData(listForN, index);
      list.add(bollData);

      // 存储最大的up
      if (maxUP == null) {
        maxUP = bollData.up;
      } else {
        if (maxUP < bollData.up) {
          maxUP = bollData.up;
          if(maxUP<kLineListInfo.maxPrice){
            maxUP = kLineListInfo.maxPrice;
          }
        }
      }

      // 存储最小的dn
      if (minDN == null) {
        minDN = bollData.dn;
      } else {
        if (minDN > bollData.dn) {
          minDN = bollData.dn;
          if(minDN>kLineListInfo.minPrice){
            minDN = kLineListInfo.minPrice;
          }
        }
      }

    }
  }

  return new BollListModel(list, maxUP, minDN);
}

BollPositonsModel bollDataToPosition(
    List<KLineModel> allKLineData,
    List<KLineModel> auxiliaryDatas,
    int n,
    List<KLineModel> kLineData,
    double canvasHeight,
    CanvasModel canvasModel) {
  List<Point> maPointList = [];
  List<Point> upPointList = [];
  List<Point> dnPointList = [];
  BollListModel bollList = getBollDataList(allKLineData,auxiliaryDatas, n, kLineData);
//  print('///////////////////////////');
//  print('item.positionIndex ${kLineData.first.kLineDate}  dx-- (${kLineData.last.kLineDate})');
  int length = bollList.list.length;
  int i=0;
  if(bollList.list.isNotEmpty){
    for(;i<length;i++){
      BollModel item = bollList.list[i];
      double dx = getDx(canvasModel, item.positionIndex);
      double maDy = priceToPositionDy(item.ma, canvasHeight, bollList.maxUP,bollList.minDN);
      double upDy = priceToPositionDy(item.up, canvasHeight, bollList.maxUP,bollList.minDN);
      double dnDy = priceToPositionDy(item.dn, canvasHeight, bollList.maxUP,bollList.minDN);

      maPointList.add(new Point(dx, maDy));
      upPointList.add(new Point(dx, upDy));
      dnPointList.add(new Point(dx, dnDy));
    }
  }else{
    // 空就返回一个空对象
    return new BollPositonsModel(
        kLineData,
        maPointList, upPointList, dnPointList, bollList.maxUP, bollList.minDN);
  }

  return new BollPositonsModel(
      kLineData,
      maPointList, upPointList, dnPointList, bollList.maxUP, bollList.minDN);
}


void drawSmoothLine(Canvas canvas, Paint paint, List<Point> points) {
  if(points.isNotEmpty){
    final path = new Path()
      ..moveTo(points.first.x.toDouble(), points.first.y.toDouble());
    MonotoneX.addCurve(path, points);
    canvas.drawPath(path, paint);
  }else{
    print('无数据！！');
  }
}

//    drawArrow(canvas,_linePaint,new Offset(12,33),new Offset(66,33));
//    drawArrow(canvas,_linePaint,new Offset(66,77),new Offset(12,77));
//    drawArrow(canvas,_linePaint,new Offset(44,12),new Offset(44,77));
//    drawArrow(canvas,_linePaint,new Offset(44,12),new Offset(44,77));
drawArrow(Canvas canvas,Paint linePaint,Offset startOffset,Offset endOffset,{theta:30,headlen:5}) {
  var angle = atan2(startOffset.dy - endOffset.dy, startOffset.dx - endOffset.dx) * 180 / pi,
      angle1 = (angle + theta) * pi / 180,
      angle2 = (angle - theta) * pi / 180,
      topX = headlen * cos(angle1),
      topY = headlen * sin(angle1),
      botX = headlen * cos(angle2),
      botY = headlen * sin(angle2);
  canvas.drawLine(startOffset,endOffset, linePaint);

  canvas.drawLine(new Offset(endOffset.dx + topX, endOffset.dy + topY),endOffset, linePaint);
  canvas.drawLine(new Offset(endOffset.dx + botX, endOffset.dy + botY),endOffset, linePaint);
}


/// 当前横线位置的价格
void drawPrice(Canvas canvas,lineDyPrice,initPriceText,lineDx,lineDy,canvasWidth,canvasHeight,linePaint){
  double copyLineDyPrice; // 判断是否一样，防止不不停刷新
  if(lineDyPrice!=copyLineDyPrice){
    copyLineDyPrice = lineDyPrice;
    var initPriceTextHeight = initPriceText.height/2;
    var margin = 2.0;
    var left = 0.0;
    var right = initPriceText.width+margin*2;
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
      left = canvasWidth - initPriceText.width-margin*2;
    }

    var lineDyPriceReact = RRect.fromLTRBR(left, top, right, bottom,Radius.circular(1.8));
    canvas.drawRRect(lineDyPriceReact, linePaint);
    initPriceText.paint(canvas, Offset(left+margin, top));
  }
}


drawDashLine(Canvas canvas,Offset startOffset,Offset endOffset, {dashLength:5,color='dddddd',strokeWidth:1.0}){
  final Paint black = Paint()
    ..color = Color(int.parse('0xFF$color'))
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke;

  var xpos = endOffset.dx - startOffset.dx; //得到横向的宽度;
  var ypos = endOffset.dy - startOffset.dy; //得到纵向的高度;
  Path p = Path();
  var numDashes = sqrt(xpos * xpos + ypos * ypos) ~/ dashLength;
  //利用正切获取斜边的长度除以虚线长度，得到要分为多少段;
  for(var i=0; i<numDashes; i++){
    if(i % 2 == 0){
      //有了横向宽度和多少段，得出每一段是多长，起点 + 每段长度 * i = 要绘制的起点；
      p.moveTo(startOffset.dx + (xpos/numDashes) * i, startOffset.dy + (ypos/numDashes) * i);
    }else{
      p.lineTo(startOffset.dx + (xpos/numDashes) * i, startOffset.dy + (ypos/numDashes) * i);
    }
  }

  canvas.drawPath(p, black);
}

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
          color: KLineConfig.EQUAL_PRICE_COLOR,
          fontSize: 13.0,
          fontWeight: FontWeight.w500
      ),
    );
}

TextPainter priceVerticalAxisTextPainter(String text) {
  return textPainter
    ..text = TextSpan(
      text: text,
      style: new TextStyle(
        color: KLineConfig.CROSS_TEXT_COLOR,
        fontSize: 10.0,
      ),
    );
}

TextPainter priceTextPainter(String text) {
  return textPainter
    ..text = TextSpan(
      text: text,
      style: new TextStyle(
          color: KLineConfig.ARROW_COLOR,
          fontSize: 10.0,
          fontWeight: FontWeight.w500
      ),
    );
}