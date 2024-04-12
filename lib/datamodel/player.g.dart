// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
      name: json['name'] as String,
    )
      ..uuid = json['uuid'] as String
      ..card = json['card'] == null
          ? null
          : CardSet.fromJson(json['card'] as Map<String, dynamic>)
      ..cardPartner = json['cardPartner'] == null
          ? null
          : CardSet.fromJson(json['cardPartner'] as Map<String, dynamic>)
      ..customImage =
          const Uint8ListConverter().fromJson(json['customImage'] as String?);

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'card': instance.card?.toJson(),
      'cardPartner': instance.cardPartner?.toJson(),
      'customImage': const Uint8ListConverter().toJson(instance.customImage),
    };
