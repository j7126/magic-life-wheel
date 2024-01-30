import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:magic_life_wheel/mtgjson/dataModel/set.dart';

part 'sets.g.dart';

@JsonSerializable(explicitToJson: true)
class MtgSets {
  MtgSets(this.data);

  List<MtgSet> data;

  factory MtgSets.fromJson(Map<String, dynamic> json) => _$MtgSetsFromJson(json);

  Map<String, dynamic> toJson() => _$MtgSetsToJson(this);

  MtgSet? getSet(String setCode) {
    return data.firstWhereOrNull((element) => element.code == setCode);
  }
}