import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:magic_life_wheel/layouts/layout.dart';
import 'package:magic_life_wheel/datamodel/player.dart';

class Layout6a extends Layout {
  @override
  int get players => 6;

  @override
  Widget build(BuildContext context, List<Player> players, Widget Function(int i) counterParentBuilder) {
    assert(players.length == this.players);

    counter(int x) {
      return counterParentBuilder(x);
    }

    return Column(
      children: [
        Expanded(
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
                  child: counter(3),
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        Expanded(
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
                  child: counter(4),
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: RotatedBox(
                  quarterTurns: 1,
                  child: counter(0),
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
      ],
    );
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
        ],
      ),
    );
  }
}
