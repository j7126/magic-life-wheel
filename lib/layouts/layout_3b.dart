import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:magic_life_wheel/layouts/layout.dart';
import 'package:magic_life_wheel/datamodel/player.dart';

class Layout3b extends Layout {
  @override
  int get players => 3;

  @override
  Widget build(
    BuildContext context,
    List<Player> players,
    Widget Function(int i, int turns) counterParentBuilder, {
    double gap = 8,
    bool evenFlex = false,
  }) {
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
                child: counter(2),
              ),
              Gap(gap),
              Expanded(
                child: counter(1),
              ),
            ],
          ),
        ),
        Gap(gap),
        Expanded(
          child: counter(0),
        )
      ],
    );
  }

  @override
  int getTurnsInPosition(int pos) {
    switch (pos) {
      case 0:
        return 3;
      case 1:
        return 1;
      case 2:
        return 1;
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
            child: buildPreviewBlock(context, constraints),
          ),
        ],
      ),
    );
  }
}
