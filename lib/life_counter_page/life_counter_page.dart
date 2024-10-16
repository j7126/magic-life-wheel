import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:gap/gap.dart';
import 'package:magic_life_wheel/dialog_service.dart';
import 'package:magic_life_wheel/dialogs/message_dialog.dart';
import 'package:magic_life_wheel/dialogs/warning_dialog.dart';
import 'package:magic_life_wheel/life_counter_page/dialogs/planar_dice_dialog.dart';
import 'package:magic_life_wheel/transfer_game/transfer_game_page.dart';
import 'package:magic_life_wheel/layouts/layout.dart';
import 'package:magic_life_wheel/layouts/layout_2a.dart';
import 'package:magic_life_wheel/layouts/layouts.dart';
import 'package:magic_life_wheel/about/about_page.dart';
import 'package:magic_life_wheel/datamodel/player.dart';
import 'package:magic_life_wheel/settings/settings_page.dart';
import 'package:magic_life_wheel/life_counter_page/counter/counter_font_size_group.dart';
import 'package:magic_life_wheel/static_service.dart';
import 'package:magic_life_wheel/life_counter_page/card_image/background_widget.dart';
import 'package:magic_life_wheel/life_counter_page/counter/counter.dart';
import 'package:magic_life_wheel/life_counter_page/dialogs/planechase_dialog.dart';
import 'package:magic_life_wheel/transfer_game/transfer_url_service.dart';
import 'package:mana_icons_flutter/mana_icons_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class LifeCounterPage extends StatefulWidget {
  const LifeCounterPage({
    super.key,
    this.waitingUri,
    this.onUriConsumed,
  });

  final String? waitingUri;
  final Function()? onUriConsumed;

  @override
  State<LifeCounterPage> createState() => _LifeCounterPageState();
}

class _LifeCounterPageState extends State<LifeCounterPage> with FullScreenListener {
  Layout? layout;
  List<Player> players = [];
  int numPlayers = 0;
  int layoutId = 0;
  double rotatedAnimate = 0.0;
  int? highlightedPlayer;
  int highlightedPlayerKey = 0;
  int? highlightedPlayerAnimation;
  bool randomPlayerAnimationInProgress = false;
  CounterFontSizeGroup counterFontSizeGroup = CounterFontSizeGroup();
  String? waitingUri;
  bool processingImport = false;

  bool triggerReRender = false;
  bool isFullScreen = false;
  bool isFullScreenForced = false;

  List<Player>? oldPlayers;
  int dragging = 0;
  bool _rearrangeMode = false;
  bool get rearrangeMode => _rearrangeMode;
  set rearrangeMode(bool val) {
    _rearrangeMode = val;
    if (val) {
      dragging = 0;
    }
  }

  bool get rotated => layout?.rotated ?? false;
  set rotated(bool val) => layout?.rotated = val;

  bool get isGameReset => !players.any((x) => !x.isGameReset);

  bool get isPlayersReset => !players.any((x) => !x.isReset);

