import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:magic_life_wheel/dialog_service.dart';
import 'package:magic_life_wheel/life_counter_page/dialogs/planar_dice_dialog.dart';
import 'package:magic_life_wheel/mtgjson/dataModel/set.dart';
import 'package:magic_life_wheel/static_service.dart';
import 'package:magic_life_wheel/life_counter_page/card_image/card_image.dart';
import 'package:mana_icons_flutter/mana_icons_flutter.dart';
import 'package:magic_life_wheel/mtgjson/dataModel/card_set.dart';
import 'package:magic_life_wheel/icons/custom_icons.dart';

class PlanechaseDialog extends StatefulWidget {
  const PlanechaseDialog({super.key});

  static int? planechasePlaneIndex;
  static CardSet? planechasePlane;
  static CardSet? planechaseNextPlane;
  static List<CardSet>? planechaseDeck;
  static bool rotated = false;
  static bool showInfo = false;
  static List<MtgSet> availableSets = [];

  @override
  State<PlanechaseDialog> createState() => _PlanechaseDialogState();

  static void buildDeck() {
    if (Service.dataLoader.allSetCards == null) {
      return;
    }

    planechaseDeck = groupBy(
            Service.dataLoader.allSetCards!.data.where((x) =>
                x.types.contains("Plane") &&
                !Service.settingsService.pref_planechaseDisabledSets.contains(x.setCode) &&
                (Service.settingsService.pref_planechaseEnableFunny || x.isFunny != true)),
            (card) => card.name.trim().toLowerCase())
        .entries
        .map((cardsWithSameName) => cardsWithSameName.value.length == 1 || Service.dataLoader.sets == null
            ? cardsWithSameName.value.first
            : cardsWithSameName.value
                .sortedBy(
                    (card) => Service.dataLoader.sets!.data.firstWhere((set) => set.code == card.setCode).releaseDate)
                .last)
        .toList();
    planechaseDeck?.shuffle();
    planechasePlaneIndex = null;
  }

  static void setPlaneCard() {
    PlanechaseDialog.planechasePlane = PlanechaseDialog
        .planechaseDeck?[PlanechaseDialog.planechasePlaneIndex! % PlanechaseDialog.planechaseDeck!.length];
    PlanechaseDialog.planechaseNextPlane = PlanechaseDialog
        .planechaseDeck?[(PlanechaseDialog.planechasePlaneIndex! + 1) % PlanechaseDialog.planechaseDeck!.length];
  }

  static void planeForward() {
    PlanechaseDialog.planechasePlaneIndex = (PlanechaseDialog.planechasePlaneIndex ?? -1) + 1;
    PlanechaseDialog.setPlaneCard();
  }

  static void planeReverse() {
    PlanechaseDialog.planechasePlaneIndex = PlanechaseDialog.planechasePlaneIndex! - 1;
    PlanechaseDialog.setPlaneCard();
  }
}

