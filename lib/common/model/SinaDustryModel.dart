
class SinaDustryModel{
  String name;
  String code;
  String stkUniCode;
//  int companyNum;
  double ma;
  double riseAndFall; // 涨跌额
  double riseAndFallPer;
  double volume;
  double amount;

  SinaDustryModel(
      this.name,
      this.code,
      this.stkUniCode,
//      this.companyNum,
      this.ma,
      this.riseAndFall,
      this.riseAndFallPer,
      this.volume,
      this.amount
      );
}
