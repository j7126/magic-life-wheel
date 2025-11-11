import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mana_icons_flutter/mana_icons_flutter.dart';

class PlanarDiceDialog extends StatefulWidget {
  const PlanarDiceDialog({super.key});

  @override
  State<PlanarDiceDialog> createState() => _PlanarDiceDialogState();
}

class _PlanarDiceDialogState extends State<PlanarDiceDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 150),
    vsync: this,
    value: 0.3,
    lowerBound: 0,
    upperBound: 0.3,
  )..reverse();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

  int result = -1;

  @override
  void initState() {
    result = Random().nextInt(6);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RotationTransition(
              turns: _animation,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: result == 0
                      ? const Icon(ManaIcons.ms_planeswalker, size: 50)
                      : result == 1
                      ? const Icon(ManaIcons.ms_chaos, size: 50)
                      : Container(),
                ),
              ),
            ),
            const Gap(16),
            Text(
              result == 0
                  ? 'Planeswalk'
                  : result == 1
                  ? 'Chaos'
                  : 'No effect',
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            if (result == 0)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  style: ButtonStyle(
                    padding: const WidgetStatePropertyAll(EdgeInsets.all(10)),
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  child: const Text('Click to Planeswalk'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
