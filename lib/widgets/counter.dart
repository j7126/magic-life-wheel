import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyrune_icons_flutter/keyrune_icons_flutter.dart';
import 'package:magic_life_wheel/datamodel/player.dart';
import 'package:magic_life_wheel/layouts/layout.dart';
import 'package:magic_life_wheel/service/counter_font_size_group.dart';
import 'package:magic_life_wheel/service/static_service.dart';
import 'package:magic_life_wheel/widgets/animated_fade.dart';
import 'package:magic_life_wheel/dialogs/commander_damage_dialog.dart';
import 'package:magic_life_wheel/widgets/background_widget.dart';
import 'package:magic_life_wheel/dialogs/edit_player_dialog.dart';

class Counter extends StatefulWidget {
  const Counter({
    super.key,
    required this.i,
    required this.layout,
    required this.players,
    required this.counterFontSizeGroup,
    this.triggerReRender,
    this.stateChanged,
    this.highlighted = false,
    this.highlightedInstant = false,
  });

  final int i;
  final Layout layout;
  final List<Player> players;
  final CounterFontSizeGroup counterFontSizeGroup;
  final VoidCallback? triggerReRender;
  final VoidCallback? stateChanged;
  final bool highlighted;
  final bool highlightedInstant;

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
    widget.stateChanged?.call();
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
    widget.stateChanged?.call();
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
  void dispose() {
    lifeChangedTimer?.cancel();
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

    var playerNameBtn = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: editPlayer,
          child: Card(
            color: widget.player.background.hasBackground ? const Color.fromARGB(140, 0, 0, 0) : null,
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
        builder: (context, constraints) {
          var fontSize = max(
            min(
              min(
                constraints.maxHeight - 112.0,
                (constraints.maxWidth - 144.0) * 0.9,
              ),
              128.0,
            ),
            1.0,
          );
          var before = widget.counterFontSizeGroup.minSize;
          widget.counterFontSizeGroup.setSize(widget.i, fontSize);
          if (widget.triggerReRender != null && before != widget.counterFontSizeGroup.minSize) {
            widget.triggerReRender!();
          }

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              color: const Color.fromARGB(50, 255, 255, 255),
            ),
            clipBehavior: Clip.antiAlias,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              children: [
                BackgroundWidget(
                  background: widget.player.background,
                ),
                if (Service.settingsService.pref_showChangingLife && changedLife != 0)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 42.0),
                      child: Text(
                        (changedLife > 0 ? "+" : "") + changedLife.toString(),
                        style: TextStyle(fontSize: 16, shadows: onBackgroundShadow),
                      ),
                    ),
                  ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 32,
                      bottom: Service.settingsService.pref_enableCommanderDamage ? 32 : 16,
                      left: 72.0,
                      right: 72.0,
                    ),
                    child: Center(
                      child: FittedBox(
                        child: Text(
                          widget.player.dead ? "" : widget.player.life.toString(),
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: Service.settingsService.pref_maximiseFontSize
                                ? min(
                                    constraints.maxHeight,
                                    constraints.maxWidth,
                                  )
                                : widget.counterFontSizeGroup.minSize,
                            shadows: onBackgroundShadow,
                          ),
                        ),
                      ),
                    ),
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
                                longPressDirection == -1
                                    ? Colors.transparent
                                    : Theme.of(context).colorScheme.onBackground.withAlpha(30),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                longPressDirection == -1
                                    ? Theme.of(context).colorScheme.onBackground.withAlpha(30)
                                    : Colors.transparent,
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
                                longPressDirection == 1
                                    ? Colors.transparent
                                    : Theme.of(context).colorScheme.onBackground.withAlpha(30),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                longPressDirection == 1
                                    ? Theme.of(context).colorScheme.onBackground.withAlpha(30)
                                    : Colors.transparent,
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
                IgnorePointer(
                  child: AnimatedFade(
                    reverseDuration: const Duration(seconds: 2),
                    visible: widget.highlighted,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        border: Border.all(
                          color: Colors.white,
                          width: 8.0,
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.highlightedInstant)
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        border: Border.all(
                          color: Colors.white,
                          width: 4.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
