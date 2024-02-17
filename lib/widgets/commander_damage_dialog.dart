import 'dart:math';

import 'package:flutter/material.dart';
import 'package:magic_life_wheel/datamodel/player.dart';
import 'package:magic_life_wheel/layouts/layout.dart';
import 'package:magic_life_wheel/widgets/card_image.dart';

class CommanderDamageDialog extends StatefulWidget {
  const CommanderDamageDialog({super.key, required this.player, required this.layout, required this.players});

  final Player player;
  final Layout layout;
  final List<Player> players;

  @override
  State<CommanderDamageDialog> createState() => _EditCommanderDamageDialog();
}

class _EditCommanderDamageDialog extends State<CommanderDamageDialog> {
  @override
  Widget build(BuildContext context) {
    var onBackgroundShadow = widget.player.card != null
        ? const [
            Shadow(
              offset: Offset(0, 0),
              blurRadius: 2.0,
              color: Color.fromARGB(100, 0, 0, 0),
            ),
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 1.0,
              color: Colors.black,
            ),
            Shadow(
              offset: Offset(2, 2),
              blurRadius: 4.0,
              color: Colors.black,
            ),
          ]
        : null;

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return AlertDialog(
      titlePadding: const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0),
      contentPadding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 32.0, top: 8.0),
      title: Row(
        children: [
          const Text("Commander Damage"),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: SizedBox(
        width: min(width - 100, 260),
        height: min(height - 100, height / width * 260),
        child: widget.layout.build(
          context,
          widget.players,
          (i) {
            var player = widget.players[i];
            var dmg = (widget.player.commanderDamage[player.uuid] ?? 0);
            return SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Card(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.all(2.0),
                child: Stack(
                  children: [
                    if (player.card != null)
                      CardImage(
                        key: Key(player.card?.name ?? ''),
                        cardSet: player.card,
                      ),
                    Positioned.fill(
                      child: Column(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text(
                                  widget.player.uuid == player.uuid && dmg <= 0 ? "me" : dmg.toString(),
                                  style: TextStyle(
                                    shadows: player.card != null
                                        ? [
                                            const Shadow(
                                              offset: Offset(0.5, 0.5),
                                              blurRadius: 10.0,
                                              color: Colors.black,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: !widget.player.deadByCommander || (widget.player.commanderDamage[player.uuid] ?? 0) >= 21
                                ? TextButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                      ),
                                      foregroundColor: MaterialStateProperty.all<Color>(
                                        Theme.of(context).colorScheme.onBackground,
                                      ),
                                      overlayColor: MaterialStateProperty.all<Color>(
                                        Theme.of(context).colorScheme.onBackground.withAlpha(30),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        widget.player.dealCommander(player.uuid, 1);
                                      });
                                    },
                                    onLongPress: () {
                                      setState(() {
                                        widget.player.dealCommander(player.uuid, 10);
                                      });
                                    },
                                    child: SizedBox(
                                      height: double.infinity,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.remove,
                                            shadows: onBackgroundShadow,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(),
                          ),
                          Expanded(
                            child: widget.player.life > 0
                                ? TextButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                      ),
                                      foregroundColor: MaterialStateProperty.all<Color>(
                                        Theme.of(context).colorScheme.onBackground,
                                      ),
                                      overlayColor: MaterialStateProperty.all<Color>(
                                        Theme.of(context).colorScheme.onBackground.withAlpha(30),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        widget.player.dealCommander(player.uuid, -1);
                                      });
                                    },
                                    onLongPress: () {
                                      setState(() {
                                        widget.player.dealCommander(player.uuid, -10);
                                      });
                                    },
                                    child: SizedBox(
                                      height: double.infinity,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            Icons.add,
                                            shadows: onBackgroundShadow,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
