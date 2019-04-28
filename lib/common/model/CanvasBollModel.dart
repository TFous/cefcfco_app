import 'dart:math';
import 'dart:ui';
import 'package:cefcfco_app/common/model/KLineModel.dart';

class CanvasBollModel{
  List<KLineModel> historyData; // 存储本次处理的原始数据
  List<KLineModel> showKLineData;
  List<Point> maPointList;
  List<Point> upPointList;
  List<Point> dnPointList;
  double dayMaxPrice;
  double dayMinPrice;
  double kLineWidth;
  double kLineMargin;
  Offset onTapDownDtails;
  bool isShowCross;

  CanvasBollModel(
      this.historyData,
      this.showKLineData,
      this.maPointList,
      this.upPointList,
      this.dnPointList,
      this.dayMaxPrice,
      this.dayMinPrice,
      this.kLineWidth,
      this.kLineMargin,
      this.onTapDownDtails,
      this.isShowCross
      );

}
