import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:magic_life_wheel/layouts/layout.dart';
import 'package:magic_life_wheel/datamodel/player.dart';

class Layout5a extends Layout {
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

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: counter(2),
              ),
              const Gap(8),
              Expanded(
                child: counter(3),
              ),
            ],
          ),
        ),
        const Gap(8),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: counter(1),
              ),
              const Gap(8),
              Expanded(
                child: counter(4),
              ),
            ],
          ),
        ),
        const Gap(8),
        Expanded(
          flex: 2,
          child: counter(0),
        ),
      ],
    );
  }

  @override
  int getTurnsInPosition(int pos) {
    switch (pos) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 1;
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
      builder: (context, constraints) => Column(
        children: [
          Expanded(
            child: Row(
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
            child: Row(
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
            child: buildPreviewBlock(context, constraints),
          ),
        ],
      ),
    );
  }
}
