// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
      name: json['name'] as String,
    )
      ..uuid = json['uuid'] as String
      ..background =
          Background.fromJson(json['background'] as Map<String, dynamic>);

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'background': instance.background.toJson(),
    };
