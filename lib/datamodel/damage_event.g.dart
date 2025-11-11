// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'damage_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DamageEvent _$DamageEventFromJson(Map<String, dynamic> json) => DamageEvent(
  priorLife: (json['priorLife'] as num).toInt(),
  change: (json['change'] as num).toInt(),
  fromCommander: json['fromCommander'] as String?,
)..time = DateTime.parse(json['time'] as String);

Map<String, dynamic> _$DamageEventToJson(DamageEvent instance) => <String, dynamic>{
  'priorLife': instance.priorLife,
  'change': instance.change,
  'fromCommander': instance.fromCommander,
  'time': instance.time.toIso8601String(),
};
