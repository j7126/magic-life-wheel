import 'package:flutter/material.dart';

extension Darken on Color {
  Color darken(double amount) {
    amount = amount.clamp(0.0, 1.0);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
