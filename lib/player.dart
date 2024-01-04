class Player {
  Player({
    required this.id,
    life,
  }) {
    name = "Player ${id + 1}";
    if (life == null) {
      this.life = 40;
    } else {
      this.life = life;
    }
  }

  final int id;
  late int life;
  late String name;

  bool get isGameReset => life == 40;

  void resetGame() {
    life = 40;
  }
}