  void save() async {
    await Future.delayed(const Duration(milliseconds: 200));
    Service.settingsService.conf_layout = layoutId;
    Service.settingsService.conf_players = await compute(
      (p) => p.map((e) => jsonEncode(e)).toList(),
      players,
    );
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

  void setPlayers(int players, {int layoutId = 0, bool reset = true}) {
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
      setupPlayers(reset: reset);
    });
  }

  void resetGame() {
    setState(() {
      for (var player in players) {
        player.resetGame();
      }
      save();
    });
  }

  void resetPlayers() {
    setState(() {
      players.clear();
      setupPlayers();
    });
  }

  void setupPlayers({bool reset = true}) {
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

      if (reset) {
        resetGame();
      }

      save();
    });
  }

  void deletePlayer(int i) {
    if (numPlayers > 2) {
      setState(() {
        players.removeAt(i);
        numPlayers = players.length;
        var layouts = Layouts.layoutsBySize[numPlayers]!;
        if (layouts.length <= layoutId) {
          layoutId = 0;
        }
        layout = layouts[layoutId];
      });
    }
  }

  void _showReset() async {
    var result = await showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return const WarningDialog(
          message: 'The life counters will be reset',
          confirmMessage: 'Reset',
          secondaryMessage: 'Reset Players',
        );
      },
    );
    if (result == null) return null;
    if (result < 0) _showResetPlayers();
    if (result == 1) resetGame();
  }

  void _showResetPlayers() async {
    var result = await showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return const WarningDialog(
          message: 'The player configuration will be reset!',
          confirmMessage: 'Reset',
        );
      },
    );
    if (result == 1) resetPlayers();
  }

  Future _showSwitchPlayersDialog(int players) async {
    var result = isGameReset ||
        (1 ==
            await showDialog<int>(
              context: context,
              barrierDismissible: true,
              builder: (context) {
                return const WarningDialog(
                  message: 'The life counters will be reset',
                  confirmMessage: 'Reset',
                );
              },
            ));

    if (result) setPlayers(players);
  }

  void _showPlanechase() {
    showDialog(
      context: context,
      // ignore: prefer_const_constructors
      builder: (BuildContext context) => PlanechaseDialog(),
    );
  }

  void _showTransferGamePage() async {
    var result = await Navigator.of(context).push<(List<Player> players, int layoutId)>(
      MaterialPageRoute(
        builder: (context) => TransferGamePage(
          players: players,
          layoutId: layoutId,
        ),
      ),
    );
    if (result != null) {
      importGame(result.$1, result.$2);
    }
  }

  void _chooseRandomPlayer() async {
    randomPlayerAnimationInProgress = true;
    var key = DateTime.now().millisecondsSinceEpoch;
    highlightedPlayerKey = key;
    highlightedPlayer = null;
    var player = key % players.length;

    for (var i = -2 * players.length; i < 0; i++) {
      setState(() {
        highlightedPlayerAnimation = (player + i) % players.length;
      });
      await Future.delayed(
        Duration(
          milliseconds: (((2 * players.length + i + 1) / (2 * players.length)) * 400).round(),
        ),
      );
    }

    setState(() {
      highlightedPlayerAnimation = null;
      highlightedPlayer = player;
      randomPlayerAnimationInProgress = false;
    });

    await Future.delayed(const Duration(seconds: 10));

    if (highlightedPlayerKey == key) {
      setState(() {
        highlightedPlayer = null;
      });
    }
  }

  void _showLayoutSelector(int layoutRotationOffset) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
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
                                quarterTurns:
                                    (rotated && l.runtimeType == layout.runtimeType ? 2 : 0) + layoutRotationOffset,
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
                    onPressed: () {
                      setState(() {
                        switchRotated();
                      });
                    },
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

  void _showMenu() {
    var menuButtonStyle = ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          return Theme.of(context).colorScheme.onSurface;
        },
      ),
      overlayColor: WidgetStateProperty.all<Color>(
        Theme.of(context).colorScheme.onSurface.withAlpha(20),
      ),
    );

    var items = [
      (
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AboutPage(),
            ),
          );
        },
        Icons.info_outline,
        "About",
      ),
      (
        () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SettingsPage(),
            ),
          );
          setState(() {});
        },
        Icons.settings,
        "Settings",
      ),
      (
        _showTransferGamePage,
        Icons.send,
        "Transfer Game",
      ),
      (
        _showReset,
        Icons.restart_alt,
        "Reset Game",
      ),
      (
        randomPlayerAnimationInProgress ? null : _chooseRandomPlayer,
        Icons.shuffle,
        "Randomise player",
      ),
    ];

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var item in items)
                TextButton(
                  onPressed: item.$1 == null
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          item.$1!();
                        },
                  style: menuButtonStyle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
                    child: Row(
                      children: [
                        Icon(item.$2),
                        const Gap(8.0),
                        Text(item.$3),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void importGame(List<Player> players, int layoutId) {
    this.players = players;
    setPlayers(
      this.players.length,
      layoutId: layoutId,
      reset: false,
    );
  }

  Future<bool> _showImportWarning(int numPlayers) async {
    return 1 ==
        await showDialog<int>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return WarningDialog(
              message: 'Do you want to import this $numPlayers player game? Your current game will be lost!',
              confirmMessage: 'Import',
            );
          },
        );
  }

  void handleWaitingUri() async {
    setState(() {
      processingImport = true;
    });
    var url = waitingUri;
    if (url == null || !url.startsWith(Service.appBaseUrl)) {
      dataError();
      setState(() {
        processingImport = false;
      });
      return;
    }
    var result = await TransferUrlService.parseUrl(url);
    if (result == null) {
      dataError();
    } else {
      if (isPlayersReset || await _showImportWarning(result.$1.length)) {
        if (mounted) {
          await DialogService.closeAllDialogs();
          importGame(result.$1, result.$2);
        }
      }
    }
    setState(() {
      processingImport = false;
    });
  }

  void dataError() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return const MessageDialog(title: 'The link data was not valid.');
        },
      );
    }
  }

  @override
  void initState() {
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    FullScreen.addListener(this);
    isFullScreen = FullScreen.isFullScreen;
    isFullScreenForced = FullScreen.isFullScreenForced;
    if (Service.settingsService.conf_players.length < 2 || Service.settingsService.conf_players.length > 6) {
      setPlayers(3);
    } else {
      for (var playerString in Service.settingsService.conf_players) {
        Player player;
        try {
          player = Player.fromJson(jsonDecode(playerString));
        } catch (_) {
          player = Player(
            name: "",
          );
        }
        players.add(player);
      }
      setPlayers(
        players.length,
        layoutId: Service.settingsService.conf_layout,
        reset: false,
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    FullScreen.removeListener(this);
    super.dispose();
  }

  @override
  void onFullScreenChanged(bool enabled, SystemUiMode? _) {
    setState(() {
      isFullScreen = enabled;
    });
  }

  @override
  void onFullScreenForcedChanged(bool forced) {
    setState(() {
      isFullScreenForced = forced;
    });
  }

  @override
  Widget build(BuildContext context) {
    counterFontSizeGroup.setNumPlayers(players.length);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (triggerReRender) {
        triggerReRender = false;
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Service.dataLoader.loaded) {
        if (widget.waitingUri != waitingUri) {
          waitingUri = widget.waitingUri;
          if (widget.waitingUri != null) {
            widget.onUriConsumed?.call();
            handleWaitingUri();
          }
        }
      }
    });

    var barButtonStyle = ButtonStyle(
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          return Theme.of(context).colorScheme.onSurface;
        },
      ),
      overlayColor: WidgetStateProperty.all<Color>(
        Theme.of(context).colorScheme.onSurface.withAlpha(20),
      ),
    );

    var layoutRotationOffset = (MediaQuery.of(context).orientation == Orientation.landscape ? 1 : 0);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ----- counters -----
                Expanded(
                  child: AnimatedPadding(
                    padding: EdgeInsets.all(rearrangeMode ? 8 : 0),
                    duration: const Duration(milliseconds: 200),
                    child: RotatedBox(
                      quarterTurns: (rotated ? 2 : 0) + layoutRotationOffset,
                      child: layout?.build(
                            context,
                            players,
                            (int i, _) {
                              const padding = 16.0;
                              return Stack(
                                children: [
                                  AnimatedPadding(
                                    padding: EdgeInsets.all(rearrangeMode ? padding : 0),
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.ease,
                                    child: Counter(
                                      key: ValueKey(players[i].uuid),
                                      i: i,
                                      layout: layout ?? Layout2a(),
                                      players: players,
                                      counterFontSizeGroup: counterFontSizeGroup,
                                      triggerReRender: () {
                                        triggerReRender = true;
                                      },
                                      stateChanged: () => save(),
                                      highlighted: highlightedPlayer == i,
                                      highlightedInstant: highlightedPlayerAnimation == i,
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
                                              maxSimultaneousDrags: 1,
                                              onDragStarted: () {
                                                setState(() {
                                                  dragging++;
                                                });
                                              },
                                              onDragEnd: (_) {
                                                setState(() {
                                                  dragging--;
                                                });
                                              },
                                              feedback: Card(
                                                clipBehavior: Clip.antiAlias,
                                                child: SizedBox(
                                                  width: 100,
                                                  height: 100,
                                                  child: BackgroundWidget(
                                                    background: players[i].background,
                                                    forceShowNoImageIcon: true,
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
                                      onWillAcceptWithDetails: (DragTargetDetails<int?> details) =>
                                          details.data != null && i != details.data,
                                    ),
                                ],
                              );
                            },
                          ) ??
                          Container(),
                    ),
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
                    ? Stack(
                        children: [
                          // non dragging
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: TextButton(
                                  key: const ValueKey("rearrangeCancelButton"),
                                  onPressed: dragging > 0
                                      ? null
                                      : () {
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
                                  onPressed: dragging > 0
                                      ? null
                                      : () {
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
                                  onPressed: dragging > 0
                                      ? null
                                      : () {
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
                          ),
                          // draging
                          if (dragging > 0 && numPlayers > 2)
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Spacer(),
                                DragTarget<int>(
                                  builder: (
                                    BuildContext context,
                                    List<dynamic> candidateData,
                                    List<dynamic> rejectedData,
                                  ) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: candidateData.isNotEmpty ? Colors.redAccent : Colors.red,
                                          borderRadius: BorderRadius.circular(32.0),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete_outline,
                                                size: 20.0,
                                              ),
                                              Gap(8.0),
                                              Text(
                                                "Remove Player",
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  height: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  onAcceptWithDetails: (DragTargetDetails<int> details) {
                                    var data = details.data;
                                    deletePlayer(data);
                                  },
                                  onWillAcceptWithDetails: (DragTargetDetails<int?> details) => details.data != null,
                                ),
                                const Spacer(),
                              ],
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
                              onPressed: () => _showMenu(),
                              style: barButtonStyle,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Icon(
                                  Icons.more_vert,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () => _showLayoutSelector(layoutRotationOffset),
                              style: barButtonStyle,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: layout != null
                                    ? SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: RotatedBox(
                                          quarterTurns: (rotated ? 2 : 0) + layoutRotationOffset,
                                          child: layout?.buildPreview(context),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.grid_view,
                                      ),
                              ),
                            ),
                          ),
                          if (Service.settingsService.pref_enablePlanechase)
                            Expanded(
                              child: TextButton(
                                onPressed: _showPlanechase,
                                onLongPress: () async {
                                  if (PlanechaseDialog.planechasePlane != null) {
                                    var result = await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) => const PlanarDiceDialog(),
                                    );
                                    if (result == true) {
                                      PlanechaseDialog.planeForward();
                                      _showPlanechase();
                                    }
                                  } else {
                                    _showPlanechase();
                                  }
                                },
                                style: barButtonStyle,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Transform.scale(
                                    scale: 1.2,
                                    alignment: Alignment.bottomCenter,
                                    child: const Icon(
                                      ManaIcons.ms_planeswalker,
                                      size: 24,
                                    ),
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
                          if (Service.supportFullScreenButton)
                            IconButton(
                              onPressed: !isFullScreenForced
                                  ? () {
                                      FullScreen.setFullScreen(!isFullScreen);
                                    }
                                  : null,
                              icon: Icon(
                                (isFullScreen || isFullScreenForced) ? Icons.fullscreen_exit : Icons.fullscreen,
                              ),
                            ),
                        ],
                      ),
              ],
            ),
            if ((widget.waitingUri != null && widget.waitingUri != waitingUri) || processingImport)
              Container(
                color: const Color.fromARGB(75, 0, 0, 0),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
