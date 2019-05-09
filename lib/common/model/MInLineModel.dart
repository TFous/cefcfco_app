import 'package:json_annotation/json_annotation.dart';

part 'MInLineModel.g.dart';

@JsonSerializable()
class MInLineModel {
  int time;
  double price;
  int volume;  // 成交量



  MInLineModel(
    this.time,
    this.price,
    this.volume,
  );

  factory MInLineModel.fromJson(Map<String, dynamic> json) => _$MInLineModelFromJson(json);

  Map<String, dynamic> toJson() => _$MInLineModelToJson(this);

  MInLineModel.empty();
}
