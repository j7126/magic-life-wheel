import 'dart:typed_data';
import 'package:json_annotation/json_annotation.dart';
import 'package:magic_life_wheel/mtgjson/dataModel/card_set.dart';
import 'package:magic_life_wheel/serialization/unit_8_list_converter.dart';

part 'background.g.dart';

@JsonSerializable(explicitToJson: true)
class Background {
  Background({
    this.card,
    this.cardPartner,
    this.customImage,
  });

  CardSet? card;
  CardSet? cardPartner;

  @Uint8ListConverter()
  Uint8List? customImage;

  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  bool get hasBackground => card != null || customImage != null;

  factory Background.fromJson(Map<String, dynamic> json) => _$BackgroundFromJson(json);

  Map<String, dynamic> toJson() => _$BackgroundToJson(this);
}
