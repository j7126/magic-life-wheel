import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:magic_life_wheel/datamodel/player.dart';
import 'package:magic_life_wheel/dialog_service.dart';
import 'package:magic_life_wheel/dialogs/card_full_dialog.dart';
import 'package:magic_life_wheel/mtgjson/extension/card_set.dart';
import 'package:magic_life_wheel/mtgjson/magic_life_wheel_protobuf/card_set.pb.dart';
import 'package:magic_life_wheel/static_service.dart';
import 'package:magic_life_wheel/life_counter_page/card_image/card_image.dart';

class CardsVariantDialog extends StatefulWidget {
  const CardsVariantDialog({
    super.key,
    required this.cards,
    this.player,
    this.fullCard = false,
  });

  final List<CardSet> cards;
  final Player? player;
  final bool fullCard;

  @override
  State<CardsVariantDialog> createState() => _CardsVariantDialogState();
}

class _CardsVariantDialogState extends State<CardsVariantDialog> {
  @override
  void initState() {
    DialogService.register(context);
    super.initState();
  }

  @override
  void dispose() {
    DialogService.deregister(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    cardSelector(CardSet card) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.fullCard)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0),
                    child: Text(
                      card.displayName,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (!widget.fullCard)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      Service.dataLoader.sets?.getSet(card.setCode)?.name ?? "Unknown Set",
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                if (!widget.fullCard)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "Artist: ${card.hasArtist() ? card.artist : "Unknown"}",
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: widget.fullCard ? EdgeInsets.zero : const EdgeInsets.only(top: 8.0),
                    child: Stack(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(constraints.maxWidth * 0.05),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: CardImage(
                                key: Key(card.uuid),
                                cardSet: card,
                                fullCard: widget.fullCard,
                              ),
                            );
                          },
                        ),
                        if (!widget.fullCard)
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
                                    card: card,
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
            if (widget.player != null)
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (widget.player!.cardPartner?.name != card.name ||
                          widget.player!.cardPartner?.uuid == card.uuid)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                Navigator.of(context).pop((card, false));
                              });
                            },
                            style: ButtonStyle(
                              padding:
                                  const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)),
                              backgroundColor: widget.player!.cardPartner?.uuid == card.uuid
                                  ? WidgetStatePropertyAll(Theme.of(context).colorScheme.inversePrimary)
                                  : null,
                              foregroundColor: widget.player!.cardPartner?.uuid == card.uuid
                                  ? WidgetStatePropertyAll(Theme.of(context).colorScheme.inverseSurface)
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.player!.card?.uuid == card.uuid ||
                                    widget.player!.cardPartner?.uuid == card.uuid)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 6.0),
                                    child: Icon(
                                      Icons.check,
                                      size: 18.0,
                                    ),
                                  ),
                                Text(widget.player!.card?.uuid == card.uuid
                                    ? "Selected"
                                    : widget.player!.cardPartner?.uuid == card.uuid
                                        ? "Partnered"
                                        : "Select"),
                              ],
                            ),
                          ),
                        ),
                      const Gap(8.0),
                      if (widget.player!.card?.name != card.name &&
                          widget.player!.cardPartner?.uuid != card.uuid &&
                          (widget.player!.forcePartner ||
                              (widget.player!.card != null && widget.player!.card!.canPartner(card))))
                        FilledButton(
                          onPressed: () {
                            setState(() {
                              Navigator.of(context).pop((card, true));
                            });
                          },
                          style: ButtonStyle(
                            padding: const WidgetStatePropertyAll(
                              EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            ),
                            backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.inversePrimary),
                            foregroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.inverseSurface),
                          ),
                          child: const Text("Partner"),
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
            padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(
                      widget.cards.first.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 500,
                childAspectRatio: widget.fullCard ? 672 / 936 : 1.1,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: widget.cards.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (BuildContext context, int index) {
                return cardSelector(widget.cards[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
