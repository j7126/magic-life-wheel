import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as image_manipulation;
import 'package:magic_life_wheel/datamodel/player.dart';
import 'package:magic_life_wheel/dialog_service.dart';
import 'package:magic_life_wheel/dialogs/card_full_dialog.dart';
import 'package:magic_life_wheel/dialogs/message_dialog.dart';
import 'package:magic_life_wheel/life_counter_page/dialogs/edit_player/set_colors_dialog.dart';
import 'package:magic_life_wheel/icons/custom_icons.dart';
import 'package:magic_life_wheel/mtgjson/extension/card_set.dart';
import 'package:magic_life_wheel/mtgjson/magic_life_wheel_protobuf/card_set.pb.dart';
import 'package:magic_life_wheel/static_service.dart';
import 'package:magic_life_wheel/life_counter_page/card_image/card_image.dart';
import 'package:magic_life_wheel/life_counter_page/dialogs/edit_player/cards_variant_dialog.dart';
import 'package:magic_life_wheel/life_counter_page/card_image/background_widget.dart';
import 'package:mana_icons_flutter/mana_icons_flutter.dart';

class EditBackgroundDialog extends StatefulWidget {
  const EditBackgroundDialog({super.key, required this.player});

  final Player player;

  @override
  State<EditBackgroundDialog> createState() => _EditBackgroundDialogState();
}

class _EditBackgroundDialogState extends State<EditBackgroundDialog> {
  late TextEditingController _searchFieldController;
  late ScrollController _scrollController;

  final ImagePicker picker = ImagePicker();

  List<MapEntry<String, List<CardSet>>>? cards;

  bool commanderOnly = true;
  bool enableFunny = false;

  final FocusNode _menuButtonFocusNode = FocusNode();

  bool loadingCustomImage = false;

