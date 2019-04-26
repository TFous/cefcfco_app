import 'package:cefcfco_app/common/model/CanvasModel.dart';

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