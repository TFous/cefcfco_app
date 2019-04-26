import 'dart:math';

class BollPositonsModel{
  List<Point> maPointList;
  List<Point> upPointList;
  List<Point> dnPointList;
  double maxUP;
  double minDN;

  BollPositonsModel(
      this.maPointList,
      this.upPointList,
      this.dnPointList,
      this.maxUP,
      this.minDN
      );
}
