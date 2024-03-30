import 'dart:math';

import 'package:flutter/material.dart';
import 'package:magic_life_wheel/mtgjson/dataModel/card_set.dart';
import 'package:magic_life_wheel/service/static_service.dart';

class CardImage extends StatefulWidget {
  const CardImage({
    super.key,
    required this.cardSet,
    this.iconPadding = EdgeInsets.zero,
    this.fullCard = false,
  });

  final CardSet? cardSet;
  final EdgeInsets iconPadding;
  final bool fullCard;

  @override
  State<CardImage> createState() => _CardImageState();
}

class _CardImageState extends State<CardImage> {
  bool _ready = false;
  bool _valid = true;
  late String _imageUrl;

  void setup() async {
    String? id = widget.cardSet?.identifiers.scryfallId;
    if (id == null) {
      _ready = false;
      _valid = false;
      return;
    }
    String fileFace = 'front';
    String dir1 = id[0];
    String dir2 = id[1];
    if (widget.fullCard) {
      _imageUrl = 'https://cards.scryfall.io/large/$fileFace/$dir1/$dir2/$id.jpg';
    } else {
      _imageUrl = 'https://cards.scryfall.io/art_crop/$fileFace/$dir1/$dir2/$id.jpg';
    }
    setState(() {
      _ready = true;
    });
  }

  @override
  void initState() {
    setup();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var brokenImage = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints bc) {
        var size = min(bc.maxHeight, bc.maxWidth) * 0.4;
        return Center(
          child: Opacity(
            opacity: 0.3,
            child: Icon(
              Icons.broken_image_outlined,
              size: size,
            ),
          ),
        );
      },
    );

    var noImage = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints bc) {
        var size = min(bc.maxHeight, bc.maxWidth) * 0.4;
        return Center(
          child: Opacity(
            opacity: 0.3,
            child: Icon(
              Icons.image_outlined,
              size: size,
            ),
          ),
        );
      },
    );

    if (Service.settingsService.pref_getScryfallImages && widget.cardSet != null) {
      if (_valid) {
        if (_ready) {
          return Stack(
            children: [
              Center(
                child: Padding(
                  padding: widget.iconPadding,
                  child: const CircularProgressIndicator(),
                ),
              ),
              Image.network(
                _imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => brokenImage,
              ),
            ],
          );
        } else {
          return Center(
            child: Padding(
              padding: widget.iconPadding,
              child: const CircularProgressIndicator(),
            ),
          );
        }
      } else {
        return Padding(
          padding: widget.iconPadding,
          child: brokenImage,
        );
      }
    } else {
      return Padding(
        padding: widget.iconPadding,
        child: noImage,
      );
    }
  }
}