class _PlanechaseDialogState extends State<PlanechaseDialog> with TickerProviderStateMixin {
  final FocusNode _menuButtonFocusNode = FocusNode();
  late final AnimationController _cardAnimationController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  late final Animation<Offset> _cardAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.0, 0.0),
  ).animate(CurvedAnimation(
    parent: _cardAnimationController,
    curve: Curves.easeInOut,
  ));

  bool _animatingPlaneswalk = false;

  late final AnimationController _setsAnimationController = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  late final Animation<double> _setsAnimation = CurvedAnimation(
    parent: _setsAnimationController,
    curve: Curves.fastOutSlowIn,
  );

  bool _showSetsSelector = false;
  bool get showSetsSelector => _showSetsSelector;
  set showSetsSelector(bool value) {
    _showSetsSelector = value;
    if (value) {
      _setsAnimationController.forward();
    } else {
      _setsAnimationController.reverse();
    }
  }

  void setDisabledSet(String code, bool enabled) {
    setState(() {
      var disabledSets = Service.settingsService.pref_planechaseDisabledSets;
      if (enabled) {
        disabledSets.add(code);
      } else {
        disabledSets.remove(code);
      }
      Service.settingsService.pref_planechaseDisabledSets = disabledSets;
    });
  }

  void planeswalkAnimationComplete() {
    setState(() {
      _animatingPlaneswalk = false;
      PlanechaseDialog.planeForward();
    });
  }

  void planeswalk() {
    if (_animatingPlaneswalk) {
      return;
    }

    showSetsSelector = false;

    if (PlanechaseDialog.planechaseDeck?.isEmpty ?? true) {
      setState(() {
        PlanechaseDialog.buildDeck();
      });
      planeswalkAnimationComplete();
    } else {
      if (PlanechaseDialog.showInfo || PlanechaseDialog.planechasePlane == null) {
        planeswalkAnimationComplete();
      } else {
        setState(() {
          _cardAnimationController.forward();
          _animatingPlaneswalk = true;
        });
      }
    }
  }

  void back() {
    if (_animatingPlaneswalk) {
      return;
    }

    setState(() {
      PlanechaseDialog.planeReverse();
    });
  }

  void getAvailableSets() {
    if (PlanechaseDialog.availableSets.isEmpty &&
        Service.dataLoader.loaded &&
        Service.dataLoader.sets != null &&
        Service.dataLoader.allSetCards != null) {
      PlanechaseDialog.availableSets = [];
      for (var card in Service.dataLoader.allSetCards!.data) {
        if (card.types.contains("Plane") && !PlanechaseDialog.availableSets.any((x) => x.code == card.setCode)) {
          var set = Service.dataLoader.sets!.data.firstWhereOrNull((x) => x.code == card.setCode);
          if (set != null) {
            PlanechaseDialog.availableSets.add(set);
          }
        }
      }
      PlanechaseDialog.availableSets.sortBy((x) => x.code);
    }
  }

  String? mapSymbolCode(String? code) {
    if (code == null) {
      return null;
    }
    code = code.toLowerCase();
    if (code == "t") {
      code = "tap";
    }
    return code;
  }

  Color? mapSymbolBackgroundColor(String? code) {
    if (code == null) {
      return null;
    }
    code = code.toLowerCase();
    switch (code) {
      case "w":
        return const Color.fromARGB(255, 233, 227, 176);
      case "u":
        return const Color.fromARGB(255, 141, 186, 208);
      case "b":
        return const Color.fromARGB(255, 154, 141, 137);
      case "r":
        return const Color.fromARGB(255, 221, 128, 101);
      case "g":
        return const Color.fromARGB(255, 127, 175, 145);
      default:
    }
    if (code == "t" || int.tryParse(code) != null) {
      return const Color.fromARGB(255, 202, 193, 190);
    }
    return null;
  }

  Color? mapSymbolForegroundColor(String? code) {
    if (code == null) {
      return null;
    }
    code = code.toLowerCase();
    switch (code) {
      case "w":
        return const Color.fromARGB(255, 32, 28, 20);
      case "u":
        return const Color.fromARGB(255, 5, 24, 33);
      case "b":
        return const Color.fromARGB(255, 18, 11, 13);
      case "r":
        return const Color.fromARGB(255, 31, 0, 0);
      case "g":
        return const Color.fromARGB(255, 0, 21, 10);
      default:
    }
    if (code == "t" || int.tryParse(code) != null) {
      return const Color.fromARGB(255, 18, 11, 13);
    }
    return null;
  }

  @override
  void initState() {
    _cardAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _animatingPlaneswalk) {
        _cardAnimationController.reset();
        planeswalkAnimationComplete();
      }
    });

    DialogService.register(context);
    super.initState();
  }

  @override
  void dispose() {
    DialogService.deregister(context);
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getAvailableSets();

    var enabledSets = PlanechaseDialog.availableSets
        .map((set) => set.code)
        .where((set) => !Service.settingsService.pref_planechaseDisabledSets.contains(set))
        .toSet();

    var card = PlanechaseDialog.planechasePlane;
    var nextCard = PlanechaseDialog.planechaseNextPlane;

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

    var isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    var imgw = isLandscape ? 936.0 : 672.0;
    var imgh = isLandscape ? 672.0 : 936.0;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: isLandscape ? 64.0 : 0.0, vertical: isLandscape ? 0.0 : 64.0),
      titlePadding: EdgeInsets.only(top: isLandscape ? 8.0 : 12.0, left: 20.0, right: 12.0),
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          const Text("Planechase"),
          const Spacer(),
          if (card != null)
            IconButton(
              icon: Icon(PlanechaseDialog.showInfo ? Icons.image_outlined : Icons.info_outline),
              onPressed: () {
                setState(() {
                  PlanechaseDialog.showInfo = !PlanechaseDialog.showInfo;
                });
              },
            ),
          MenuAnchor(
            childFocusNode: _menuButtonFocusNode,
            style: const MenuStyle(
              visualDensity: VisualDensity.comfortable,
            ),
            menuChildren: <Widget>[
              MenuItemButton(
                onPressed: () {
                  setState(() {
                    PlanechaseDialog.planechaseDeck = null;
                    PlanechaseDialog.planechasePlane = null;
                    PlanechaseDialog.planechaseNextPlane = null;
                    PlanechaseDialog.planechasePlaneIndex = null;
                  });
                },
                leadingIcon: const Icon(Icons.shuffle),
                child: const Text("Shuffle Deck"),
              ),
              if (card != null)
                MenuItemButton(
                  onPressed: () {
                    setState(() {
                      PlanechaseDialog.showInfo = !PlanechaseDialog.showInfo;
                    });
                  },
                  leadingIcon: Icon(PlanechaseDialog.showInfo ? Icons.image_outlined : Icons.info_outline),
                  child: Text(PlanechaseDialog.showInfo ? "Show Image" : "Show Text"),
                ),
            ],
            builder: (BuildContext context, MenuController controller, Widget? child) {
              return IconButton(
                focusNode: _menuButtonFocusNode,
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(Icons.more_vert),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: Service.dataLoader.loaded && Service.dataLoader.allSetCards != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: AspectRatio(
                    aspectRatio: imgw / imgh,
                    child: SizedBox(
                      width: imgw,
                      height: imgh,
                      child: card == null
                          ? LayoutBuilder(builder: (context, constraints) {
                              return Center(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                showSetsSelector = !showSetsSelector;
                                              });
                                            },
                                            behavior: HitTestBehavior.opaque,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                              child: Row(
                                                children: [
                                                  AnimatedRotation(
                                                    duration: const Duration(milliseconds: 200),
                                                    turns: showSetsSelector ? 0.5 : 0,
                                                    child: Transform.scale(
                                                      scale: 1.2,
                                                      child: const Icon(
                                                        Icons.expand_more,
                                                        size: 32,
                                                        color: Color.fromARGB(255, 178, 178, 178),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            "Enabled Sets",
                                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                                  color: const Color.fromARGB(255, 229, 229, 229),
                                                                ),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                          Text(
                                                            "${enabledSets.length} / ${PlanechaseDialog.availableSets.length}",
                                                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                                  color: const Color.fromARGB(255, 229, 229, 229),
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizeTransition(
                                            sizeFactor: _setsAnimation,
                                            axis: Axis.vertical,
                                            axisAlignment: -1,
                                            child: Column(
                                              children: [
                                                for (var set in PlanechaseDialog.availableSets.reversed)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(horizontal: 21.0, vertical: 2.0),
                                                    child: Row(
                                                      children: [
                                                        Checkbox(
                                                          value: enabledSets.contains(set.code),
                                                          onChanged: (value) {
                                                            setDisabledSet(set.code, value == false);
                                                          },
                                                        ),
                                                        const Gap(16.0),
                                                        GestureDetector(
                                                          child: Text("${set.code}: ${set.name}"),
                                                          onTap: () {
                                                            setDisabledSet(set.code, enabledSets.contains(set.code));
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            Service.settingsService.pref_planechaseEnableFunny =
                                                !Service.settingsService.pref_planechaseEnableFunny;
                                          });
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.gavel,
                                                size: 32,
                                                color: Color.fromARGB(255, 127, 127, 127),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Enable Unsanctioned",
                                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                              color: const Color.fromARGB(255, 229, 229, 229),
                                                            ),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                      Text(
                                                        "Playtest cards or cards from un-sets",
                                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                              color: const Color.fromARGB(255, 229, 229, 229),
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Switch(
                                                value: Service.settingsService.pref_planechaseEnableFunny,
                                                onChanged: (bool value) {
                                                  setState(() {
                                                    Service.settingsService.pref_planechaseEnableFunny = value;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(32.0),
                                        child: FilledButton(
                                          onPressed: planeswalk,
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  ManaIcons.ms_planeswalker,
                                                  size: 36,
                                                ),
                                                Gap(12.0),
                                                Text(
                                                  "Planeswalk",
                                                  style: TextStyle(
                                                    fontSize: 26.0,
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
                              );
                            })
                          : LayoutBuilder(builder: (context, constraints) {
                              return PlanechaseDialog.showInfo
                                  ? Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: Text(
                                              card.name,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: min(constraints.maxHeight, constraints.maxWidth) * 0.12,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Builder(builder: (context) {
                                              var spans = RegExp(r'({)([^}]*)(})|([^{]*)')
                                                  .allMatches(card.text?.replaceAll("\n", "\n\n") ?? "")
                                                  .where((element) => element.group(0) != null);
                                              return AutoSizeText.rich(
                                                TextSpan(
                                                  children: [
                                                    for (var span in spans)
                                                      span.groupCount > 1 &&
                                                              ManaIcons.icons.containsKey(mapSymbolCode(span.group(2)))
                                                          ? WidgetSpan(
                                                              child: Padding(
                                                                padding: EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        (IconTheme.of(context).size ?? 1) * 0.1),
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(
                                                                        (IconTheme.of(context).size ?? 1) * 0.5),
                                                                    color: mapSymbolBackgroundColor(span.group(2)),
                                                                  ),
                                                                  clipBehavior: Clip.hardEdge,
                                                                  child: Padding(
                                                                    padding: EdgeInsets.all(
                                                                        (IconTheme.of(context).size ?? 1) * 0.1),
                                                                    child: Icon(
                                                                      ManaIcons.icons[mapSymbolCode(span.group(2))],
                                                                      color: mapSymbolForegroundColor(span.group(2)),
                                                                      size: (IconTheme.of(context).size ?? 1) * 0.8,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : TextSpan(
                                                              text: span.group(0),
                                                            ),
                                                  ],
                                                ),
                                                placeholderDimensions: [
                                                  for (var span in spans)
                                                    if (span.groupCount > 1 &&
                                                        ManaIcons.icons.containsKey(mapSymbolCode(span.group(2))))
                                                      PlaceholderDimensions(
                                                        size: Size(
                                                          (IconTheme.of(context).size ?? 0) * 1.2,
                                                          (IconTheme.of(context).size ?? 0),
                                                        ),
                                                        alignment: PlaceholderAlignment.baseline,
                                                      )
                                                ],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: min(constraints.maxHeight, constraints.maxWidth) * 0.08,
                                                ),
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    )
                                  : RotatedBox(
                                      quarterTurns: (isLandscape ? 1 : 0) + (PlanechaseDialog.rotated ? 2 : 0),
                                      child: Container(
                                        decoration: const BoxDecoration(),
                                        clipBehavior: Clip.hardEdge,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Stack(
                                            children: [
                                              if (nextCard != null)
                                                Stack(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(
                                                          min(constraints.maxHeight, constraints.maxWidth) * 0.05,
                                                        ),
                                                      ),
                                                      clipBehavior: Clip.antiAlias,
                                                      child: Opacity(
                                                        opacity: _animatingPlaneswalk ? 1 : 0,
                                                        child: CardImage(
                                                          key: Key(nextCard.uuid),
                                                          cardSet: nextCard,
                                                          fullCard: true,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(
                                                          min(constraints.maxHeight, constraints.maxWidth) * 0.05,
                                                        ),
                                                        border: Border.all(
                                                          color: Theme.of(context).colorScheme.surface,
                                                          width:
                                                              min(constraints.maxHeight, constraints.maxWidth) * 0.005,
                                                          strokeAlign: BorderSide.strokeAlignCenter,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              SlideTransition(
                                                position: _cardAnimation,
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(
                                                          min(constraints.maxHeight, constraints.maxWidth) * 0.05,
                                                        ),
                                                      ),
                                                      clipBehavior: Clip.antiAlias,
                                                      child: CardImage(
                                                        key: Key(card.uuid),
                                                        cardSet: card,
                                                        fullCard: true,
                                                      ),
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(
                                                          min(constraints.maxHeight, constraints.maxWidth) * 0.05,
                                                        ),
                                                        border: Border.all(
                                                          color: Theme.of(context).colorScheme.surface,
                                                          width:
                                                              min(constraints.maxHeight, constraints.maxWidth) * 0.005,
                                                          strokeAlign: BorderSide.strokeAlignCenter,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                            }),
                    ),
                  ),
                ),
                const Divider(
                  height: 2,
                ),
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(26),
                      bottomRight: Radius.circular(26),
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: PlanechaseDialog.planechasePlaneIndex == null ||
                                  PlanechaseDialog.planechasePlaneIndex! <= 0
                              ? null
                              : back,
                          style: barButtonStyle,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Icon(
                              Icons.undo,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: planeswalk,
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
                          onPressed: card != null
                              ? () async {
                                  var result = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) => const PlanarDiceDialog(),
                                  );
                                  if (result == true) {
                                    planeswalk();
                                  }
                                }
                              : null,
                          style: barButtonStyle,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Icon(
                              CustomIcons.diceD6,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: card == null || PlanechaseDialog.showInfo
                              ? null
                              : () {
                                  setState(() {
                                    PlanechaseDialog.rotated = !PlanechaseDialog.rotated;
                                  });
                                },
                          style: barButtonStyle,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Icon(
                              Icons.screen_rotation_alt_outlined,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Flexible(
                child: AspectRatio(
                  aspectRatio: imgw / imgh,
                  child: SizedBox(
                    width: imgw,
                    height: imgh,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
