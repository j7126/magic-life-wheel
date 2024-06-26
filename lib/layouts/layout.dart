import 'dart:math';
import 'package:flutter/material.dart';
import 'package:magic_life_wheel/datamodel/player.dart';

class Layout {
  int get players => 0;
  bool get symetrical => true;

  bool rotated = false;

  Widget build(
    BuildContext context,
    List<Player> players,
    Widget Function(int i, int turns) counterParentBuilder, {
    double gap = 8,
    bool evenFlex = false,
  }) {
    assert(players.length == this.players);
    throw UnimplementedError();
  }

  int getTurnsInPosition(int pos) {
    throw UnimplementedError();
  }

  Widget buildPreviewBlock(BuildContext context, BoxConstraints constraints) {
    return Padding(
      padding: EdgeInsets.all(min(constraints.maxHeight, constraints.maxWidth) * 0.06),
      child: Container(
        decoration: BoxDecoration(
          color: IconTheme.of(context).color ?? const Color.fromARGB(0, 0, 0, 0),
          borderRadius: BorderRadius.circular(min(constraints.maxHeight, constraints.maxWidth) * 0.09),
        ),
      ),
    );
  }

  Widget buildPreview(BuildContext context) {
    throw UnimplementedError();
  }
}
