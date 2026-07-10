// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) =>
    Player(
        name: json['name'] as String,
        background: json['background'] == null
            ? null
            : Background.fromJson(json['background'] as Map<String, dynamic>),
      )
      ..uuid = json['uuid'] as String
      ..enableDead = json['enableDead'] as bool
      ..life = (json['life'] as num).toInt()
      ..commanderDamage = Map<String, int>.from(json['commanderDamage'] as Map)
      ..damageHistory = (json['damageHistory'] as List<dynamic>)
          .map((e) => DamageEvent.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'name': instance.name,
  'background': instance.background.toJson(),
  'enableDead': instance.enableDead,
  'life': instance.life,
  'commanderDamage': instance.commanderDamage,
  'damageHistory': instance.damageHistory.map((e) => e.toJson()).toList(),
};