  void pop() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void searchCards(String searchStr) async {
    if (Service.dataLoader.allSetCards == null) {
      return;
    }
    var finalSearchStr = CardSetExtension.filterStringForSearch(searchStr.trim());
    var searchStrWords = finalSearchStr.split(' ');
    var cards = Service.dataLoader.allSetCards?.data.where(
      (card) {
        if (commanderOnly &&
            !(card.hasCommander() ||
                ((widget.player.card?.hasKeywordChooseBackground() ?? false) &&
                    card.hasSubtypeBackground()))) {
          return false;
        }
        if (!enableFunny && card.isFunny == true) {
          return false;
        }
        if (card.hasCardSearchStringAlt() && card.cardSearchStringAlt.contains(finalSearchStr)) {
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

  void selectVariant(List<CardSet> cards) async {
    var card = await showDialog<(CardSet, bool)?>(
      context: context,
      builder: (BuildContext context) => CardsVariantDialog(
        cards: cards,
        player: widget.player,
      ),
    );
    setState(() {
      if (card != null) {
        if (card.$2) {
          widget.player.cardPartner = card.$1;
        } else {
          if (widget.player.card?.uuid == card.$1.uuid) {
            widget.player.card = widget.player.cardPartner;
            widget.player.cardPartner = null;
          } else if (widget.player.cardPartner?.uuid == card.$1.uuid) {
            widget.player.cardPartner = null;
          } else {
            widget.player.card = card.$1;
            if (widget.player.cardPartner?.name == card.$1.name) {
              widget.player.cardPartner = null;
            }
          }
        }
        Navigator.of(context).pop();
      }
    });
  }

  void customImageError() {
    setState(() {
      loadingCustomImage = false;
    });

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return const MessageDialog(
          title: 'Failed to set image!',
          message: 'The image format may not be supported, please try another image.',
        );
      },
    );
  }

  void setCustomImage() async {
    setState(() {
      loadingCustomImage = true;
    });

    await Future.delayed(const Duration(milliseconds: 50));

    var file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) {
      setState(() {
        loadingCustomImage = false;
      });
      return;
    }

    var bytes = await file.readAsBytes();

    var image = await compute((bytes) => image_manipulation.decodeImage(bytes), bytes);
    if (image == null) {
      return customImageError();
    }

    if (max(image.width, image.height) > 700) {
      var isLandscape = image.width > image.height;
      if (isLandscape) {
        image = await compute(
            (image) => image_manipulation.copyResize(
                  image,
                  width: 700,
                  height: null,
                ),
            image);
      } else {
        image = await compute(
            (image) => image_manipulation.copyResize(
                  image,
                  width: null,
                  height: 700,
                ),
            image);
      }
    }

    widget.player.background.customImage = await compute(
        (image) => image_manipulation.encodeJpg(
              image,
              quality: 80,
            ),
        image);

    pop();
  }

  void setColors() async {
    var colors = await showDialog<List<Color>?>(
      context: context,
      builder: (BuildContext context) => SetColorsDialog(
        colors: widget.player.background.colors,
      ),
    );

    if (colors != null && colors.isNotEmpty) {
      setState(() {
        widget.player.background.colors = colors;
      });
      pop();
    } else if (colors != null && colors.isEmpty && widget.player.background.colors != null) {
      setState(() {
        widget.player.background.colors = null;
      });
    }
  }

  @override
  void initState() {
    DialogService.register(context);
    _searchFieldController = TextEditingController();
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    DialogService.deregister(context);
    _searchFieldController.dispose();
    _scrollController.dispose();
    _menuButtonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    cardSelector(
      List<CardSet>? card, {
      bool useSelectedName = false,
    }) {
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
                    useSelectedName ? selectedCard.displayName : card.first.displayName,
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
                    "Artist: ${selectedCard.hasArtist() ? selectedCard.artist : "Unknown"}",
                    style: const TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Stack(
                      children: [
                        CardImage(
                          key: Key(selectedCard.uuid),
                          cardSet: selectedCard,
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(
                              Icons.open_in_new,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 2,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => CardFullDialog(
                                  card: selectedCard!,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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
                    if (!commanderOnly ||
                        selectedCard.hasCommander() ||
                        widget.player.cardPartner?.name == selectedCard.name)
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            if (widget.player.card?.name == selectedCard!.name) {
                              // if the card is already selected, deselect it.
                              if (widget.player.card != null &&
                                  widget.player.cardPartner != null &&
                                  widget.player.cardPartner!.hasSubtypeBackground() &&
                                  widget.player.card!.canPartner(widget.player.cardPartner!)) {
                                // if the partner is a legal background, remove it
                                widget.player.cardPartner = null;
                              }
                              widget.player.card = widget.player.cardPartner;
                              widget.player.cardPartner = null;
                            } else if (widget.player.cardPartner?.name == selectedCard.name) {
                              // if the card is already partner, deselect it.
                              widget.player.cardPartner = null;
                            } else {
                              // select the card.
                              widget.player.card = selectedCard;
                              if (widget.player.cardPartner?.name == selectedCard.name) {
                                // if the card was partner, remove it.
                                widget.player.cardPartner = null;
                              }
                              if (widget.player.card != null &&
                                  widget.player.cardPartner != null &&
                                  !widget.player.forcePartner &&
                                  !widget.player.card!.canPartner(widget.player.cardPartner!)) {
                                // if the new selection cannot be partners with the existing partner, remove it.
                                widget.player.cardPartner = null;
                              }
                            }
                            Navigator.of(context).pop();
                          });
                        },
                        style: ButtonStyle(
                          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)),
                          backgroundColor: widget.player.cardPartner?.name == selectedCard.name
                              ? WidgetStatePropertyAll(Theme.of(context).colorScheme.inversePrimary)
                              : null,
                          foregroundColor: widget.player.cardPartner?.name == selectedCard.name
                              ? WidgetStatePropertyAll(Theme.of(context).colorScheme.inverseSurface)
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.player.card?.name == selectedCard.name ||
                                widget.player.cardPartner?.name == selectedCard.name)
                              Padding(
                                padding: EdgeInsets.only(right: 6.0),
                                child: Icon(
                                  Icons.check,
                                  size: 18.0,
                                  color: widget.player.cardPartner?.name == selectedCard.name
                                      ? Theme.of(context).colorScheme.inverseSurface
                                      : null,
                                ),
                              ),
                            Text(widget.player.card?.name == selectedCard.name
                                ? "Selected"
                                : widget.player.cardPartner?.name == selectedCard.name
                                    ? "Partnered"
                                    : "Select"),
                          ],
                        ),
                      ),
                    if (widget.player.card?.name != selectedCard.name &&
                        widget.player.cardPartner?.name != selectedCard.name &&
                        (widget.player.forcePartner ||
                            (widget.player.card != null && widget.player.card!.canPartner(selectedCard))))
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: FilledButton(
                          onPressed: () {
                            setState(() {
                              widget.player.cardPartner = selectedCard;
                              Navigator.of(context).pop();
                            });
                          },
                          style: ButtonStyle(
                            padding:
                                const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)),
                            backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.inversePrimary),
                            foregroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.inverseSurface),
                          ),
                          child: const Text("Partner"),
                        ),
                      ),
                    const Spacer(),
                    if (card.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: FilledButton.tonal(
                          onPressed: () => selectVariant(card),
                          style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)),
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

    return loadingCustomImage
        ? Container(
            color: Colors.transparent,
            width: double.infinity,
            height: double.infinity,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Dialog(
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          "Background",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: setCustomImage,
                        icon: const Icon(Icons.image_outlined),
                      ),
                      IconButton(
                        onPressed: setColors,
                        icon: const Icon(Icons.color_lens_outlined),
                      ),
                      MenuAnchor(
                        childFocusNode: _menuButtonFocusNode,
                        style: const MenuStyle(
                          visualDensity: VisualDensity.comfortable,
                        ),
                        menuChildren: <Widget>[
                          MenuItemButton(
                            onPressed: setCustomImage,
                            leadingIcon: const Icon(Icons.image_outlined),
                            child: const Text("Custom Image"),
                          ),
                          MenuItemButton(
                            onPressed: setColors,
                            leadingIcon: const Icon(Icons.color_lens_outlined),
                            child: const Text("Color Background"),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7.0),
                            child: Container(
                              height: 2.0,
                              color: (DividerTheme.of(context).color ?? Theme.of(context).colorScheme.outlineVariant)
                                  .withAlpha(127),
                            ),
                          ),
                          MenuItemButton(
                            onPressed: widget.player.background.hasBackground
                                ? () {
                                    setState(() {
                                      widget.player.background.clear();
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
                          MenuItemButton(
                            onPressed: () {
                              setState(() {
                                enableFunny = !enableFunny;
                              });
                              searchCards(_searchFieldController.text);
                            },
                            closeOnActivate: false,
                            leadingIcon: SizedBox(
                              width: IconTheme.of(context).size,
                              height: IconTheme.of(context).size,
                              child: Checkbox(
                                value: enableFunny,
                                onChanged: (bool? value) {
                                  setState(() {
                                    enableFunny = value ?? false;
                                  });
                                  searchCards(_searchFieldController.text);
                                },
                              ),
                            ),
                            child: const Text("Enable Unset Cards"),
                          ),
                          MenuItemButton(
                            onPressed: () {
                              setState(() {
                                widget.player.forcePartner = !widget.player.forcePartner;
                              });
                            },
                            closeOnActivate: false,
                            leadingIcon: SizedBox(
                              width: IconTheme.of(context).size,
                              height: IconTheme.of(context).size,
                              child: Checkbox(
                                value: widget.player.forcePartner,
                                onChanged: (bool? value) {
                                  setState(() {
                                    widget.player.forcePartner = value ?? false;
                                  });
                                },
                              ),
                            ),
                            child: const Text("Force Partner"),
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
                if (Service.settingsService.pref_getScryfallImages)
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
                  )
                else if (!widget.player.background.hasBackground)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: setColors,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.palette_outlined,
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
                                          "Color background",
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                color: const Color.fromARGB(255, 229, 229, 229),
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Text(
                                          "Set a solid color or gradient background.",
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                color: const Color.fromARGB(255, 229, 229, 229),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.open_in_new,
                                  color: Color.fromARGB(255, 178, 178, 178),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: setCustomImage,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.image_outlined,
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
                                          "Custom image",
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                color: const Color.fromARGB(255, 229, 229, 229),
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Text(
                                          "Select your own custom background image.",
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                color: const Color.fromARGB(255, 229, 229, 229),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.open_in_new,
                                  color: Color.fromARGB(255, 178, 178, 178),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              Service.settingsService.pref_getScryfallImages =
                                  !Service.settingsService.pref_getScryfallImages;
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                            child: Row(
                              children: [
                                const Icon(
                                  ManaIcons.ms_planeswalker,
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
                                          "Card images",
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                color: const Color.fromARGB(255, 229, 229, 229),
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Text(
                                          "Fetch card images from scryfall.",
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                color: const Color.fromARGB(255, 229, 229, 229),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: Service.settingsService.pref_getScryfallImages,
                                  onChanged: (bool value) {
                                    setState(() {
                                      Service.settingsService.pref_getScryfallImages = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_searchFieldController.text.isEmpty || (cards?.isEmpty ?? true))
                  if (widget.player.background.hasBackground)
                    Expanded(
                      child: Column(
                        children: [
                          if (cards?.isEmpty ?? false)
                            Padding(
                              padding: const EdgeInsets.only(top: 24.0, bottom: 4.0),
                              child: Row(
                                children: [
                                  const Spacer(),
                                  const Icon(
                                    CustomIcons.cardsOutlined,
                                    size: 34,
                                    color: Color.fromARGB(255, 76, 76, 76),
                                  ),
                                  const Gap(8.0),
                                  Text(
                                    "No results found",
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          color: const Color.fromARGB(255, 76, 76, 76),
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          const Gap(16.0),
                          if (widget.player.card != null && Service.dataLoader.allSetCards != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 500,
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1.1,
                                  child: cardSelector(
                                    Service.dataLoader.allSetCards?.data
                                        .where((element) => element.name == widget.player.card?.name)
                                        .toList(),
                                    useSelectedName: true,
                                  ),
                                ),
                              ),
                            ),
                          if (widget.player.background.customImage != null || widget.player.background.colors != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 500,
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1.1,
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: Stack(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0),
                                              child: Text(
                                                widget.player.background.customImage != null
                                                    ? "Custom Image"
                                                    : (widget.player.background.colors?.length ?? 0) > 1
                                                        ? "Color Gradient"
                                                        : "Color",
                                                style: const TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: BackgroundWidget(
                                                  background: widget.player.background,
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
                                                  onPressed: widget.player.background.customImage != null
                                                      ? setCustomImage
                                                      : setColors,
                                                  style: const ButtonStyle(
                                                    padding: WidgetStatePropertyAll(
                                                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 6.0),
                                                        child: Icon(
                                                          widget.player.background.customImage != null
                                                              ? Icons.image_outlined
                                                              : Icons.color_lens_outlined,
                                                          size: 18.0,
                                                        ),
                                                      ),
                                                      Text(
                                                        widget.player.background.customImage != null
                                                            ? "Change Image"
                                                            : (widget.player.background.colors?.length ?? 0) > 1
                                                                ? "Change Colors"
                                                                : "Change Color",
                                                      ),
                                                    ],
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
                              ),
                            ),
                          const Gap(8.0),
                          if ((widget.player.card != null && Service.dataLoader.allSetCards != null) &&
                              widget.player.cardPartner != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 500,
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1.1,
                                  child: cardSelector(Service.dataLoader.allSetCards?.data
                                      .where((element) => element.name == widget.player.cardPartner?.name)
                                      .toList()),
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  else if (Service.settingsService.pref_getScryfallImages)
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
