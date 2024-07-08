// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Background _$BackgroundFromJson(Map<String, dynamic> json) => Background()
  .._card = json['_card'] == null
      ? null
      : CardSet.fromJson(json['_card'] as Map<String, dynamic>)
  .._cardPartner = json['_cardPartner'] == null
      ? null
      : CardSet.fromJson(json['_cardPartner'] as Map<String, dynamic>)
  .._customImage =
      const Uint8ListConverter().fromJson(json['_customImage'] as String?)
  .._colors = (json['_colors'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList();

Map<String, dynamic> _$BackgroundToJson(Background instance) =>
    <String, dynamic>{
      '_card': instance._card?.toJson(),
      '_cardPartner': instance._cardPartner?.toJson(),
      '_customImage': const Uint8ListConverter().toJson(instance._customImage),
      '_colors': instance._colors,
    };
