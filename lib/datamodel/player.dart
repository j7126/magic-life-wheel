import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:magic_life_wheel/mtgjson/dataModel/card_set.dart';
import 'package:magic_life_wheel/serialization/unit_8_list_converter.dart';
import 'package:magic_life_wheel/service/static_service.dart';
import 'package:uuid/uuid.dart';

part 'player.g.dart';

@JsonSerializable(explicitToJson: true)
class Player {
  Player({
    required this.name,
  }) {
    uuid = (const Uuid()).v4();
    life = Service.settingsService.pref_startingLife;
  }

  late String uuid;
  String name;
  CardSet? card;
  CardSet? cardPartner;

  @Uint8ListConverter()
  Uint8List? customImage;

  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  bool forcePartner = false;

  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  Map<String, int> commanderDamage = {};

  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  bool get deadByCommander => commanderDamage.values.any((element) => element >= 21);

  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  bool get dead => (enableDead && life <= 0) || deadByCommander;

  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  bool enableDead = true;

  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  late int life;

  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  bool get isGameReset => life == Service.settingsService.pref_startingLife;

  void dealCommander(String player, int life) {
    commanderDamage[player] = (commanderDamage[player] ?? 0) - life;
    if ((commanderDamage[player] ?? 0) < 0) {
      life += (commanderDamage[player] ?? 0);
      commanderDamage[player] = 0;
    }
    this.life += life;
  }

  void deal(int life) {
    if (dead && life > 0 && !deadByCommander) {
      this.life = life;
    } else {
      this.life += life;
    }
  }

  void resetGame() {
    life = Service.settingsService.pref_startingLife;
    commanderDamage.clear();
  }

  String getDisplayName(int i) {
    if (name.isEmpty) {
      return card?.name ?? "Player ${i + 1}";
    } else {
      return name;
    }
  }

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}
