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
  bool isDragging = false;
  List<Player>? oldPlayers;

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
              id: i,
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
    var result = isGameReset ? true : await _showResetWarning();

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // counters
          Expanded(
            child: layout?.build(
                  context,
                  players,
                  (Widget child, int i) {
                    const padding = 16.0;
                    return Stack(
                      children: [
                        AnimatedPadding(
                          padding: EdgeInsets.all(isDragging ? padding : 0),
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.ease,
                          child: child,
                        ),
                        if (isDragging)
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
          // toolbar
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: isDragging
                ? Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        key: const ValueKey("DraggingMenuButton1"),
                        onPressed: () {
                          players = oldPlayers ?? [];
                          oldPlayers = null;
                          setState(() {
                            isDragging = false;
                          });
                        },
                        icon: const Icon(Icons.close),
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      IconButton(
                        key: const ValueKey("DraggingMenuButton2"),
                        onPressed: () {
                          setState(() {
                            isDragging = false;
                          });
                        },
                        icon: const Icon(Icons.done),
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        color: Theme.of(context).colorScheme.onBackground,
                        onPressed: _showResetGameDialog,
                        icon: const Icon(Icons.restart_alt),
                      ),
                      IconButton(
                        onPressed: (Layouts.layoutsBySize[numPlayers]?.length ?? 0) > 1 ? switchLayout : null,
                        icon: layout != null
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: layout?.buildPreview(context),
                              )
                            : const Icon(Icons.grid_view),
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      IconButton(
                        onPressed: () {
                          oldPlayers = List.from(players);
                          setState(() {
                            isDragging = true;
                          });
                        },
                        icon: const Icon(Icons.swap_horiz_outlined),
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      PopupMenuButton<int>(
                        iconColor: Theme.of(context).colorScheme.onBackground,
                        tooltip: "Number of players",
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
                        onSelected: (int players) {
                          _showSwitchPlayersDialog(players);
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                          const PopupMenuItem<int>(
                            value: 2,
                            child: Text('2 Players'),
                          ),
                          const PopupMenuItem<int>(
                            value: 3,
                            child: Text('3 Players'),
                          ),
                          const PopupMenuItem<int>(
                            value: 4,
                            child: Text('4 Players'),
                          ),
                          const PopupMenuItem<int>(
                            value: 5,
                            child: Text('5 Players'),
                          ),
                          const PopupMenuItem<int>(
                            value: 6,
                            child: Text('6 Players'),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
