import 'package:flutter/material.dart';

extension Lighten on Color {
  Color lighten(double amount) {
    amount = amount.clamp(0.0, 1.0);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}
