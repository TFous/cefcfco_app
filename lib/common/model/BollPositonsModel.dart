import 'dart:math';
import 'package:cefcfco_app/common/model/KLineModel.dart';

class BollPositonsModel{
  List<KLineModel> historyData; // 存储本次处理的原始数据
  List<Point> maPointList;
  List<Point> upPointList;
  List<Point> dnPointList;
  double maxUP;
  double minDN;

  BollPositonsModel(
      this.historyData,
      this.maPointList,
      this.upPointList,
      this.dnPointList,
      this.maxUP,
      this.minDN
      );
}
