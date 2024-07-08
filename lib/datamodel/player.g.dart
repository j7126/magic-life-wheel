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
          Background.fromJson(json['background'] as Map<String, dynamic>)
      ..commanderDamage = Map<String, int>.from(json['commanderDamage'] as Map)
      ..enableDead = json['enableDead'] as bool
      ..life = (json['life'] as num).toInt();

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'background': instance.background.toJson(),
      'commanderDamage': instance.commanderDamage,
      'enableDead': instance.enableDead,
      'life': instance.life,
    };
