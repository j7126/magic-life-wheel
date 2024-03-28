import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyrune_icons_flutter/keyrune_icons_flutter.dart';
import 'package:magic_life_wheel/datamodel/player.dart';
import 'package:magic_life_wheel/layouts/layout.dart';
import 'package:magic_life_wheel/service/static_service.dart';
import 'package:magic_life_wheel/widgets/card_image.dart';
import 'package:magic_life_wheel/widgets/commander_damage_dialog.dart';
import 'package:magic_life_wheel/widgets/edit_player_dialog.dart';

class Counter extends StatefulWidget {
  const Counter({
    super.key,
    required this.i,
    required this.layout,
    required this.players,
    this.stateChanged,
  });

  final int i;
  final Layout layout;
  final List<Player> players;
  final VoidCallback? stateChanged;

  Player get player => players[i];

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  Timer? longPressTimer;
  int? longPressDirection;

  int changedLife = 0;
  Timer? lifeChangedTimer;

  bool get showMinusButton => !widget.player.dead;
  bool get showPlusButton => !widget.player.deadByCommander;

  void editPlayer() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => EditPlayerDialog(player: widget.player),
    );
    setState(() {});
    widget.stateChanged?.call();
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
    changedLife += x;
    lifeChangedTimer?.cancel();
    lifeChangedTimer = Timer(
      const Duration(seconds: 5),
      () {
        setState(() {
          changedLife = 0;
        });
        lifeChangedTimer?.cancel();
        lifeChangedTimer = null;
      },
    );
  }

  void handleLongPressInterval(int direction, {int i = 0}) {
    if (direction != -1 && direction != 1) {
      return;
    }

    if ((direction < 0 && !showMinusButton) || (direction > 0 && !showPlusButton)) {
      handleLongPressEnd();
      return;
    }

    HapticFeedback.vibrate();

    setState(() {
      changeLife(direction * 10);
      longPressDirection = direction;
      longPressTimer = Timer(
        Duration(milliseconds: i == 0 ? 650 : 500),
        () => handleLongPressInterval(direction, i: i + 1),
      );
    });
  }

  void handleLongPressEnd() {
    setState(() {
      longPressTimer?.cancel();
      longPressTimer = null;
      longPressDirection = null;
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
                widget.player.getDisplayName(widget.i),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ),
    );

    var commanderButton = IconButton(
      icon: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          KeyruneIcons.ss_cmd,
          size: 28.0,
          shadows: onBackgroundShadow,
        ),
      ),
      onPressed: commanderDamage,
    );

    return Opacity(
      opacity: widget.player.dead ? 0.2 : 1,
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
              if (Service.settingsService.pref_showChangingLife && changedLife != 0)
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 42.0),
                    child: Text(
                      (changedLife > 0 ? "+" : "") + changedLife.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
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
                            widget.player.dead ? "" : widget.player.life.toString(),
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
                      child: GestureDetector(
                        onLongPressStart: (e) => handleLongPressInterval(-1),
                        onLongPressEnd: (e) => handleLongPressEnd(),
                        child: TextButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            ),
                            foregroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).colorScheme.onBackground,
                            ),
                            overlayColor: MaterialStateProperty.all<Color>(
                              longPressDirection == -1 ? Colors.transparent : Theme.of(context).colorScheme.onBackground.withAlpha(30),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                              longPressDirection == -1 ? Theme.of(context).colorScheme.onBackground.withAlpha(30) : Colors.transparent,
                            ),
                          ),
                          onPressed: !showMinusButton ? null : () => changeLife(-1),
                          child: showMinusButton
                              ? SizedBox(
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
                                )
                              : Container(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onLongPressStart: (e) => handleLongPressInterval(1),
                        onLongPressEnd: (e) => handleLongPressEnd(),
                        child: TextButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            ),
                            foregroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).colorScheme.onBackground,
                            ),
                            overlayColor: MaterialStateProperty.all<Color>(
                              longPressDirection == 1 ? Colors.transparent : Theme.of(context).colorScheme.onBackground.withAlpha(30),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                              longPressDirection == 1 ? Theme.of(context).colorScheme.onBackground.withAlpha(30) : Colors.transparent,
                            ),
                          ),
                          onPressed: !showPlusButton ? null : () => changeLife(1),
                          child: showPlusButton
                              ? SizedBox(
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
                                )
                              : Container(),
                        ),
                      ),
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
