// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'KLineModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KLineModel _$KLineModelFromJson(Map<String, dynamic> json) {
  return KLineModel(
      json['date'] as String,
      (json['open'] as num)?.toDouble(),
      (json['close'] as num)?.toDouble(),
      (json['high'] as num)?.toDouble(),
      (json['low'] as num)?.toDouble(),
      (json['volume'] as num)?.toDouble(),
      (json['amount'] as num)?.toDouble(),
      json['turn'] as String);
}

Map<String, dynamic> _$KLineModelToJson(KLineModel instance) =>
    <String, dynamic>{
      'date': instance.date,
      'open': instance.open,
      'close': instance.close,
      'high': instance.high,
      'low': instance.low,
      'volume': instance.volume,
      'amount': instance.amount,
      'turn': instance.turn
    };
