import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:gap/gap.dart';
import 'package:magic_life_wheel/card_search_page/card_search_page.dart';
import 'package:magic_life_wheel/datamodel/game.dart';
import 'package:magic_life_wheel/dialog_service.dart';
import 'package:magic_life_wheel/dialogs/message_dialog.dart';
import 'package:magic_life_wheel/dialogs/warning_dialog.dart';
import 'package:magic_life_wheel/life_counter_page/dialogs/planar_dice_dialog.dart';
import 'package:magic_life_wheel/transfer_game/transfer_game_page.dart';
import 'package:magic_life_wheel/layouts/layout.dart';
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
  late Game game;

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

  void switchLayout() {
    setState(() {
      game.switchLayout();
    });
  }

  void switchRotated() {
    setState(() {
      game.rotated = !game.rotated;
      rotatedAnimate += game.rotated ? 0.5 : -0.5;
    });
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
    if (result == 1) {
      setState(() {
        game.resetGame();
      });
    }
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
    if (result == 1) {
      setState(() {
        game.resetPlayers();
      });
    }
  }

  Future _showSwitchPlayersDialog(int players) async {
    var result = game.isGameReset ||
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

    if (result) {
      setState(() {
        game.setPlayers(players);
      });
    }
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
        builder: (context) => TransferGamePage(game: game),
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
    var player = key % game.players.length;

    for (var i = -2 * game.players.length; i < 0; i++) {
      setState(() {
        highlightedPlayerAnimation = (player + i) % game.players.length;
      });
      await Future.delayed(
        Duration(
          milliseconds: (((2 * game.players.length + i + 1) / (2 * game.players.length)) * 400).round(),
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
                  selected: {game.players.length},
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
                if (Layouts.layoutsBySize[game.players.length] != null)
                  SegmentedButton<String>(
                    segments: <ButtonSegment<String>>[
                      for (Layout l in Layouts.layoutsBySize[game.players.length] ?? [])
                        ButtonSegment<String>(
                          value: l.runtimeType.toString(),
                          label: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 48,
                              width: 48,
                              child: RotatedBox(
                                quarterTurns: (game.rotated && l.runtimeType == game.layout.runtimeType ? 2 : 0) +
                                    layoutRotationOffset,
                                child: l.buildPreview(context),
                              ),
                            ),
                          ),
                        ),
                    ],
                    selected: {game.layout.runtimeType.toString()},
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
    var menuButtonForegroundColor = WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        return Theme.of(context).colorScheme.onSurface;
      },
    );
    var menuButtonStyle = ButtonStyle(
      foregroundColor: menuButtonForegroundColor,
      iconColor: menuButtonForegroundColor,
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
        Service.settingsService.pref_getScryfallImages
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CardSearchPage(),
                  ),
                );
              }
            : null,
        Icons.search,
        "Search Cards",
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
    setState(() {
      game = Game.fromPlayerList(players, layoutId);
    });
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
      if (game.isPlayersReset || await _showImportWarning(result.$1.length)) {
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

    game = Game(Service.settingsService.conf_players, Service.settingsService.conf_layout);

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
    counterFontSizeGroup.setNumPlayers(game.players.length);

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

    var barButtonForegroundColor = WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return null;
        }
        return Theme.of(context).colorScheme.onSurface;
      },
    );
    var barButtonStyle = ButtonStyle(
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      foregroundColor: barButtonForegroundColor,
      iconColor: barButtonForegroundColor,
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
                      quarterTurns: (game.rotated ? 2 : 0) + layoutRotationOffset,
                      child: game.layout.build(
                        context,
                        game.players,
                        (int i, _) {
                          const padding = 16.0;
                          return Stack(
                            children: [
                              AnimatedPadding(
                                padding: EdgeInsets.all(rearrangeMode ? padding : 0),
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.ease,
                                child: Counter(
                                  key: ValueKey(game.players[i].uuid),
                                  i: i,
                                  layout: game.layout,
                                  players: game.players,
                                  counterFontSizeGroup: counterFontSizeGroup,
                                  triggerReRender: () {
                                    triggerReRender = true;
                                  },
                                  stateChanged: () {
                                    setState(() {
                                      game.save();
                                    });
                                  },
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
                                                background: game.players[i].background,
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
                                        var temp = game.players[data];
                                        game.players[data] = game.players[i];
                                        game.players[i] = temp;
                                      }
                                    });
                                  },
                                  onWillAcceptWithDetails: (DragTargetDetails<int?> details) =>
                                      details.data != null && i != details.data,
                                ),
                            ],
                          );
                        },
                      ),
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
                                  onPressed: dragging > 0 || oldPlayers?.length != game.players.length
                                      ? null
                                      : () {
                                          game.players = oldPlayers ?? [];
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
                                      size: 24.0,
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
                                            game.players.shuffle();
                                          });
                                        },
                                  style: barButtonStyle,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12.0),
                                    child: Icon(
                                      Icons.shuffle_outlined,
                                      size: 24.0,
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
                                            game.save();
                                          });
                                        },
                                  style: barButtonStyle,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12.0),
                                    child: Icon(
                                      Icons.done,
                                      size: 24.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // draging
                          if (dragging > 0 && game.players.length > 2)
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
                                    setState(() {
                                      game.deletePlayer(data);
                                    });
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
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Icon(
                                  Icons.more_vert,
                                  size: 24.0,
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
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: RotatedBox(
                                    quarterTurns: (game.rotated ? 2 : 0) + layoutRotationOffset,
                                    child: game.layout.buildPreview(context),
                                  ),
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
                                oldPlayers = List.from(game.players);
                                setState(() {
                                  rearrangeMode = true;
                                });
                              },
                              style: barButtonStyle,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Icon(
                                  Icons.swap_horiz_outlined,
                                  size: 24.0,
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
                                size: 24.0,
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
