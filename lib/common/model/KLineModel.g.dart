// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'KLineModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KLineModel _$KLineModelFromJson(Map<String, dynamic> json) {
  return KLineModel(
      json['kLineDate'] as String,
      (json['startPrice'] as num)?.toDouble(),
      (json['endPrice'] as num)?.toDouble(),
      (json['maxPrice'] as num)?.toDouble(),
      (json['minPrice'] as num)?.toDouble(),
      (json['volume'] as num)?.toDouble(),
      (json['turnover'] as num)?.toDouble(),
      json['turnoverRate'] as String);
}

Map<String, dynamic> _$KLineModelToJson(KLineModel instance) =>
    <String, dynamic>{
      'kLineDate': instance.kLineDate,
      'startPrice': instance.startPrice,
      'endPrice': instance.endPrice,
      'maxPrice': instance.maxPrice,
      'minPrice': instance.minPrice,
      'volume': instance.volume,
      'turnover': instance.turnover,
      'turnoverRate': instance.turnoverRate
    };
