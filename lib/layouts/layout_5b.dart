import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:magic_life_wheel/layouts/layout.dart';
import 'package:magic_life_wheel/datamodel/player.dart';

class Layout5b extends Layout {
  @override
  int get players => 5;

  @override
  bool get symetrical => false;

  @override
  Widget build(BuildContext context, List<Player> players, Widget Function(int i, int turns) counterParentBuilder) {
    assert(players.length == this.players);

    counter(int x) {
      var turns = getTurnsInPosition(x);
      return RotatedBox(
        quarterTurns: turns,
        child: counterParentBuilder(x, turns),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: counter(1),
              ),
              const Gap(8),
              Expanded(
                child: counter(0),
              ),
            ],
          ),
        ),
        const Gap(8),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: counter(2),
              ),
              const Gap(8),
              Expanded(
                child: counter(3),
              ),
              const Gap(8),
              Expanded(
                child: counter(4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int getTurnsInPosition(int pos) {
    switch (pos) {
      case 0:
        return 1;
      case 1:
        return 1;
      case 2:
        return 3;
      case 3:
        return 3;
      case 4:
        return 3;
      default:
    }
    return 0;
  }

  @override
  Widget buildPreview(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: buildPreviewBlock(context, constraints),
                ),
                Expanded(
                  child: buildPreviewBlock(context, constraints),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: buildPreviewBlock(context, constraints),
                ),
                Expanded(
                  child: buildPreviewBlock(context, constraints),
                ),
                Expanded(
                  child: buildPreviewBlock(context, constraints),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
