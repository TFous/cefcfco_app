import 'package:json_annotation/json_annotation.dart';

/**
 * Created by guoshuyu
 * Date: 2018-07-31
 */

part 'KLineModel.g.dart';

@JsonSerializable()
class KLineModel {

  int id;

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

  @override
  toString(){
    return 'id:$id,kLineDate:$kLineDate';
  }

  KLineModel(
    this.id,
    this.kLineDate,
    this.startPrice,
    this.endPrice,
    this.maxPrice,
    this.minPrice
  );

  factory KLineModel.fromJson(Map<String, dynamic> json) => _$RepositoryFromJson(json);

  Map<String, dynamic> toJson() => _$RepositoryToJson(this);

  KLineModel.empty();
}
