import 'dart:math';
import 'package:flutter/material.dart';
import 'package:magic_life_wheel/datamodel/background.dart';
import 'package:magic_life_wheel/life_counter_page/card_image/card_image.dart';

class BackgroundWidget extends StatelessWidget {
  const BackgroundWidget({
    super.key,
    required this.background,
    this.forceShowNoImageIcon = false,
    this.iconPadding = EdgeInsets.zero,
    this.showLoader = true,
  });

  final Background background;
  final bool forceShowNoImageIcon;
  final EdgeInsets iconPadding;
  final bool showLoader;

  @override
  Widget build(BuildContext context) {
    if (background.customImage != null) {
      return Image.memory(
        background.customImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
          return const Center(
            child: Text('This image type is not supported'),
          );
        },
      );
    }

    if (background.card != null) {
      return CardImage(
        key: Key((background.card?.uuid ?? '') + (background.cardPartner?.uuid ?? '')),
        cardSet: background.card,
        partnerCard: background.cardPartner,
        iconPadding: iconPadding,
        showLoader: showLoader,
      );
    }

    if (background.colors != null && background.colors!.isNotEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: background.colors!.length > 1
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: background.colors!,
                )
              : null,
          color: background.colors!.length > 1 ? null : background.colors!.first,
        ),
      );
    }

    if (forceShowNoImageIcon) {
      return Padding(
        padding: iconPadding,
        child: LayoutBuilder(
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
        ),
      );
    }

    return Container();
  }
}
