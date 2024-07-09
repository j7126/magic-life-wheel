import 'package:json_annotation/json_annotation.dart';

part 'damage_event.g.dart';

@JsonSerializable(explicitToJson: true)
class DamageEvent {
  DamageEvent({
    required this.priorLife,
    required this.change,
    this.fromCommander,
  });

  final int priorLife;
  int change;
  final String? fromCommander;
  DateTime time = DateTime.now();

  int get lifeAfter => priorLife + change;

  factory DamageEvent.fromJson(Map<String, dynamic> json) => _$DamageEventFromJson(json);

  Map<String, dynamic> toJson() => _$DamageEventToJson(this);
}
