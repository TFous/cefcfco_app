import 'dart:math';
import 'dart:ui';

import 'package:cefcfco_app/common/config/KLineConfig.dart';
import 'package:cefcfco_app/common/model/BollListModel.dart';
import 'package:cefcfco_app/common/model/BollModel.dart';
import 'package:cefcfco_app/common/model/BollPositonsModel.dart';
import 'package:cefcfco_app/common/model/CanvasModel.dart';
import 'package:cefcfco_app/common/model/KLineModel.dart';
import 'package:cefcfco_app/common/utils/monotonex.dart';
/*
k线图的一些公用方法


 */

// 每次调用返回比原先数据多一条
List<KLineModel> getKLineData(List<KLineModel> allData,
    List<KLineModel> historyData, int day, String direction,
    {num: 1, otherDay}) {
  int length = day;
  if (otherDay != null && otherDay > 0) {
    length = day + otherDay - 1;
  }
  int allDataLength = allData.length;
  List<KLineModel> list = [];
  if(historyData.isEmpty){ // 没有历史数据则是初始化，去最新数据
    list = allData.sublist(allDataLength - length);
  }else if (allDataLength <= length) {// 如果总数据小于需求的条数，则直接返回全部
    list = allData.sublist(0, allDataLength);
  } else {
//    print('historyData--${historyData.length}--${historyData.first.kLineDate}');
    KLineModel historyFirstItem = historyData.first;
    KLineModel historyLastItem = historyData.last;
    if (direction == 'right') {
      //向右滑动，数据向前拿⬅

      if (historyFirstItem.kLineDate == allData.first.kLineDate) {
        list = allData.sublist(0, day);
      }  else{
        for (int i = 0; i < allDataLength; i++) {
          if (historyLastItem.kLineDate == allData[i].kLineDate) {
            int start = i - length- num;
            int end = i - num;
            if(start<0){
              start = 0;
              end = day;
            }
            list = allData.sublist(start, end);
          }
        }
      }
    } else {
      // 向左滑动，数据向后→

      //如果原来的数据没有更新的数据，则直接返回最新的一段数据
      if (historyLastItem.kLineDate == allData.last.kLineDate) {
        list = allData.sublist(allDataLength - length);
      } else {
        // 不然返回向后瞬移一条的数据
        for (int i = 0; i < allDataLength; i++) {
//          if (historyFirstItem.kLineDate == allData[i].kLineDate) {
//            print('historyFirstItem--$i');
//          }
          if (historyLastItem.kLineDate == allData[i].kLineDate) {
            int start = i-length+num;
            int end = i + num+1;
            if(start<=0){
              list = allData.sublist(0, end);
            }else if(end>allDataLength){
              list = allData.sublist(allDataLength - length);
            }else{
              list = allData.sublist(start, end);
            }
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
  int length = auxiliaryDatas.length; //28  20  9
  int i = 0;
  int index = -1;  // 默认不在屏幕上显示
  int kLineDataLength = kLineData.length;
  double maxUP; // 最大的上轨
  double minDN; // 最低的下轨
  List<BollModel> list = [];
//  print('${listForN.first.kLineDate}--${listForN.last.kLineDate}---${listForN.length}');
  print('kLineData${kLineData.first.kLineDate}--${kLineData.last.kLineDate}---${kLineData.length}');
  print('auxiliaryDatas${auxiliaryDatas.first.kLineDate}--${auxiliaryDatas.last.kLineDate}---${auxiliaryDatas.length}');
  print('***************');
  for (; i <= length; i++) {
    if (i >= n) {
      List<KLineModel> listForN = auxiliaryDatas.sublist(i-n, i);
      KLineModel last = listForN.last;
      for(var p=0;p<kLineDataLength;p++){
        if(last.kLineDate==kLineData[p].kLineDate){
          index = p;
          print('index}--${index}');

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
        }
      }

      // 存储最下的dn
      if (minDN == null) {
        minDN = bollData.dn;
      } else {
        if (minDN > bollData.dn) {
          minDN = bollData.dn;
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
  int kLineDataLength = kLineData.length;
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