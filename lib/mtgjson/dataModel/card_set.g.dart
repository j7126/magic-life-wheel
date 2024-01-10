// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CardSetImpl _$$CardSetImplFromJson(Map<String, dynamic> json) =>
    _$CardSetImpl(
      name: json['name'] as String,
      uuid: json['uuid'] as String,
      identifiers:
          Identifiers.fromJson(json['identifiers'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CardSetImplToJson(_$CardSetImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'uuid': instance.uuid,
      'identifiers': instance.identifiers.toJson(),
    };
