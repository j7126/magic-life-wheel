import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:magic_life_wheel/mtgjson/dataModel/card_set.dart';
import 'package:magic_life_wheel/serialization/unit_8_list_converter.dart';
import 'package:magic_life_wheel/static_service.dart';

part 'background.g.dart';

@JsonSerializable(explicitToJson: true)
class Background {
  Background();

  @JsonKey(
    includeFromJson: true,
    includeToJson: true,
  )
  CardSet? _card;
  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  CardSet? get card => _card;
  set card(CardSet? value) {
    _card = value;
    if (value != null) {
      customImage = null;
      colors = null;
    }
  }

  @JsonKey(
    includeFromJson: true,
    includeToJson: true,
  )
  CardSet? _cardPartner;
  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  CardSet? get cardPartner => _cardPartner;
  set cardPartner(CardSet? value) {
    _cardPartner = value;
    if (value != null) {
      customImage = null;
      colors = null;
    }
  }

  @JsonKey(
    includeFromJson: true,
    includeToJson: true,
  )
  @Uint8ListConverter()
  Uint8List? _customImage;
  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  Uint8List? get customImage => _customImage;
  set customImage(Uint8List? value) {
    _customImage = value;
    if (value != null) {
      card = null;
      cardPartner = null;
      colors = null;
    }
  }

  @JsonKey(
    includeFromJson: true,
    includeToJson: true,
  )
  List<int>? _colors;
  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  List<Color>? get colors => _colors?.map((e) => Color(e)).toList();
  set colors(List<Color>? value) {
    _colors = value?.map((e) => e.value).toList();
    if (value != null) {
      card = null;
      cardPartner = null;
      customImage = null;
    }
  }

  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  bool get hasBackground => (card != null && Service.settingsService.pref_getScryfallImages) || customImage != null || colors != null;

  void clear() {
    card = null;
    cardPartner = null;
    customImage = null;
    colors = null;
  }

  factory Background.fromJson(Map<String, dynamic> json) => _$BackgroundFromJson(json);

  Map<String, dynamic> toJson() => _$BackgroundToJson(this);
}
