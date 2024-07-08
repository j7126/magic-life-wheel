import 'dart:math';

import 'package:flutter/material.dart';
import 'package:magic_life_wheel/dialog_service.dart';
import 'package:magic_life_wheel/mtgjson/dataModel/card_set.dart';
import 'package:magic_life_wheel/life_counter_page/card_image/card_image.dart';

class CardFullDialog extends StatefulWidget {
  const CardFullDialog({
    super.key,
    required this.card,
  });

  final CardSet card;

  @override
  State<CardFullDialog> createState() => _CardFullDialogState();
}

class _CardFullDialogState extends State<CardFullDialog> {
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
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      widget.card.displayName,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                ),
              ],
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(builder: (context, constraints) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      min(constraints.maxHeight, constraints.maxWidth) * 0.05,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AspectRatio(
                    aspectRatio: 672 / 936,
                    child: CardImage(
                      cardSet: widget.card,
                      fullCard: true,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
