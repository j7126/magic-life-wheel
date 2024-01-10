import 'package:freezed_annotation/freezed_annotation.dart';
import 'identifiers.dart';

part 'card_set.freezed.dart';
part 'card_set.g.dart';

@freezed
class CardSet with _$CardSet {
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory CardSet({
    required String name,
    required String uuid,
    required Identifiers identifiers,
  }) = _CardSet;

  factory CardSet.fromJson(Map<String, dynamic> json) => _$CardSetFromJson(json);
}
