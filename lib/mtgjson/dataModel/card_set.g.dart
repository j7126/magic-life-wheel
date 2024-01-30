// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardSet _$CardSetFromJson(Map<String, dynamic> json) => CardSet(
      name: json['name'] as String,
      uuid: json['uuid'] as String,
      setCode: json['setCode'] as String,
      identifiers:
          Identifiers.fromJson(json['identifiers'] as Map<String, dynamic>),
      artist: json['artist'] as String?,
    );

Map<String, dynamic> _$CardSetToJson(CardSet instance) => <String, dynamic>{
      'name': instance.name,
      'uuid': instance.uuid,
      'setCode': instance.setCode,
      'artist': instance.artist,
      'identifiers': instance.identifiers.toJson(),
    };
