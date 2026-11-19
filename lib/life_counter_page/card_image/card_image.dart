import 'dart:math';
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:magic_life_wheel/mtgjson/magic_life_wheel/generated/card_set.pb.dart';
import 'package:magic_life_wheel/static_service.dart';
import 'package:image/image.dart' as img;
import 'package:shimmer_animation/shimmer_animation.dart';

class CardImage extends StatefulWidget {
  const CardImage({
    super.key,
    required this.cardSet,
    this.partnerCard,
    this.iconPadding = EdgeInsets.zero,
    this.fullCard = false,
  });

  final CardSet? cardSet;
  final CardSet? partnerCard;
  final EdgeInsets iconPadding;
  final bool fullCard;

  @override
  State<CardImage> createState() => _CardImageState();
}

class _CardImageState extends State<CardImage> {
  bool _valid = true;
  late String _imageUrl;
  String? _partnerImageUrl;
  Uint8List? _artColorsGradient;
  Uint8List? _partnerArtColorsGradient;

  Uint8List? getArtColorsGradient(CardSet? card) {
    if (card == null || card.artColors.length != 12) {
      return null;
    }

    var image = img.Image(width: 4, height: 3);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final color = card.artColors[x + 3 * y];
        final pixel = image.getPixel(x, y);
        pixel.r = (color >> 16) & 0xFF;
        pixel.g = (color >> 8) & 0xFF;
        pixel.b = color & 0xFF;
      }
    }
    return img.encodePng(image, level: 1);
  }

  String? getImage(CardSet? card) {
    String? id = (card == null || !card.hasScryfallId()) ? null : card.scryfallId;
    if (id == null) {
      return null;
    }
    String fileFace = 'front';
    String dir1 = id[0];
    String dir2 = id[1];
    if (widget.fullCard) {
      return 'https://cards.scryfall.io/large/$fileFace/$dir1/$dir2/$id.jpg';
    } else {
      return 'https://cards.scryfall.io/art_crop/$fileFace/$dir1/$dir2/$id.jpg';
    }
  }

  void setup() {
    // loading gradient
    _artColorsGradient = getArtColorsGradient(widget.cardSet);
    _partnerArtColorsGradient = getArtColorsGradient(widget.partnerCard);

    // main image
    var url = getImage(widget.cardSet);
    if (url == null) {
      _valid = false;
    } else {
      _imageUrl = url;
    }

    // partner image
    _partnerImageUrl = getImage(widget.partnerCard);
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
          child: Icon(
            Icons.broken_image_outlined,
            size: size,
            color: const Color.fromARGB(255, 76, 76, 76),
          ),
        );
      },
    );

    var noImage = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints bc) {
        var size = min(bc.maxHeight, bc.maxWidth) * 0.4;
        return Center(
          child: Icon(
            Icons.image_outlined,
            size: size,
            color: const Color.fromARGB(255, 76, 76, 76),
          ),
        );
      },
    );

    if (Service.settingsService.pref_getScryfallImages && widget.cardSet != null) {
      if (_valid) {
        return Row(
          children: [
            Expanded(
              child: Image.network(
                _imageUrl,
                fit: BoxFit.cover,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => brokenImage,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) => frame != null
                    ? child
                    : SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Shimmer(
                          duration: Duration(seconds: 4),
                          interval: Duration(seconds: 0),
                          child: _artColorsGradient == null
                              ? Container()
                              : Image.memory(
                                  _artColorsGradient!,
                                  gaplessPlayback: true,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
              ),
            ),
            if (_partnerImageUrl != null)
              Expanded(
                child: Image.network(
                  _partnerImageUrl!,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => brokenImage,
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) => frame != null
                      ? child
                      : SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: Shimmer(
                            duration: Duration(seconds: 4),
                            interval: Duration(seconds: 0),
                            child: _partnerArtColorsGradient == null
                                ? Container()
                                : Image.memory(
                                    _partnerArtColorsGradient!,
                                    gaplessPlayback: true,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                ),
              ),
          ],
        );
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
