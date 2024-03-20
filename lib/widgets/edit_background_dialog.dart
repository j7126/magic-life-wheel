import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:magic_life_wheel/datamodel/player.dart';
import 'package:magic_life_wheel/icons/custom_icons.dart';
import 'package:magic_life_wheel/mtgjson/dataModel/card_set.dart';
import 'package:magic_life_wheel/service/static_service.dart';
import 'package:magic_life_wheel/widgets/card_image.dart';
import 'package:magic_life_wheel/widgets/cards_variant_dialog.dart';

class EditBackgroundDialog extends StatefulWidget {
  const EditBackgroundDialog({super.key, required this.player});

  final Player player;

  @override
  State<EditBackgroundDialog> createState() => _EditBackgroundDialogState();
}

class _EditBackgroundDialogState extends State<EditBackgroundDialog> {
  late TextEditingController _searchFieldController;
  late ScrollController _scrollController;

  List<MapEntry<String, List<CardSet>>>? cards;

  bool commanderOnly = true;

  final FocusNode _menuButtonFocusNode = FocusNode();

  void searchCards(String searchStr) async {
    if (Service.dataLoader.allSetCards == null) {
      return;
    }
    var finalSearchStr = CardSet.filterStringForSearch(searchStr.trim());
    var searchStrWords = finalSearchStr.split(' ');
    var cards = Service.dataLoader.allSetCards?.data.where(
      (card) {
        if (commanderOnly && !(card.leadershipSkills?.commander ?? false)) {
          return false;
        }
        return card.cardSearchString.contains(finalSearchStr);
      },
    );
    var cardGroups = groupBy<CardSet, String>(cards ?? [], (card) => card.name).entries.toList();
    cardGroups.sort((a, b) {
      var wordMatchesA = a.value.first.getWordMatches(searchStrWords);
      var wordMatchesB = b.value.first.getWordMatches(searchStrWords);
      if (wordMatchesA != wordMatchesB) {
        return wordMatchesB - wordMatchesA;
      } else {
        return a.key.length.compareTo(b.key.length);
      }
    });
    if (searchStr == _searchFieldController.text) {
      setState(() {
        this.cards = cardGroups;
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    }
  }

  void selectVariant(List<CardSet> cards) async {
    var card = await showDialog<CardSet?>(
      context: context,
      builder: (BuildContext context) => CardsVariantDialog(
        cards: cards,
        player: widget.player,
      ),
    );
    setState(() {
      if (card != null) {
        widget.player.card = card;
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void initState() {
    _searchFieldController = TextEditingController();
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    _scrollController.dispose();
    _menuButtonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    cardSelector(List<CardSet>? card) {
      if (card == null) {
        return Container();
      }

      var selectedCard = card.firstWhereOrNull((x) => x.uuid == widget.player.card?.uuid);
      selectedCard ??= card.first;
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0),
                  child: Text(
                    card.first.name,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    Service.dataLoader.sets?.getSet(selectedCard.setCode)?.name ?? "Unknown Set",
                    style: const TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    "Artist: ${selectedCard.artist ?? "Unknown"}",
                    style: const TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: CardImage(
                      key: Key(selectedCard.uuid),
                      cardSet: selectedCard,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          widget.player.card = selectedCard ?? card.first;
                          Navigator.of(context).pop();
                        });
                      },
                      style: const ButtonStyle(
                        padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)),
                      ),
                      child: widget.player.card?.uuid == selectedCard.uuid ? const Text("Selected") : const Text("Select"),
                    ),
                    const Spacer(),
                    if (card.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: FilledButton.tonal(
                          onPressed: () => selectVariant(card),
                          style: const ButtonStyle(
                            padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)),
                          ),
                          child: Text("${card.length} Variants"),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Background",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Spacer(),
                MenuAnchor(
                  childFocusNode: _menuButtonFocusNode,
                  style: const MenuStyle(
                    visualDensity: VisualDensity.comfortable,
                  ),
                  menuChildren: <Widget>[
                    MenuItemButton(
                      onPressed: widget.player.card != null
                          ? () {
                              setState(() {
                                widget.player.card = null;
                              });
                            }
                          : null,
                      leadingIcon: const Icon(Icons.deselect),
                      child: const Text("Remove Background"),
                    ),
                    MenuItemButton(
                      onPressed: () {
                        setState(() {
                          commanderOnly = !commanderOnly;
                        });
                        searchCards(_searchFieldController.text);
                      },
                      closeOnActivate: false,
                      leadingIcon: SizedBox(
                        width: IconTheme.of(context).size,
                        height: IconTheme.of(context).size,
                        child: Checkbox(
                          value: commanderOnly,
                          onChanged: (bool? value) {
                            setState(() {
                              commanderOnly = value ?? false;
                            });
                            searchCards(_searchFieldController.text);
                          },
                        ),
                      ),
                      child: const Text("Commander Only"),
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
              ],
            ),
          ),
          TextField(
            controller: _searchFieldController,
            decoration: InputDecoration(
                hintText: "Search Cards",
                border: const UnderlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchFieldController.text.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _searchFieldController.clear();
                          });
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                  ],
                )),
            autofocus: true,
            onChanged: (value) => searchCards(value),
          ),
          if (_searchFieldController.text.isEmpty || (cards?.isEmpty ?? true))
            widget.player.card != null && Service.dataLoader.allSetCards != null
                ? Expanded(
                    child: Column(
                      children: [
                        if (cards?.isEmpty ?? false)
                          Opacity(
                            opacity: 0.3,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 24.0, bottom: 4.0),
                              child: Row(
                                children: [
                                  const Spacer(),
                                  const Icon(
                                    CustomIcons.cards_outlined,
                                    size: 34,
                                  ),
                                  const Gap(8.0),
                                  Text(
                                    "No results found",
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            constraints: const BoxConstraints(
                              maxWidth: 500,
                            ),
                            child: AspectRatio(
                              aspectRatio: 1.1,
                              child: cardSelector(Service.dataLoader.allSetCards?.data
                                  .where((element) => element.name == widget.player.card?.name)
                                  .toList()),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints bc) {
                        var size = min(bc.maxHeight, bc.maxWidth) * 0.5;
                        return Opacity(
                          opacity: 0.3,
                          child: Column(
                            children: [
                              const Spacer(),
                              Icon(
                                CustomIcons.cards_outlined,
                                size: size,
                              ),
                              Text(
                                cards?.isEmpty ?? false ? "No results found" : "",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: size * 0.13,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const Spacer(),
                            ],
                          ),
                        );
                      },
                    ),
                  )
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 500,
                  childAspectRatio: 1.1,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                padding: const EdgeInsets.all(16.0),
                controller: _scrollController,
                itemCount: cards?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  var card = cards?[index];
                  return cardSelector(card?.value);
                },
              ),
            ),
        ],
      ),
    );
  }
}
