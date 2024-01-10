// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_set_cards.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AllSetCards _$AllSetCardsFromJson(Map<String, dynamic> json) => AllSetCards(
      (json['data'] as List<dynamic>)
          .map((e) => CardSet.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AllSetCardsToJson(AllSetCards instance) =>
    <String, dynamic>{
      'data': instance.data.map((e) => e.toJson()).toList(),
    };
