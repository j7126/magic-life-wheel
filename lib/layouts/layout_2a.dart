import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:magic_life_wheel/layouts/layout.dart';
import 'package:magic_life_wheel/datamodel/player.dart';

class Layout2a extends Layout {
  @override
  int get players => 2;

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

    return Column(
      children: [
        Expanded(
          child: counter(1),
        ),
        Gap(gap),
        Expanded(
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
        return 2;
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
            child: buildPreviewBlock(context, constraints),
          ),
          Expanded(
            child: buildPreviewBlock(context, constraints),
          ),
        ],
      ),
    );
  }
}
