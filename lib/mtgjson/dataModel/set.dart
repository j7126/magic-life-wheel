import 'package:json_annotation/json_annotation.dart';

part 'set.g.dart';

@JsonSerializable(explicitToJson: true)
class MtgSet {
  MtgSet({
    required this.baseSetSize,
    required this.code,
    required this.isFoilOnly,
    required this.isOnlineOnly,
    required this.keyruneCode,
    required this.name,
    required this.releaseDate,
    required this.totalSetSize,
    required this.type,
  });

  int baseSetSize;
  String code;
  bool isFoilOnly;
  bool isOnlineOnly;
  String keyruneCode;
  String name;
  String releaseDate;
  int totalSetSize;
  String type;

  factory MtgSet.fromJson(Map<String, dynamic> json) => _$MtgSetFromJson(json);

  Map<String, dynamic> toJson() => _$MtgSetToJson(this);
}
