import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyrune_icons_flutter/keyrune_icons_flutter.dart';
import 'package:magic_life_wheel/datamodel/player.dart';
import 'package:magic_life_wheel/layouts/layout.dart';
import 'package:magic_life_wheel/life_counter_page/counter/commander_damage_grid.dart';
import 'package:magic_life_wheel/life_counter_page/counter/counter_font_size_group.dart';
import 'package:magic_life_wheel/static_service.dart';
import 'package:magic_life_wheel/widgets/animated_fade.dart';
import 'package:magic_life_wheel/life_counter_page/dialogs/commander_damage_dialog.dart';
import 'package:magic_life_wheel/life_counter_page/card_image/background_widget.dart';
import 'package:magic_life_wheel/life_counter_page/dialogs/edit_player/edit_player_dialog.dart';

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

  int get changedLife => widget.player.damageHistory.isNotEmpty &&
          widget.player.damageHistory.last.fromCommander == null &&
          DateTime.now().millisecondsSinceEpoch - widget.player.damageHistory.last.time.millisecondsSinceEpoch < 5000
      ? widget.player.damageHistory.last.change
      : 0;
  Timer? lifeChangedTimer;

  bool get showMinusButton => !widget.player.dead;
  bool get showPlusButton => !widget.player.deadByCommander;

  void editPlayer() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => EditPlayerDialog(
        player: widget.player,
        players: widget.players,
      ),
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
    lifeChangedTimer?.cancel();
    lifeChangedTimer = Timer(
      const Duration(milliseconds: 5001),
      () {
        setState(() {});
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
      longPressTimer?.cancel();
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
    longPressTimer?.cancel();
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
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
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

    var commanderButton = Service.settingsService.pref_commanderDamageMiniGrid
        ? GestureDetector(
            onTap: commanderDamage,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: SizedBox(
                width: 72,
                height: 66,
                child: CommanderDamageGrid(
                  player: widget.player,
                  layout: widget.layout,
                  players: widget.players,
                ),
              ),
            ),
          )
        : IconButton(
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
                constraints.maxHeight -
                    (Service.settingsService.pref_enableCommanderDamage
                        ? Service.settingsService.pref_commanderDamageMiniGrid
                            ? 102
                            : 82
                        : 20),
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
              color: const Color.fromARGB(255, 50, 50, 50),
            ),
            clipBehavior: Clip.antiAlias,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              children: [
                BackgroundWidget(
                  background: widget.player.background,
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: widget.player.dead ? 0 : 1,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: Service.settingsService.pref_enableCommanderDamage &&
                                Service.settingsService.pref_commanderDamageMiniGrid
                            ? 16
                            : 32,
                        bottom: Service.settingsService.pref_enableCommanderDamage
                            ? Service.settingsService.pref_commanderDamageMiniGrid
                                ? 48
                                : 32
                            : 16,
                        left: 72.0,
                        right: 72.0,
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: Service.settingsService.pref_maximiseFontSize ? BoxFit.contain : BoxFit.none,
                          child: Text(
                            widget.player.life.toString(),
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
                              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                              ),
                              foregroundColor: WidgetStateProperty.all<Color>(
                                Theme.of(context).colorScheme.onSurface,
                              ),
                              iconColor: WidgetStateProperty.all<Color>(
                                Theme.of(context).colorScheme.onSurface,
                              ),
                              overlayColor: WidgetStateProperty.all<Color>(
                                longPressDirection == -1
                                    ? Colors.transparent
                                    : Theme.of(context).colorScheme.onSurface.withAlpha(30),
                              ),
                              backgroundColor: WidgetStateProperty.all<Color>(
                                longPressDirection == -1
                                    ? Theme.of(context).colorScheme.onSurface.withAlpha(30)
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
                              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                              ),
                              foregroundColor: WidgetStateProperty.all<Color>(
                                Theme.of(context).colorScheme.onSurface,
                              ),
                              iconColor: WidgetStateProperty.all<Color>(
                                Theme.of(context).colorScheme.onSurface,
                              ),
                              overlayColor: WidgetStateProperty.all<Color>(
                                longPressDirection == 1
                                    ? Colors.transparent
                                    : Theme.of(context).colorScheme.onSurface.withAlpha(30),
                              ),
                              backgroundColor: WidgetStateProperty.all<Color>(
                                longPressDirection == 1
                                    ? Theme.of(context).colorScheme.onSurface.withAlpha(30)
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Service.settingsService.pref_showChangingLife && changedLife < 0
                              ? Container(
                                  constraints: const BoxConstraints(minWidth: 38),
                                  child: Text(
                                    changedLife.toString(),
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      shadows: onBackgroundShadow,
                                    ),
                                    maxLines: 1,
                                  ),
                                )
                              : const SizedBox(width: 38, height: 0),
                          Flexible(
                            fit: FlexFit.loose,
                            child: playerNameBtn,
                          ),
                          Service.settingsService.pref_showChangingLife && changedLife > 0
                              ? Container(
                                  constraints: const BoxConstraints(minWidth: 38),
                                  child: Text(
                                    "+$changedLife",
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      shadows: onBackgroundShadow,
                                    ),
                                    maxLines: 1,
                                  ),
                                )
                              : const SizedBox(width: 38, height: 0),
                        ],
                      );
                    }),
                  ),
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
