// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MtgSet _$MtgSetFromJson(Map<String, dynamic> json) => MtgSet(
  baseSetSize: (json['baseSetSize'] as num).toInt(),
  code: json['code'] as String,
  isFoilOnly: json['isFoilOnly'] as bool,
  isOnlineOnly: json['isOnlineOnly'] as bool,
  keyruneCode: json['keyruneCode'] as String,
  name: json['name'] as String,
  releaseDate: json['releaseDate'] as String,
  totalSetSize: (json['totalSetSize'] as num).toInt(),
  type: json['type'] as String,
);

Map<String, dynamic> _$MtgSetToJson(MtgSet instance) => <String, dynamic>{
  'baseSetSize': instance.baseSetSize,
  'code': instance.code,
  'isFoilOnly': instance.isFoilOnly,
  'isOnlineOnly': instance.isOnlineOnly,
  'keyruneCode': instance.keyruneCode,
  'name': instance.name,
  'releaseDate': instance.releaseDate,
  'totalSetSize': instance.totalSetSize,
  'type': instance.type,
};
