import 'dart:ui';
import 'package:cefcfco_app/common/model/MInLineModel.dart';

class MinCanvasModel{
  List<MInLineModel> minLineData;
  double initPrice;
  Offset onTapDownDtails;
  bool isShowCross;

  MinCanvasModel(
      this.minLineData,
      this.initPrice,
      this.onTapDownDtails,
      this.isShowCross
      );
}
