import 'package:flutter/material.dart';
import 'package:keyrune_icons_flutter/keyrune_icons_flutter.dart';
import 'package:magic_life_wheel/datamodel/player.dart';
import 'package:magic_life_wheel/layouts/layout.dart';
import 'package:magic_life_wheel/service/static_service.dart';
import 'package:magic_life_wheel/widgets/card_image.dart';
import 'package:magic_life_wheel/widgets/commander_damage_dialog.dart';
import 'package:magic_life_wheel/widgets/edit_player_dialog.dart';

class Counter extends StatefulWidget {
  const Counter({super.key, required this.i, required this.layout, required this.players});

  final int i;
  final Layout layout;
  final List<Player> players;

  Player get player => players[i];

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  void editPlayerBackground() {}

  void editPlayer() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => EditPlayerDialog(player: widget.player),
    );
    setState(() {});
  }

  void commanderDamage() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => CommanderDamageDialog(
        player: widget.player,
        layout: widget.layout,
        players: widget.players,
      ),
    );
    setState(() {});
  }

  void changeLife(int x) {
    setState(() {
      widget.player.deal(x);
    });
  }

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

    var playerNameBtn = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: editPlayer,
          child: Card(
            color: widget.player.card != null ? const Color.fromARGB(140, 0, 0, 0) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                widget.player.name.isEmpty ? widget.player.card?.name ?? "Player ${widget.i + 1}" : widget.player.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ),
    );

    var commanderButton = Padding(
      padding: const EdgeInsets.all(8.0),
      child: IconButton(
        icon: Icon(
          KeyruneIcons.ss_cmd,
          size: 28.0,
          shadows: onBackgroundShadow,
        ),
        onPressed: commanderDamage,
      ),
    );

    return Opacity(
      opacity: widget.player.life <= 0 ? 0.2 : 1,
      child: LayoutBuilder(
        builder: (context, constraints) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            color: const Color.fromARGB(50, 255, 255, 255),
          ),
          clipBehavior: Clip.antiAlias,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            children: [
              if (widget.player.card != null)
                CardImage(
                  key: Key(widget.player.card?.uuid ?? ''),
                  cardSet: widget.player.card,
                ),
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Opacity(
                      opacity: 0,
                      child: playerNameBtn,
                    ),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            widget.player.life.toString(),
                            style: TextStyle(
                              shadows: widget.player.card != null
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
                    Container(
                      height: Service.settingsService.pref_enableCommanderDamage ? 32 : 16,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                              onPressed: () => changeLife(-1),
                              onLongPress: () => changeLife(-10),
                              child: SizedBox(
                                height: double.infinity,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Icon(
                                        Icons.remove,
                                        shadows: onBackgroundShadow,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                    ),
                    Expanded(
                      child: !widget.player.deadByCommander
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
                              onPressed: () => changeLife(1),
                              onLongPress: () => changeLife(10),
                              child: SizedBox(
                                height: double.infinity,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Icon(
                                        Icons.add,
                                        shadows: onBackgroundShadow,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: playerNameBtn,
              ),
              if (Service.settingsService.pref_enableCommanderDamage)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: commanderButton,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
