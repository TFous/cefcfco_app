import 'package:json_annotation/json_annotation.dart';

part 'KLineModel.g.dart';

@JsonSerializable()
class KLineModel {
//  @JsonKey(name: "k_line_date")
  String date;

//  @JsonKey(name: "start_price")
  double open;

//  @JsonKey(name: "end_price")
  double close;

//  @JsonKey(name: "max_price")
  double high;

//  @JsonKey(name: "min_price")
  double low;

  double volume;  // 成交量

  double amount;  // 成交额

  String turn;  // 换手率

  @override
  toString(){
    return 'kLineDate--->$date-->$close';
  }

  KLineModel(
    this.date,
    this.open,
    this.close,
    this.high,
    this.low,
    this.volume,
    this.amount,
    this.turn
  );

  factory KLineModel.fromJson(Map<String, dynamic> json) => _$KLineModelFromJson(json);

  Map<String, dynamic> toJson() => _$KLineModelToJson(this);

  KLineModel.empty();
}
