import 'package:magic_life_wheel/mtgjson/dataModel/card_set.dart';

class Player {
  Player({
    required this.name,
    life,
  }) {
    if (life == null) {
      this.life = 40;
    } else {
      this.life = life;
    }
  }

  late int life;
  late String name;
  CardSet? card;

  bool get isGameReset => life == 40;

  void resetGame() {
    life = 40;
  }
}
