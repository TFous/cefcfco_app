// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'MInLineModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MInLineModel _$MInLineModelFromJson(Map<String, dynamic> json) {
  return MInLineModel(json['time'] as int, (json['price'] as num)?.toDouble(),
      json['volume'] as int);
}

Map<String, dynamic> _$MInLineModelToJson(MInLineModel instance) =>
    <String, dynamic>{
      'time': instance.time,
      'price': instance.price,
      'volume': instance.volume
    };
