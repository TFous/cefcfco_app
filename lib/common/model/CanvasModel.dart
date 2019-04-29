import 'dart:ui';
import 'package:cefcfco_app/common/model/KLineModel.dart';

class CanvasModel{
  List<KLineModel> allKLineData;
  List<KLineModel> showKLineData;
  List<KLineModel> day5Data;
  List<KLineModel> day10Data;
  List<KLineModel> day15Data;
  List<KLineModel> day20Data;
  double dayMaxPrice;
  double dayMinPrice;
  double kLineWidth;
  double kLineMargin;
  Offset onTapDownDtails;
  bool isShowCross;

  CanvasModel(
      this.allKLineData,
      this.showKLineData,
      this.day5Data,
      this.day10Data,
      this.day15Data,
      this.day20Data,
      this.dayMaxPrice,
      this.dayMinPrice,
      this.kLineWidth,
      this.kLineMargin,
      this.onTapDownDtails,
      this.isShowCross
      );

}
