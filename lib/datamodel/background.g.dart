// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Background _$BackgroundFromJson(Map<String, dynamic> json) => Background()
  ..cardProtobuf =
      const Uint8ListConverter().fromJson(json['cardProtobuf'] as String?)
  ..cardPartnerProtobuf = const Uint8ListConverter()
      .fromJson(json['cardPartnerProtobuf'] as String?)
  .._customImage =
      const Uint8ListConverter().fromJson(json['_customImage'] as String?)
  .._colors = (json['_colors'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList();

Map<String, dynamic> _$BackgroundToJson(Background instance) =>
    <String, dynamic>{
      'cardProtobuf': const Uint8ListConverter().toJson(instance.cardProtobuf),
      'cardPartnerProtobuf':
          const Uint8ListConverter().toJson(instance.cardPartnerProtobuf),
      '_customImage': const Uint8ListConverter().toJson(instance._customImage),
      '_colors': instance._colors,
    };
