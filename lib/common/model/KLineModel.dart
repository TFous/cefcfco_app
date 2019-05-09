import 'package:json_annotation/json_annotation.dart';

part 'KLineModel.g.dart';

@JsonSerializable()
class KLineModel {
//  @JsonKey(name: "k_line_date")
  String kLineDate;

//  @JsonKey(name: "start_price")
  double startPrice;

//  @JsonKey(name: "end_price")
  double endPrice;

//  @JsonKey(name: "max_price")
  double maxPrice;

//  @JsonKey(name: "min_price")
  double minPrice;

  double volume;  // 成交量

  double turnover;  // 成交额

  String turnoverRate;  // 换手率

  @override
  toString(){
    return 'kLineDate--->$kLineDate-->$endPrice';
  }

  KLineModel(
    this.kLineDate,
    this.startPrice,
    this.endPrice,
    this.maxPrice,
    this.minPrice,
    this.volume,
    this.turnover,
    this.turnoverRate
  );

  factory KLineModel.fromJson(Map<String, dynamic> json) => _$KLineModelFromJson(json);

  Map<String, dynamic> toJson() => _$KLineModelToJson(this);

  KLineModel.empty();
}
