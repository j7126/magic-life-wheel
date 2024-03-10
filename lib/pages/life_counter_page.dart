import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:magic_life_wheel/layouts/layout.dart';
import 'package:magic_life_wheel/layouts/layout_2a.dart';
import 'package:magic_life_wheel/layouts/layouts.dart';
import 'package:magic_life_wheel/pages/about_page.dart';
import 'package:magic_life_wheel/datamodel/player.dart';
import 'package:magic_life_wheel/pages/settings_page.dart';
import 'package:magic_life_wheel/service/static_service.dart';
import 'package:magic_life_wheel/widgets/card_image.dart';
import 'package:magic_life_wheel/widgets/counter.dart';
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
  bool rotated = false;
  double rotatedAnimate = 0.0;

  final FocusNode _menuButtonFocusNode = FocusNode();

  bool get isGameReset => !players.any((x) => !x.isGameReset);

  void save() {
    Service.settingsService.conf_layout = layoutId;
    Service.settingsService.conf_players = players.map((e) => jsonEncode(e)).toList();
  }

  void switchLayout() {
    setState(() {
      rotated = false;
      var layouts = Layouts.layoutsBySize[numPlayers];
      if (layouts == null) return;
      layoutId++;
      if (layoutId >= layouts.length) layoutId = 0;
      layout = layouts[layoutId];
      save();
    });
  }

  void switchRotated() {
    setState(() {
      rotated = !rotated;
      rotatedAnimate += rotated ? 0.5 : -0.5;
    });
  }

  void setPlayers(int players, {int layoutId = 0}) {
    setState(() {
      numPlayers = players;
      layout = null;
      this.layoutId = layoutId;
      var layouts = Layouts.layoutsBySize[numPlayers];
      if (layouts != null) {
        if (layouts.length <= this.layoutId) {
          this.layoutId = 0;
        }
        layout = layouts[this.layoutId];
      }
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

      save();
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

  Future _showSwitchPlayersDialog(int players) async {
    var result = isGameReset ? true : await _showResetWarning();

    if (result ?? false) setPlayers(players);
  }

  void _showResetGameDialog() async {
    var result = isGameReset ? false : await _showResetWarning();

    if (result ?? false) resetGame();
  }

  void _showLayoutSelector() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    "Players",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SegmentedButton<int>(
                  segments: <ButtonSegment<int>>[
                    for (int i = 2; i <= 6; i++)
                      ButtonSegment<int>(
                        value: i,
                        label: Text(i.toString()),
                      ),
                  ],
                  selected: {numPlayers},
                  onSelectionChanged: (Set<int> newSelection) async {
                    await _showSwitchPlayersDialog(newSelection.first);
                    setState(() {});
                  },
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 4.0, top: 16.0),
                  child: Text(
                    "Layout",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                if (Layouts.layoutsBySize[numPlayers] != null)
                  SegmentedButton<String>(
                    segments: <ButtonSegment<String>>[
                      for (Layout l in Layouts.layoutsBySize[numPlayers] ?? [])
                        ButtonSegment<String>(
                          value: l.runtimeType.toString(),
                          label: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 48,
                              width: 48,
                              child: RotatedBox(
                                quarterTurns: rotated && l.runtimeType == layout.runtimeType ? 2 : 0,
                                child: l.buildPreview(context),
                              ),
                            ),
                          ),
                        ),
                    ],
                    selected: {layout.runtimeType.toString()},
                    onSelectionChanged: (Set<String> newSelection) async {
                      setState(() {
                        switchLayout();
                      });
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: FilledButton(
                    onPressed: !(layout?.symetrical ?? true)
                        ? () {
                            setState(() {
                              switchRotated();
                            });
                          }
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedRotation(
                          turns: rotatedAnimate,
                          duration: const Duration(milliseconds: 250),
                          child: const Icon(Icons.screen_rotation_alt_outlined),
                        ),
                        const Gap(8),
                        const Text("Rotate"),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: OutlinedButton(
                    child: const Text('Done'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  void initState() {
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    if (Service.settingsService.conf_players.length < 2 || Service.settingsService.conf_players.length > 6) {
      setPlayers(3);
    } else {
      for (var playerString in Service.settingsService.conf_players) {
        var player = Player.fromJson(jsonDecode(playerString));
        players.add(player);
      }
      setPlayers(players.length, layoutId: Service.settingsService.conf_layout);
    }
    super.initState();
  }

  @override
  void dispose() {
    _menuButtonFocusNode.dispose();
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
      body: SafeArea(
        child: Column(
          children: [
            // ----- counters -----
            Expanded(
              child: RotatedBox(
                quarterTurns: rotated ? 2 : 0,
                child: layout?.build(
                      context,
                      players,
                      (int i) {
                        const padding = 16.0;
                        return Stack(
                          children: [
                            AnimatedPadding(
                              padding: EdgeInsets.all(rearrangeMode ? padding : 0),
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.ease,
                              child: Counter(
                                i: i,
                                layout: layout ?? Layout2a(),
                                players: players,
                                stateChanged: () => save(),
                              ),
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
                                        dragAnchorStrategy: (d, c, o) => const Offset(50, 50),
                                        feedback: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: SizedBox(
                                            width: 100,
                                            height: 100,
                                            child: CardImage(
                                              key: Key(players[i].card?.uuid ?? ''),
                                              cardSet: players[i].card,
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
                                onAcceptWithDetails: (DragTargetDetails<int> details) {
                                  var data = details.data;
                                  setState(() {
                                    if (i != data) {
                                      var temp = players[data];
                                      players[data] = players[i];
                                      players[i] = temp;
                                    }
                                  });
                                },
                                onWillAcceptWithDetails: (DragTargetDetails<int?> details) => details.data != null && i != details.data,
                              ),
                          ],
                        );
                      },
                    ) ??
                    Container(),
              ),
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
                              save();
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
                        child: MenuAnchor(
                          childFocusNode: _menuButtonFocusNode,
                          style: const MenuStyle(
                            visualDensity: VisualDensity.comfortable,
                          ),
                          menuChildren: <Widget>[
                            MenuItemButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const AboutPage(),
                                  ),
                                );
                              },
                              leadingIcon: const Icon(Icons.info_outline),
                              child: const Text("About"),
                            ),
                            MenuItemButton(
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const SettingsPage(),
                                  ),
                                );
                                setState(() {});
                              },
                              leadingIcon: const Icon(Icons.settings),
                              child: const Text("Settings"),
                            ),
                            MenuItemButton(
                              onPressed: _showResetGameDialog,
                              leadingIcon: const Icon(Icons.restart_alt),
                              child: const Text("Reset Game"),
                            ),
                          ],
                          builder: (BuildContext context, MenuController controller, Widget? child) {
                            return TextButton(
                              focusNode: _menuButtonFocusNode,
                              onPressed: () {
                                if (controller.isOpen) {
                                  controller.close();
                                } else {
                                  controller.open();
                                }
                              },
                              style: barButtonStyle,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Icon(
                                  Icons.more_vert,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: _showLayoutSelector,
                          style: barButtonStyle,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: layout != null
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: RotatedBox(
                                      quarterTurns: rotated ? 2 : 0,
                                      child: layout?.buildPreview(context),
                                    ),
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
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
