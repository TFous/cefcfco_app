import 'dart:ui';
import 'package:cefcfco_app/common/model/KLineModel.dart';

class CanvasModel{
  List<KLineModel> showKLineData;
  List<KLineModel> day5Data;
  List<KLineModel> day10Data;
  double dayMaxPrice;
  double dayMinPrice;
  double kLineWidth;
  double kLineMargin;
  Offset onTapDownDtails;
  bool isShowCross;

  CanvasModel(this.showKLineData,
      this.day5Data,
      this.day10Data,
      this.dayMaxPrice,
      this.dayMinPrice,
      this.kLineWidth,
      this.kLineMargin,
      this.onTapDownDtails,
      this.isShowCross
      );

}
