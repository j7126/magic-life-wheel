import 'package:json_annotation/json_annotation.dart';

part 'identifiers.g.dart';

@JsonSerializable(explicitToJson: true)
class Identifiers {
  Identifiers();

  String? scryfallId;
  String? scryfallOracleId;
  String? scryfallIllustrationId;

  factory Identifiers.fromJson(Map<String, dynamic> json) =>
      _$IdentifiersFromJson(json);

  Map<String, dynamic> toJson() => _$IdentifiersToJson(this);
}
