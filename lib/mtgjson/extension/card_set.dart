import 'package:magic_life_wheel/mtgjson/magic_life_wheel_protobuf/card_set.pb.dart';
import 'package:string_normalizer/string_normalizer.dart';

extension CardSetExtension on CardSet {
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

  bool canPartner(CardSet other) {
    // partner
    return (hasKeywordPartner() && other.hasKeywordPartner()) ||
        // friends forever
        (hasKeywordFriendsForever() && other.hasKeywordFriendsForever()) ||
        // doctor's companion
        (hasKeywordDoctorsCompanion() && other.hasSubtypeTimeLordDoctor()) ||
        (hasSubtypeTimeLordDoctor() && other.hasKeywordDoctorsCompanion()) ||
        // choose a background
        (hasKeywordChooseBackground() && other.hasSubtypeBackground()) ||
        (hasSubtypeBackground() && other.hasKeywordChooseBackground());
  }

  String get displayName => hasFlavorName() ? flavorName : name;
}
