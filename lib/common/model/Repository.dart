import 'package:json_annotation/json_annotation.dart';

/**
 * Created by guoshuyu
 * Date: 2018-07-31
 */

part 'Repository.g.dart';

@JsonSerializable()
class Repository {

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

  Repository(
    this.id,
    this.kLineDate,
    this.startPrice,
    this.endPrice,
    this.maxPrice,
    this.minPrice
  );

  factory Repository.fromJson(Map<String, dynamic> json) => _$RepositoryFromJson(json);

  Map<String, dynamic> toJson() => _$RepositoryToJson(this);

  Repository.empty();
}
