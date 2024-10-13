import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magic_life_wheel/datamodel/player.dart';
import 'package:magic_life_wheel/dialog_service.dart';
import 'package:magic_life_wheel/layouts/layout.dart';
import 'package:magic_life_wheel/static_service.dart';
import 'package:magic_life_wheel/life_counter_page/card_image/card_image.dart';
import 'package:magic_life_wheel/life_counter_page/card_image/background_widget.dart';

class CommanderDamageDialog extends StatefulWidget {
  const CommanderDamageDialog({super.key, required this.player, required this.layout, required this.players});

  final Player player;
  final Layout layout;
  final List<Player> players;

  @override
  State<CommanderDamageDialog> createState() => _EditCommanderDamageDialog();
}

class _EditCommanderDamageDialog extends State<CommanderDamageDialog> {
  Timer? lifeChangedTimer;
  String? lastChanged;

  void changeLife(String cmdid, int x) {
    setState(() {
      lastChanged = cmdid;
      widget.player.dealCommander(cmdid, x);
    });
    lifeChangedTimer?.cancel();
    lifeChangedTimer = Timer(
      const Duration(milliseconds: 5001),
      () {
        setState(() {});
        lifeChangedTimer?.cancel();
        lifeChangedTimer = null;
      },
    );
  }

  @override
  void initState() {
    DialogService.register(context);
    super.initState();
  }

  @override
  void dispose() {
    DialogService.deregister(context);
    lifeChangedTimer?.cancel();
    lifeChangedTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var onBackgroundShadow = widget.player.background.hasBackground
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

    var isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    var myIndex = widget.players.indexWhere((x) => widget.player.uuid == x.uuid);

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: isLandscape ? 132.0 : 60.0, vertical: isLandscape ? 60.0 : 132.0),
      titlePadding: const EdgeInsets.only(top: 12.0, left: 18.0, right: 16.0),
      contentPadding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
      title: Row(
        children: [
          const Text("Commander"),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: AspectRatio(
        aspectRatio: isLandscape ? 2 : 1 / 2,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: RotatedBox(
            quarterTurns:
                (widget.layout.rotated ? 2 : 0) + (MediaQuery.of(context).orientation == Orientation.landscape ? 1 : 0),
            child: widget.layout.build(
              context,
              widget.players,
              (i, turns) {
                var player = widget.players[i];

                Widget counter({bool partner = false}) {
                  var card = partner ? player.cardPartner : player.card;
                  var cmdid = partner ? "${player.uuid}_partner" : player.uuid;
                  var dmg = (widget.player.commanderDamage[cmdid] ?? 0);
                  var changedLife = widget.player.damageHistory.isNotEmpty &&
                          widget.player.damageHistory.last.fromCommander == cmdid &&
                          lastChanged == cmdid &&
                          DateTime.now().millisecondsSinceEpoch -
                                  widget.player.damageHistory.last.time.millisecondsSinceEpoch <
                              5000
                      ? widget.player.damageHistory.last.change * -1
                      : 0;

                  return RotatedBox(
                    quarterTurns: Service.settingsService.pref_commanderDamageButtonsFacePlayer
                        ? widget.layout.getTurnsInPosition(myIndex) + -1 * turns
                        : 0,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      margin: const EdgeInsets.all(1.0),
                      child: Stack(
                        children: [
                          if (card != null)
                            CardImage(
                              key: Key(card.uuid),
                              cardSet: card,
                            ),
                          if (!partner && card == null && player.background.hasBackground)
                            BackgroundWidget(
                              background: player.background,
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
                                          shadows: card != null || (!partner && player.background.hasBackground)
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
                          if (changedLife != 0)
                            Positioned.fill(
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 64.0, top: 2.0),
                                  child: Text(
                                    changedLife > 0 ? "+$changedLife" : changedLife.toString(),
                                    style: TextStyle(
                                        shadows: card != null || (!partner && player.background.hasBackground)
                                            ? [
                                                const Shadow(
                                                  offset: Offset(0.5, 0.5),
                                                  blurRadius: 10.0,
                                                  color: Colors.black,
                                                ),
                                              ]
                                            : null),
                                  ),
                                ),
                              ),
                            ),
                          Positioned.fill(
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: TextButton(
                                    style: ButtonStyle(
                                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                        const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                      ),
                                      foregroundColor: WidgetStateProperty.all<Color>(
                                        Theme.of(context).colorScheme.onSurface,
                                      ),
                                      overlayColor: WidgetStateProperty.all<Color>(
                                        Theme.of(context).colorScheme.onSurface.withAlpha(30),
                                      ),
                                    ),
                                    onPressed: () {
                                      changeLife(cmdid, 1);
                                    },
                                    onLongPress: () {
                                      changeLife(cmdid, 10);
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
                                  ),
                                ),
                                Expanded(
                                  flex: Service.settingsService.pref_asymmetricalCommanderDamageButtons ? 2 : 1,
                                  child: TextButton(
                                    style: ButtonStyle(
                                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                        const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                      ),
                                      foregroundColor: WidgetStateProperty.all<Color>(
                                        Theme.of(context).colorScheme.onSurface,
                                      ),
                                      overlayColor: WidgetStateProperty.all<Color>(
                                        Theme.of(context).colorScheme.onSurface.withAlpha(30),
                                      ),
                                    ),
                                    onPressed: () {
                                      changeLife(cmdid, -1);
                                    },
                                    onLongPress: () {
                                      changeLife(cmdid, -10);
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
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Flex(
                        direction: constraints.maxWidth > constraints.maxHeight ? Axis.horizontal : Axis.vertical,
                        children: [
                          Expanded(
                            child: counter(),
                          ),
                          if (player.cardPartner != null)
                            Expanded(
                              child: counter(
                                partner: true,
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
