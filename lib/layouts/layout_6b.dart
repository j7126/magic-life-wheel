import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:magic_life_wheel/layouts/layout.dart';
import 'package:magic_life_wheel/player.dart';
import 'package:magic_life_wheel/widgets/counter.dart';

class Layout6b extends Layout {
  @override
  int get players => 6;

  @override
  Widget build(BuildContext context, List<Player> players, Widget Function(Widget child, int i) counterParentBuilder) {
    assert(players.length == this.players);

    counter(int x) {
      return counterParentBuilder(
        Counter(
          player: players[x],
        ),
        x,
      );
    }

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: RotatedBox(
            quarterTurns: 2,
            child: counter(3),
          ),
        ),
        const Gap(8),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: RotatedBox(
                  quarterTurns: 1,
                  child: counter(2),
                ),
              ),
              const Gap(8),
              Expanded(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: counter(4),
                ),
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
                child: RotatedBox(
                  quarterTurns: 1,
                  child: counter(1),
                ),
              ),
              const Gap(8),
              Expanded(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: counter(5),
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        Expanded(
          flex: 2,
          child: RotatedBox(
            quarterTurns: 0,
            child: counter(0),
          ),
        ),
      ],
    );
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
