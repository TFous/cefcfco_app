import 'dart:math';

import 'package:cefcfco_app/common/model/BollListModel.dart';
import 'package:cefcfco_app/common/model/BollModel.dart';
import 'package:cefcfco_app/common/model/BollPositonsModel.dart';
import 'package:cefcfco_app/common/model/CanvasModel.dart';
import 'package:cefcfco_app/common/model/KLineModel.dart';

/// k线图的一些公用方法

double priceToPositionDy(double nowPrice,double canvasHeight,CanvasModel canvasModel){
  double initPrice = (canvasModel.dayMaxPrice+canvasModel.dayMinPrice)/2;
  double dy = canvasHeight / 2 - ((nowPrice - initPrice) / (canvasModel.dayMaxPrice - initPrice) * canvasHeight /
      2);
  return dy;
}


/// 当前时间转换成秒
int getMillisecondsSinceEpoch(){
  return DateTime.now().millisecondsSinceEpoch;
}

/// MA=N日内的收盘价之和除以N(kLineDatas.length)
/// 传入多少数据，计算多少数据的平均数
double getMA(List<KLineModel>kLineDatas) {
  int length = kLineDatas.length;
  double total = 0.0;
  int i = 0;
  for (; i < length; i++) {
    total += kLineDatas[i].endPrice;
  }
  return total / length;
}
/// length 几日
double getMdData(List<KLineModel> list,int length){
  double addAll=0; // 累加总数，用于计算平均数
  double allVariance=0;  // 累加差值，用于计算md
  list.asMap().forEach((index,num){
    addAll+=num.endPrice;
    double ma = addAll/(index+1);
    double a = getVariance(num.endPrice,ma);
    allVariance+=a;
  });
  return sqrt(allVariance/length);
}

double getVariance(c,ma){
  double num = c-ma;
  return num*num;
}

double getUP(double mb,double md){
  double num = mb+md*2;
  return num;
}

double getDN(double mb,double md){
  double num = mb-md*2;
  return num;
}

/// 获取几天的平均值数组， 便于计算最高值和最低值
/// n 几天的平局值
/// auxiliaryDatas  画辅助线的总数据
List<Point> getMaList(List<KLineModel>auxiliaryDatas,int n,int kLineDataLength,double canvasHeight,CanvasModel canvasModel){
  int length = auxiliaryDatas.length;
  int i = 0;
  int index = 0;
  List<Point> pointList= [];
  for(;i<length;i++){
    if(i<=length-n){
      List<KLineModel> listForN = auxiliaryDatas.sublist(i,i+n);
      if(length<kLineDataLength+n){
        index = i+(n-(length-kLineDataLength)-1);
      }else{
        index = i;
      }
      Point mdPoint = getUPPoint(listForN,n,index,canvasHeight,canvasModel);
      pointList.add(mdPoint);
    }
  }
  return pointList;
}

/// slotDatas 为计算均值的时间段
Point getUPPoint(List<KLineModel>slotDatas,int day,int lineIndex,double canvasHeight,CanvasModel canvasModel){
  int length = slotDatas.length;
  if(length<day){
    print('当前数据数量太少！-----length:$length');
    return null;
  }

  double mb = getMA(slotDatas);
  double md = getMdData(slotDatas, day);
  double up = getUP(mb, md);

  double dx = getDx(canvasModel,lineIndex);
  double dy = priceToPositionDy(up,canvasHeight,canvasModel);
  Point position =  Point(dx,dy);
  return position;
}

// 获取x轴的位置
double getDx(CanvasModel canvasModel,int lineIndex){
  double kLineDistance = canvasModel.kLineWidth + canvasModel.kLineMargin;
  double dx = (kLineDistance*lineIndex+canvasModel.kLineMargin + kLineDistance*lineIndex+kLineDistance)/2;
  return dx;
}


BollPositonsModel bollDataToPosition(List<KLineModel>auxiliaryDatas,int n,int kLineDataLength,double canvasHeight,CanvasModel canvasModel){

  List<Point> maPointList = [];
  List<Point> upPointList = [];
  List<Point> dnPointList = [];

  BollListModel bollList = getBollDataList(auxiliaryDatas,n,kLineDataLength);

  bollList.list.forEach((item){
    double dx = getDx(canvasModel,item.positionIndex);

    double maDy = priceToPositionDy(item.ma,canvasHeight,canvasModel);
    double upDy = priceToPositionDy(item.up,canvasHeight,canvasModel);
    double dnDy = priceToPositionDy(item.dn,canvasHeight,canvasModel);

    maPointList.add(new Point(dx, maDy));
    upPointList.add(new Point(dx, upDy));
    dnPointList.add(new Point(dx, dnDy));

  });

  return new BollPositonsModel(maPointList,upPointList,dnPointList,bollList.maxUP,bollList.minDN);

}

/// 获取几天的平均值数组， 便于计算最高值和最低值
/// n 几天的平局值
/// auxiliaryDatas  画辅助线的总数据
/// kLineDataLength  k线图的数据长度，长度要少于auxiliaryDatas长度，相减值为n-1，
/// 如果相等或不为n-1,则index向后移 index = i+(n-(length-kLineDataLength)-1);
BollListModel getBollDataList(List<KLineModel>auxiliaryDatas,int n,int kLineDataLength){
  int length = auxiliaryDatas.length;
  int i = 0;
  int index = 0;
  double maxUP; // 最大的上轨
  double minDN; // 最低的下轨
  List<BollModel> list= [];
  for(;i<length;i++){
    if(i<=length-n){
      List<KLineModel> listForN = auxiliaryDatas.sublist(i,i+n);
      if(length<kLineDataLength+n){
        index = i+(n-(length-kLineDataLength)-1);
      }else{
        index = i;
      }

      BollModel bollData = getBollData(listForN,index);
      list.add(bollData);

      // 存储最大的up
      if(maxUP==null){
        maxUP=bollData.up;
      }else{
        if(maxUP<bollData.up){
          maxUP = bollData.up;
        }
      }

      // 存储最下的dn
      if(minDN==null){
        minDN=bollData.dn;
      }else{
        if(minDN>bollData.dn){
          minDN = bollData.dn;
        }
      }

    }
  }
  return new BollListModel(list,maxUP,minDN);
}



BollModel getBollData(List<KLineModel>slotDatas,int positionIndex){
  int length = slotDatas.length;

  double mb = getMA(slotDatas); // 这里放也就是ma,平均数
  double md = getMdData(slotDatas, length);

  double up = getUP(mb, md);
  double dn = getDN(mb, md);

  return new BollModel(positionIndex,mb,up,dn);
}