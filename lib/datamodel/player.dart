import 'package:json_annotation/json_annotation.dart';
import 'package:magic_life_wheel/mtgjson/dataModel/card_set.dart';
import 'package:uuid/uuid.dart';

part 'player.g.dart';

@JsonSerializable(explicitToJson: true)
class Player {
  Player({
    required this.name,
    life,
  }) {
    uuid = (const Uuid()).v4();
    if (life == null) {
      this.life = 40;
    } else {
      this.life = life;
    }
  }

  late String uuid;
  String name;
  CardSet? card;

  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  late int _life;
  
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
  int get life {
    if (deadByCommander) {
      return 0;
    }
    return _life;
  }

  set life(int value) {
    _life = value;
  }

  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  bool get isGameReset => life == 40;

  void dealCommander(String player, int life) {
    commanderDamage[player] = (commanderDamage[player] ?? 0) - life;
    if ((commanderDamage[player] ?? 0) < 0) {
      life += (commanderDamage[player] ?? 0);
      commanderDamage[player] = 0;
    }
    _life += life;
  }

  void deal(int life) {
    if (!deadByCommander) {
      _life += life;
      if (_life < 0) {
        _life = 0;
      }
    }
  }

  void resetGame() {
    _life = 40;
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
