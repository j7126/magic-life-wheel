// workaround from https://github.com/flutter/flutter/issues/188035#issuecomment-4769262102

import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// A drop-in replacement for [Icon] that renders [shadows] through a
/// compositor-based [Stack] of blurred glyph layers instead of the framework's
/// default [TextStyle.shadows] path.
///
/// ## Why this exists
///
/// https://github.com/flutter/flutter/issues/188035
/// https://github.com/flutter/flutter/issues/187361 — icon shadows drawn
/// through the default text-shadow path render unstably in production on both
/// Android and iOS, and the upstream fix has no committed timeline. Until it
/// lands we paint icon shadows ourselves, which avoids the broken code path
/// entirely while keeping the visual result.
///
/// This is a **temporary workaround**. Once the Flutter SDK fixes the issue,
/// delete this file and rename every `IconX(` back to `Icon(` — the full
/// revert recipe and the list of touched call sites live in
/// `docs/iconx-shadow-workaround.md`.
///
/// ## Behaviour
///
/// * When [shadows] (and the ambient [IconThemeData.shadows]) is null or empty,
///   [IconX] delegates verbatim to a plain [Icon] — zero behavioural change and
///   the buggy path is never reached.
/// * When shadows are present, each [Shadow] is painted as an offset, blurred,
///   recoloured copy of the glyph stacked *beneath* the real icon, reproducing
///   [Shadow.color] / [Shadow.offset] / [Shadow.blurRadius] via [ImageFiltered]
///   + [Transform.translate]. The visible icon, its colour, its [blendMode] and
///   its semantics are unchanged, and the layout footprint stays identical to
///   [Icon] (shadows overflow the glyph box without affecting size, exactly as
///   the framework does).
///
/// The constructor mirrors [Icon] (Flutter 3.44) field-for-field so call sites
/// can be renamed mechanically (`Icon(` -> `IconX(`).
class IconX extends StatelessWidget {
  const IconX(
    this.icon, {
    super.key,
    this.size,
    this.fill,
    this.weight,
    this.grade,
    this.opticalSize,
    this.color,
    this.shadows,
    this.semanticLabel,
    this.textDirection,
    this.applyTextScaling,
    this.blendMode,
    this.fontWeight,
  })  : assert(fill == null || (fill >= 0.0 && fill <= 1.0)),
        assert(weight == null || weight > 0.0),
        assert(opticalSize == null || opticalSize > 0.0);

  final IconData? icon;
  final double? size;
  final double? fill;
  final double? weight;
  final double? grade;
  final double? opticalSize;
  final Color? color;
  final List<Shadow>? shadows;
  final String? semanticLabel;
  final TextDirection? textDirection;
  final bool? applyTextScaling;
  final BlendMode? blendMode;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    // Mirror Icon's own shadow resolution: explicit shadows win, otherwise the
    // ambient IconTheme's shadows. Keeps IconX a faithful drop-in even for
    // theme-provided shadows.
    final resolvedShadows = shadows ?? IconTheme.of(context).shadows;

    // No shadows -> identical to a plain Icon; the buggy path is never reached.
    if (resolvedShadows == null || resolvedShadows.isEmpty) {
      return _glyph(
        color: color,
        semanticLabel: semanticLabel,
        blendMode: blendMode,
      );
    }

    return Stack(
      // Shadows may overflow the glyph box; never clip them, matching Icon.
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: <Widget>[
        for (final shadow in resolvedShadows)
          _ShadowedGlyph(
            shadow: shadow,
            // Shadow layers are decorative: recoloured to the shadow colour, no
            // foreground blendMode, and no semantics. Neutralise the ambient
            // IconTheme so (a) opacity never dims the shadow colour — the real
            // Icon never scales shadows by opacity — and (b) theme shadows are
            // not re-resolved through the broken framework path.
            child: ExcludeSemantics(
              child: IconTheme.merge(
                data: const IconThemeData(opacity: 1.0, shadows: <Shadow>[]),
                child: _glyph(
                  color: shadow.color,
                  semanticLabel: null,
                  blendMode: null,
                ),
              ),
            ),
          ),
        // The real icon on top keeps the ambient theme colour/opacity (so it
        // matches a plain Icon) and carries blendMode + semantics, but theme
        // shadows are cleared — IconX has already lifted them into the layers
        // above, so they must not be re-painted through the broken path.
        IconTheme.merge(
          data: const IconThemeData(shadows: <Shadow>[]),
          child: _glyph(
            color: color,
            semanticLabel: semanticLabel,
            blendMode: blendMode,
          ),
        ),
      ],
    );
  }

  /// Builds a plain [Icon] with the mirrored styling but **no** [shadows] of its
  /// own — shadows are drawn as separate layers, so the framework's shadow path
  /// is never exercised. [color], [semanticLabel] and [blendMode] are supplied
  /// per layer (shadow layers recolour the glyph and drop semantics/blendMode).
  Icon _glyph({
    required Color? color,
    required String? semanticLabel,
    required BlendMode? blendMode,
  }) {
    return Icon(
      icon,
      size: size,
      fill: fill,
      weight: weight,
      grade: grade,
      opticalSize: opticalSize,
      color: color,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
      applyTextScaling: applyTextScaling,
      blendMode: blendMode,
      fontWeight: fontWeight,
    );
  }
}

/// Paints [child] offset and blurred to reproduce a single [Shadow], without
/// affecting the layout footprint — matching how [Icon] paints shadows.
class _ShadowedGlyph extends StatelessWidget {
  const _ShadowedGlyph({required this.shadow, required this.child});

  final Shadow shadow;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // [child] is a single-colour glyph silhouette (the shadow colour). A
    // premultiplied-alpha Gaussian blur of a uniform-colour shape preserves the
    // hue and only feathers the alpha — i.e. it is equivalent to the framework's
    // MaskFilter.blur(BlurStyle.normal) over the glyph mask. We use the same
    // radius->sigma conversion so the blur matches the original visual.
    final sigma = Shadow.convertRadiusToSigma(shadow.blurRadius);
    var glyph = child;
    if (shadow.blurRadius > 0) {
      glyph = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: sigma,
          sigmaY: sigma,
          tileMode: ui.TileMode.decal,
        ),
        child: glyph,
      );
    }
    return Transform.translate(offset: shadow.offset, child: glyph);
  }
}
