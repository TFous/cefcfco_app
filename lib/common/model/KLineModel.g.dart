// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'KLineModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KLineModel _$RepositoryFromJson(Map<String, dynamic> json) {
  return KLineModel(
      json['kLineDate'] as String,
      (json['startPrice'] as num)?.toDouble(),
      (json['endPrice'] as num)?.toDouble(),
      (json['maxPrice'] as num)?.toDouble(),
      (json['minPrice'] as num)?.toDouble());
}

Map<String, dynamic> _$RepositoryToJson(KLineModel instance) =>
    <String, dynamic>{
      'kLineDate': instance.kLineDate,
      'startPrice': instance.startPrice,
      'endPrice': instance.endPrice,
      'maxPrice': instance.maxPrice,
      'minPrice': instance.minPrice
    };
