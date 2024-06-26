import 'dart:math';
import 'package:flutter/material.dart';
import 'package:magic_life_wheel/datamodel/player.dart';
import 'package:magic_life_wheel/layouts/layout.dart';
import 'package:magic_life_wheel/static_service.dart';
import 'package:magic_life_wheel/life_counter_page/card_image/card_image.dart';
import 'package:magic_life_wheel/life_counter_page/card_image/background_widget.dart';

class CommanderDamageGrid extends StatelessWidget {
  const CommanderDamageGrid({
    super.key,
    required this.player,
    required this.layout,
    required this.players,
  });

  final Player player;
  final Layout layout;
  final List<Player> players;

  @override
  Widget build(BuildContext context) {
    var myIndex = players.indexWhere((x) => player.uuid == x.uuid);

    return LayoutBuilder(builder: (context, constraints) {
      var minDimension = min(constraints.maxWidth, constraints.maxHeight);
      return Padding(
        padding: EdgeInsets.all(minDimension * 0.04),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 70, 73, 72),
              border: Border.all(
                color: Colors.black,
                width: minDimension * 0.04,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              borderRadius: BorderRadius.circular(minDimension * 0.2)),
          child: RotatedBox(
            quarterTurns: -1 * layout.getTurnsInPosition(myIndex),
            child: layout.build(
              gap: 0,
              evenFlex: true,
              context,
              players,
              (i, turns) {
                var player = players[i];

                Widget counter({bool partner = false}) {
                  var card = partner ? player.cardPartner : player.card;
                  var cmdid = partner ? (card?.uuid ?? player.uuid) : player.uuid;
                  var dmg = (this.player.commanderDamage[cmdid] ?? 0);

                  return ClipRect(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: RotatedBox(
                      quarterTurns: Service.settingsService.pref_commanderDamageButtonsFacePlayer
                          ? layout.getTurnsInPosition(myIndex) + -1 * turns
                          : 0,
                      child: Stack(
                        children: [
                          if (card != null)
                            CardImage(
                              key: Key(card.uuid),
                              cardSet: card,
                              showLoader: false,
                            ),
                          if (!partner && card == null && player.background.hasBackground)
                            BackgroundWidget(
                              background: player.background,
                              showLoader: false,
                            ),
                          Positioned.fill(
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    dmg.toString(),
                                    overflow: TextOverflow.visible,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily: "mono",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 50,
                                      height: 1,
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
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SizedBox(
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
                );
              },
            ),
          ),
        ),
      );
    });
  }
}
