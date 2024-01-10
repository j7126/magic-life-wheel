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

  bool get isGameReset => life == 40;

  void resetGame() {
    life = 40;
  }
}
