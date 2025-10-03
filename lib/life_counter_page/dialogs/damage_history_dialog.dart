import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:magic_life_wheel/datamodel/player.dart';
import 'package:magic_life_wheel/dialog_service.dart';
import 'package:magic_life_wheel/life_counter_page/card_image/background_widget.dart';
import 'package:magic_life_wheel/life_counter_page/card_image/card_image.dart';

class DamageHistoryDialog extends StatefulWidget {
  const DamageHistoryDialog({super.key, required this.player, required this.players});

  final Player player;
  final List<Player> players;

  @override
  State<DamageHistoryDialog> createState() => _DamageHistoryDialogDialog();
}

class _DamageHistoryDialogDialog extends State<DamageHistoryDialog> {
  String timeDiffString(DateTime dt) {
    var diff = DateTime.now().millisecondsSinceEpoch - dt.millisecondsSinceEpoch;
    diff ~/= 1000;
    var s = diff % 60;
    diff ~/= 60;
    var m = diff % 60;
    diff ~/= 60;
    var h = diff % 24;
    diff ~/= 24;
    var d = diff;
    if (d != 0) {
      return "$d d";
    } else if (h != 0) {
      return "$h h";
    } else if (m != 0) {
      return "$m m";
    } else {
      return "$s s";
    }
  }

  @override
  void initState() {
    DialogService.register(context);
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {});
      } else {
        t.cancel();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    DialogService.deregister(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 64.0),
      titlePadding: const EdgeInsets.only(top: 12.0, left: 18.0, right: 16.0),
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          const Text("Damage History"),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: Container(
        constraints: const BoxConstraints(minWidth: 320),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, top: 16.0, left: 12.0, right: 12.0),
                    child: Text(
                      widget.player.dead ? "Dead" : "${widget.player.life} Life",
                      style: const TextStyle(
                        fontSize: 26,
                        height: 1,
                        color: Color.fromARGB(255, 178, 178, 178),
                      ),
                    ),
                  ),
                  if (widget.player.damageHistory.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.player.damageHistory.where((x) => x.change < 0).map((x) => x.change).sum.abs().toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    height: 1,
                                    color: Color.fromARGB(255, 178, 178, 178),
                                  ),
                                ),
                                Text(
                                  "Life Lost",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1,
                                    color: Color.fromARGB(255, 178, 178, 178),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.player.damageHistory.where((x) => x.change > 0).map((x) => x.change).sum.abs().toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    height: 1,
                                    color: Color.fromARGB(255, 178, 178, 178),
                                  ),
                                ),
                                Text(
                                  "Life Gained",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1,
                                    color: Color.fromARGB(255, 178, 178, 178),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.player.damageHistory.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0, top: 12.0),
                      child: Row(
                        children: [
                          const Spacer(),
                          const Icon(
                            Icons.history,
                            size: 34,
                            color: Color.fromARGB(255, 127, 127, 127),
                          ),
                          const Gap(8.0),
                          Text(
                            "No history",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: const Color.fromARGB(255, 127, 127, 127),
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  for (var event in widget.player.damageHistory.reversed) ...[
                    Card(
                      child: SizedBox(
                        height: 80,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 64,
                                height: 64,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Builder(builder: (context) {
                                  Widget? bg;
                                  if (event.fromCommander != null) {
                                    if (event.fromCommander!.endsWith("_partner")) {
                                      var player = widget.players.firstWhereOrNull((x) => "${x.uuid}_partner" == event.fromCommander);
                                      if (player != null && player.cardPartner != null) {
                                        bg = CardImage(
                                          key: Key(player.cardPartner!.uuid),
                                          cardSet: player.cardPartner,
                                        );
                                      }
                                    } else {
                                      var player = widget.players.firstWhereOrNull((x) => x.uuid == event.fromCommander);
                                      if (player != null) {
                                        bg = player.card != null
                                            ? CardImage(
                                                key: Key(player.card!.uuid),
                                                cardSet: player.card,
                                              )
                                            : BackgroundWidget(
                                                background: player.background,
                                              );
                                      }
                                    }
                                  }
                                  return Stack(
                                    children: [
                                      if (bg != null) bg,
                                      SizedBox(
                                        width: 64,
                                        height: 64,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Text(
                                              "${event.change > 0 ? "+" : ""}${event.change.toString()}",
                                              style: TextStyle(
                                                shadows: bg != null
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
                                                    : null,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    event.change > 0
                                        ? "Life Gain"
                                        : event.fromCommander != null
                                            ? "Commander"
                                            : "Damage",
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    timeDiffString(event.time),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Container(
                              height: 2.0,
                              color: (DividerTheme.of(context).color ?? Theme.of(context).colorScheme.outlineVariant).withAlpha(127),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            "${event.priorLife}",
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1,
                              color: Color.fromARGB(255, 153, 153, 153),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Container(
                              height: 2.0,
                              color: (DividerTheme.of(context).color ?? Theme.of(context).colorScheme.outlineVariant).withAlpha(127),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (widget.player.damageHistory.isNotEmpty)
                    Card(
                      child: SizedBox(
                        height: 80,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Icon(Icons.flag),
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Text(
                                "Game Start",
                                style: TextStyle(fontSize: 28),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
