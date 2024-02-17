import 'package:magic_life_wheel/mtgjson/dataModel/card_set.dart';
import 'package:uuid/uuid.dart';

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
  late int _life;
  String name;
  CardSet? card;
  Map<String, int> commanderDamage = {};

  bool get deadByCommander => commanderDamage.values.any((element) => element >= 21);

  int get life {
    if (deadByCommander) {
      return 0;
    }
    return _life;
  }

  set life(int value) {
    _life = value;
  }

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
}
