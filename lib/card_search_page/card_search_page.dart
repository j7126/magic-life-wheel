import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:magic_life_wheel/icons/custom_icons.dart';
import 'package:magic_life_wheel/life_counter_page/card_image/card_image.dart';
import 'package:magic_life_wheel/life_counter_page/dialogs/edit_player/cards_variant_dialog.dart';
import 'package:magic_life_wheel/mtgjson/dataModel/card_set.dart';
import 'package:magic_life_wheel/static_service.dart';

class CardSearchPage extends StatefulWidget {
  const CardSearchPage({super.key});

  @override
  State<CardSearchPage> createState() => _CardSearchPageState();
}

class _CardSearchPageState extends State<CardSearchPage> {
  late TextEditingController _searchFieldController;
  late ScrollController _scrollController;

  List<MapEntry<String, List<CardSet>>>? cards;

  final FocusNode _menuButtonFocusNode = FocusNode();

  void pop() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void searchCards(String searchStr) async {
    if (Service.dataLoader.allSetCards == null) {
      return;
    }
    var finalSearchStr = CardSet.filterStringForSearch(searchStr.trim());
    var searchStrWords = finalSearchStr.split(' ');
    var cards = Service.dataLoader.allSetCards?.data.where(
      (card) {
        if (card.cardSearchStringAlt != null && card.cardSearchStringAlt!.contains(finalSearchStr)) {
          return true;
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

  void selectVariant(List<CardSet> cards) {
    showDialog<(CardSet, bool)?>(
      context: context,
      builder: (BuildContext context) => CardsVariantDialog(
        cards: cards,
        fullCard: true,
      ),
    );
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
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 4,
        shadowColor: Theme.of(context).colorScheme.shadow,
        title: const Text("Card Search"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          TextField(
            controller: _searchFieldController,
            decoration: InputDecoration(
                hintText: "Search Cards",
                border: const UnderlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
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
                        icon: const Icon(Icons.close),
                      ),
                  ],
                )),
            autofocus: true,
            onChanged: (value) => searchCards(value),
          ),
          if (_searchFieldController.text.isEmpty || (cards?.isEmpty ?? true))
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints bc) {
                  var size = min(bc.maxHeight, bc.maxWidth) * 0.5;
                  return Column(
                    children: [
                      const Spacer(),
                      Icon(
                        CustomIcons.cardsOutlined,
                        size: size,
                        color: const Color.fromARGB(255, 76, 76, 76),
                      ),
                      Text(
                        cards?.isEmpty ?? false ? "No results found" : "",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: size * 0.13,
                              color: const Color.fromARGB(255, 76, 76, 76),
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                    ],
                  );
                },
              ),
            ),
          if (!(_searchFieldController.text.isEmpty || (cards?.isEmpty ?? true)))
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 500,
                  childAspectRatio: 672 / 936,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                padding: const EdgeInsets.all(16.0),
                controller: _scrollController,
                itemCount: cards?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  var card = cards?[index];
                  return card?.value == null
                      ? Container()
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(constraints.maxWidth * 0.05),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: GestureDetector(
                                onTap: () {
                                  if (card.value.length > 1) {
                                    selectVariant(card.value);
                                  }
                                },
                                child: CardImage(
                                  key: Key(card!.value.first.uuid),
                                  cardSet: card.value.first,
                                  fullCard: true,
                                ),
                              ),
                            );
                          },
                        );
                },
              ),
            ),
        ],
      ),
    );
  }
}
