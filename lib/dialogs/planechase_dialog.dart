import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:magic_life_wheel/service/static_service.dart';
import 'package:magic_life_wheel/widgets/card_image.dart';
import 'package:mana_icons_flutter/mana_icons_flutter.dart';
import 'package:magic_life_wheel/mtgjson/dataModel/card_set.dart';

class PlanechaseDialog extends StatefulWidget {
  const PlanechaseDialog({super.key});

  static int? planechasePlaneIndex;
  static CardSet? planechasePlane;
  static List<CardSet>? planechaseDeck;
  static bool rotated = false;
  static bool showInfo = false;

  @override
  State<PlanechaseDialog> createState() => _PlanechaseDialogState();
}

class _PlanechaseDialogState extends State<PlanechaseDialog> {
  final FocusNode _menuButtonFocusNode = FocusNode();

  void buildDeck() {
    PlanechaseDialog.planechaseDeck =
        Service.dataLoader.allSetCards?.data.where((x) => x.types.contains("Plane")).toList();
    PlanechaseDialog.planechaseDeck?.shuffle();
    setState(() {
      PlanechaseDialog.planechasePlaneIndex = null;
    });
  }

  void planeswalk() {
    if (PlanechaseDialog.planechaseDeck?.isEmpty ?? true) {
      buildDeck();
    }

    setState(() {
      PlanechaseDialog.planechasePlaneIndex = (PlanechaseDialog.planechasePlaneIndex ?? -1) + 1;
      PlanechaseDialog.planechasePlane = PlanechaseDialog
          .planechaseDeck?[PlanechaseDialog.planechasePlaneIndex! % PlanechaseDialog.planechaseDeck!.length];
    });
  }

  void back() {
    setState(() {
      PlanechaseDialog.planechasePlaneIndex = PlanechaseDialog.planechasePlaneIndex! - 1;
      PlanechaseDialog.planechasePlane = PlanechaseDialog
          .planechaseDeck?[PlanechaseDialog.planechasePlaneIndex! % PlanechaseDialog.planechaseDeck!.length];
    });
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
  Widget build(BuildContext context) {
    var card = PlanechaseDialog.planechasePlane;

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

    var isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    var imgw = isLandscape ? 936.0 : 672.0;
    var imgh = isLandscape ? 672.0 : 936.0;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: isLandscape ? 64.0 : 32.0, vertical: isLandscape ? 32.0 : 64.0),
      titlePadding: const EdgeInsets.only(top: 12.0, left: 18.0, right: 18.0),
      contentPadding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
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
                  buildDeck();
                  setState(() {
                    PlanechaseDialog.planechasePlane = null;
                  });
                },
                leadingIcon: const Icon(Icons.shuffle),
                child: const Text("Shuffle Deck"),
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
                                child: Opacity(
                                  opacity: 0.4,
                                  child: Icon(
                                    ManaIcons.ms_planeswalker,
                                    size: min(constraints.maxHeight, constraints.maxWidth) * 0.4,
                                  ),
                                ),
                              );
                            })
                          : LayoutBuilder(builder: (context, constraints) {
                              return PlanechaseDialog.showInfo
                                  ? Column(
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
                                                                  horizontal: (IconTheme.of(context).size ?? 1) * 0.1),
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
                                    )
                                  : RotatedBox(
                                      quarterTurns: (isLandscape ? 1 : 0) + (PlanechaseDialog.rotated ? 2 : 0),
                                      child: Container(
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
                                    );
                            }),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Divider(
                    height: 2,
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
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
              padding: const EdgeInsets.only(bottom: 58.0),
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
