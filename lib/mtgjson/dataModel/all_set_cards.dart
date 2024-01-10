import 'package:json_annotation/json_annotation.dart';
import 'package:magic_life_wheel/mtgjson/dataModel/card_set.dart';

part 'all_set_cards.g.dart';

@JsonSerializable(explicitToJson: true)
class AllSetCards {
  AllSetCards(this.data);

  List<CardSet> data;

  factory AllSetCards.fromJson(Map<String, dynamic> json) =>
      _$AllSetCardsFromJson(json);
}
