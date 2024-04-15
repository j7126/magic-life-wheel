// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Background _$BackgroundFromJson(Map<String, dynamic> json) => Background(
      card: json['card'] == null
          ? null
          : CardSet.fromJson(json['card'] as Map<String, dynamic>),
      cardPartner: json['cardPartner'] == null
          ? null
          : CardSet.fromJson(json['cardPartner'] as Map<String, dynamic>),
      customImage:
          const Uint8ListConverter().fromJson(json['customImage'] as String?),
    );

Map<String, dynamic> _$BackgroundToJson(Background instance) =>
    <String, dynamic>{
      'card': instance.card?.toJson(),
      'cardPartner': instance.cardPartner?.toJson(),
      'customImage': const Uint8ListConverter().toJson(instance.customImage),
    };
