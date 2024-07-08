import 'package:json_annotation/json_annotation.dart';
import 'package:magic_life_wheel/mtgjson/dataModel/leadership_skills.dart';
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
    required this.types,
    required this.subtypes,
    required this.supertypes,
    this.leadershipSkills,
    this.keywords,
    this.text,
    required this.cardSearchString,
    required this.cardSearchStringWords,
  });

  String name;
  String uuid;
  String setCode;
  String? artist;
  Identifiers identifiers;
  List<String> types;
  List<String> subtypes;
  List<String> supertypes;
  LeadershipSkills? leadershipSkills;
  List<String>? keywords;
  String? text;
  String? flavorName;

  String cardSearchString;
  List<String> cardSearchStringWords;
  String? cardSearchStringAlt;
  List<String>? cardSearchStringWordsAlt;

  factory CardSet.fromJson(Map<String, dynamic> json) => _$CardSetFromJson(json);

  Map<String, dynamic> toJson() => _$CardSetToJson(this);

  static RegExp cardSearchStringFilterEmptyRegex = RegExp('[\']');
  static RegExp cardSearchStringFilterSpaceRegex = RegExp('[-,. ]+');

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

  bool get isPartner => keywords?.contains("Partner") ?? false;

  String get displayName => flavorName ?? name;
}
