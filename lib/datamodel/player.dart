import 'package:json_annotation/json_annotation.dart';
import 'package:magic_life_wheel/datamodel/background.dart';
import 'package:magic_life_wheel/mtgjson/dataModel/card_set.dart';
import 'package:magic_life_wheel/static_service.dart';
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
  Background background = Background();

  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  CardSet? get card => background.card;
  set card(CardSet? c) => background.card = c;

  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  CardSet? get cardPartner => background.cardPartner;
  set cardPartner(CardSet? c) => background.cardPartner = c;

  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  bool forcePartner = false;

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

  bool enableDead = true;

  late int life;

  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  bool get isGameReset => life == Service.settingsService.pref_startingLife && commanderDamage.isEmpty;

  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  bool get isReset => isGameReset && name.isEmpty && !background.hasBackground;

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
      return background.card?.displayName ?? "Player ${i + 1}";
    } else {
      return name;
    }
  }

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}
