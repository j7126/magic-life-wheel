import 'package:json_annotation/json_annotation.dart';
import 'package:magic_life_wheel/datamodel/background.dart';
import 'package:magic_life_wheel/datamodel/damage_event.dart';
import 'package:magic_life_wheel/mtgjson/extension/card_set.dart';
import 'package:magic_life_wheel/mtgjson/magic_life_wheel_protobuf/card_set.pb.dart';
import 'package:magic_life_wheel/static_service.dart';
import 'package:uuid/uuid.dart';

part 'player.g.dart';

@JsonSerializable(explicitToJson: true)
class Player {
  Player({
    required this.name,
    Background? background,
  }) {
    uuid = (const Uuid()).v4();
    life = Service.settingsService.pref_startingLife;
    if (background != null) {
      this.background = background;
    }
  }

  late String uuid;
  String name;
  Background background = Background();
  bool enableDead = true;
  late int life;
  Map<String, int> commanderDamage = {};
  List<DamageEvent> damageHistory = [];

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
  bool get isGameReset => life == Service.settingsService.pref_startingLife && commanderDamage.isEmpty;

  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  bool get isReset => isGameReset && name.isEmpty && !background.hasBackground;

  void dealCommander(String player, int life) {
    // handle commander
    commanderDamage[player] = (commanderDamage[player] ?? 0) - life;
    // don't allow going below 0 commander damage
    if ((commanderDamage[player] ?? 0) < 0) {
      life += (commanderDamage[player] ?? 0);
      commanderDamage[player] = 0;
    }
    // history
    var now = DateTime.now();
    if (damageHistory.isNotEmpty &&
        damageHistory.last.fromCommander == player &&
        (now.millisecondsSinceEpoch - damageHistory.last.time.millisecondsSinceEpoch) < 5000) {
      damageHistory.last.change += life;
      damageHistory.last.time = now;
      if (damageHistory.last.change == 0) {
        damageHistory.removeLast();
      }
    } else {
      damageHistory.add(DamageEvent(
        priorLife: this.life,
        change: life,
        fromCommander: player,
      ));
    }
    // update life
    this.life += life;
  }

  void deal(int life) {
    var fromDead = dead && life > 0 && !deadByCommander;
    // history
    var now = DateTime.now();
    if (!fromDead &&
        damageHistory.isNotEmpty &&
        damageHistory.last.fromCommander == null &&
        (now.millisecondsSinceEpoch - damageHistory.last.time.millisecondsSinceEpoch) < 5000) {
      damageHistory.last.change += life;
      damageHistory.last.time = now;
      if (damageHistory.last.change == 0) {
        damageHistory.removeLast();
      }
    } else {
      damageHistory.add(DamageEvent(
        priorLife: fromDead ? 0 : this.life,
        change: life,
      ));
    }
    // update life
    if (fromDead) {
      this.life = life;
    } else {
      this.life += life;
    }
  }

  void resetGame() {
    life = Service.settingsService.pref_startingLife;
    commanderDamage.clear();
    damageHistory.clear();
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
