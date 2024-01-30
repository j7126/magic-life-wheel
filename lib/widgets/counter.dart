import 'package:flutter/material.dart';
import 'package:magic_life_wheel/datamodel/player.dart';
import 'package:magic_life_wheel/widgets/card_image.dart';
import 'package:magic_life_wheel/widgets/edit_player_dialog.dart';

class Counter extends StatefulWidget {
  const Counter({super.key, required this.player, required this.i});

  final int i;
  final Player player;

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

  void changeLife(int x) {
    setState(() {
      widget.player.life += x;
      if (widget.player.life < 0) {
        widget.player.life = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var playerNameBtn = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: editPlayer,
        child: Card(
          color: widget.player.card != null ? const Color.fromARGB(140, 0, 0, 0) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(widget.player.name.isEmpty ? "Player ${widget.i + 1}" : widget.player.name),
          ),
        ),
      ),
    );

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

    return LayoutBuilder(
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
                key: Key(widget.player.card?.name ?? ''),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(),
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
                    child: TextButton(
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
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              child: Center(
                child: Column(
                  children: [
                    playerNameBtn,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
