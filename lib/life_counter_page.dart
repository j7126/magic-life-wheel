import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic_life_wheel/layouts/layout.dart';
import 'package:magic_life_wheel/layouts/layouts.dart';
import 'package:magic_life_wheel/player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class LifeCounterPage extends StatefulWidget {
  const LifeCounterPage({super.key});

  @override
  State<LifeCounterPage> createState() => _LifeCounterPageState();
}

class _LifeCounterPageState extends State<LifeCounterPage> {
  Layout? layout;
  List<Player> players = [];
  int numPlayers = 0;
  int layoutId = 0;
  bool rearrangeMode = false;
  List<Player>? oldPlayers;

  final FocusNode _playersMenuButtonFocusNode = FocusNode();

  bool get isGameReset => !players.any((x) => !x.isGameReset);

  void switchLayout() {
    setState(() {
      var layouts = Layouts.layoutsBySize[numPlayers];
      if (layouts == null) return;
      layoutId++;
      if (layoutId >= layouts.length) layoutId = 0;
      layout = layouts[layoutId];
    });
  }

  void setPlayers(int players) {
    setState(() {
      numPlayers = players;
      layout = null;
      layoutId = 0;
      layout = Layouts.layoutsBySize[numPlayers]?.first;
      setupPlayers();
    });
  }

  void resetGame() {
    setState(() {
      for (var player in players) {
        player.resetGame();
      }
    });
  }

  void setupPlayers() {
    setState(() {
      if (numPlayers > players.length) {
        for (var i = players.length; i < numPlayers; i++) {
          players.add(
            Player(
              name: "",
            ),
          );
        }
      } else {
        var diff = players.length - numPlayers;
        for (var i = 0; i < diff; i++) {
          players.removeLast();
        }
      }

      resetGame();
    });
  }

  Future<bool?> _showResetWarning() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('The life counters will be reset.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  void _showSwitchPlayersDialog(int players) async {
    var result = isGameReset ? true : await _showResetWarning();

    if (result ?? false) setPlayers(players);
  }

  void _showResetGameDialog() async {
    var result = isGameReset ? false : await _showResetWarning();

    if (result ?? false) resetGame();
  }

  @override
  void initState() {
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    setPlayers(3);
    super.initState();
  }

  @override
  void dispose() {
    _playersMenuButtonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var barButtonStyle = ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      foregroundColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          return Theme.of(context).colorScheme.onBackground;
        },
      ),
      overlayColor: MaterialStateProperty.all<Color>(
        Theme.of(context).colorScheme.onBackground.withAlpha(20),
      ),
    );

    return Scaffold(
      body: Column(
        children: [
          // ----- counters -----
          Expanded(
            child: layout?.build(
                  context,
                  players,
                  (Widget child, int i) {
                    const padding = 16.0;
                    return Stack(
                      children: [
                        AnimatedPadding(
                          padding: EdgeInsets.all(rearrangeMode ? padding : 0),
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.ease,
                          child: child,
                        ),
                        if (rearrangeMode)
                          DragTarget<int>(
                            builder: (
                              BuildContext context,
                              List<dynamic> candidateData,
                              List<dynamic> rejectedData,
                            ) {
                              return Stack(
                                children: [
                                  Draggable<int>(
                                    data: i,
                                    dragAnchorStrategy: pointerDragAnchorStrategy,
                                    feedback: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          players[i].name,
                                          style: const TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    childWhenDragging: Padding(
                                      padding: const EdgeInsets.all(padding),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(35),
                                          color: const Color.fromARGB(100, 0, 0, 0),
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(padding),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(35),
                                          color: const Color.fromARGB(0, 0, 0, 0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (candidateData.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(padding),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(35),
                                          color: const Color.fromARGB(45, 48, 150, 63),
                                        ),
                                      ),
                                    )
                                ],
                              );
                            },
                            onAccept: (int data) {
                              setState(() {
                                if (i != data) {
                                  var temp = players[data];
                                  players[data] = players[i];
                                  players[i] = temp;
                                }
                              });
                            },
                            onWillAccept: (int? data) => data != null && i != data,
                          ),
                      ],
                    );
                  },
                ) ??
                Container(),
          ),
          // ----- toolbar -----
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Divider(
              height: 2,
            ),
          ),
          rearrangeMode
              // rearrange toolbar
              ? Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: TextButton(
                        key: const ValueKey("rearrangeCancelButton"),
                        onPressed: () {
                          players = oldPlayers ?? [];
                          oldPlayers = null;
                          setState(() {
                            rearrangeMode = false;
                          });
                        },
                        style: barButtonStyle,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Icon(
                            Icons.close,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        key: const ValueKey("rearrangeShuffleButton"),
                        onPressed: () {
                          setState(() {
                            players.shuffle();
                          });
                        },
                        style: barButtonStyle,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Icon(
                            Icons.shuffle_outlined,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        key: const ValueKey("rearrangeDoneButton"),
                        onPressed: () {
                          setState(() {
                            rearrangeMode = false;
                          });
                        },
                        style: barButtonStyle,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Icon(
                            Icons.done,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              // standard toolbar
              : Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _showResetGameDialog,
                        style: barButtonStyle,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Icon(
                            Icons.restart_alt,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: (Layouts.layoutsBySize[numPlayers]?.length ?? 0) > 1 ? switchLayout : null,
                        style: barButtonStyle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: layout != null
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: layout?.buildPreview(context),
                                )
                              : const Icon(
                                  Icons.grid_view,
                                ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          oldPlayers = List.from(players);
                          setState(() {
                            rearrangeMode = true;
                          });
                        },
                        style: barButtonStyle,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Icon(
                            Icons.swap_horiz_outlined,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: MenuAnchor(
                        childFocusNode: _playersMenuButtonFocusNode,
                        menuChildren: <Widget>[
                          for (int i = 2; i <= 6; i++)
                            MenuItemButton(
                              child: Text('$i Players'),
                              onPressed: () => _showSwitchPlayersDialog(i),
                            ),
                        ],
                        builder: (BuildContext context, MenuController controller, Widget? child) {
                          return TextButton(
                            focusNode: _playersMenuButtonFocusNode,
                            onPressed: () {
                              if (controller.isOpen) {
                                controller.close();
                              } else {
                                controller.open();
                              }
                            },
                            style: barButtonStyle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Center(
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context).iconTheme.color ?? Colors.black,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Center(
                                    child: Text(numPlayers.toString()),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
