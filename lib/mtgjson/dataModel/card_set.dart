import 'package:json_annotation/json_annotation.dart';
import 'package:string_normalizer/string_normalizer.dart';
import 'identifiers.dart';

part 'card_set.g.dart';

@JsonSerializable(explicitToJson: true)
class CardSet {
  CardSet({
    required this.name,
    required this.uuid,
    required this.setCode,
    required this.identifiers,
    required this.artist,
    required this.cardSearchString,
    required this.cardSearchStringWords,
  });

  String name;
  String uuid;
  String setCode;
  String? artist;
  Identifiers identifiers;
  String cardSearchString;
  List<String> cardSearchStringWords;

  factory CardSet.fromJson(Map<String, dynamic> json) => _$CardSetFromJson(json);

  Map<String, dynamic> toJson() => _$CardSetToJson(this);

  static RegExp cardSearchStringFilterEmptyRegex = RegExp('[\']');
  static RegExp cardSearchStringFilterSpaceRegex = RegExp('[-, ]+');

  static String filterStringForSearch(String str) {
    str = str.toLowerCase().normalize();
    str = str.replaceAll(cardSearchStringFilterEmptyRegex, '');
    str = str.replaceAll(cardSearchStringFilterSpaceRegex, ' ');
    return str;
  }

  int getWordMatches(List<String> words) {
    if (cardSearchStringWords.isEmpty) {
      return 0;
    }
    var offset = words.indexWhere((element) => element == cardSearchStringWords.first);
    if (offset < 0) {
      return 0;
    }
    int i = 1;
    while (i < cardSearchStringWords.length && i + offset < words.length) {
      if (cardSearchStringWords[i] != words[i]) {
        break;
      }
      i++;
    }
    return i;
  }
}
