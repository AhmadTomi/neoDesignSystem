import 'package:flutter/material.dart';

import 'oklch_color.dart';

/// Lightness and saturation adjustments on [Color], computed in OKLCH.
///
/// OKLCH is perceptual: the same lightness step looks equally large on any
/// hue, and changing saturation (chroma) keeps the hue. Results are mapped
/// back into sRGB by lowering chroma (never by clipping channels), and the
/// original alpha is kept.
///
/// Lightness uses the OKLCH scale (0.0 black → 1.0 white). Saturation
/// amounts are relative: `saturate(0.2)` means 20% more chroma.
extension ColorAdjustX on Color {
  /// Perceptual lightness in OKLCH, 0.0 (black) to 1.0 (white).
  double get lightness => OklchColor.fromColor(this).l;

  /// Chroma (colorfulness) in OKLCH; 0.0 is a neutral gray.
  double get chroma => OklchColor.fromColor(this).c;

  /// Returns this color with lightness set to [lightness] (clamped to 0..1).
  Color withLightness(double lightness) =>
      _adjust((o) => o.copyWith(l: lightness.clamp(0.0, 1.0)));

  /// Raises lightness by [amount] on the 0..1 OKLCH scale (e.g. 0.1).
  Color lighten([double amount = 0.1]) =>
      _adjust((o) => o.copyWith(l: (o.l + amount).clamp(0.0, 1.0)));

  /// Lowers lightness by [amount] on the 0..1 OKLCH scale (e.g. 0.1).
  Color darken([double amount = 0.1]) =>
      _adjust((o) => o.copyWith(l: (o.l - amount).clamp(0.0, 1.0)));

  /// Multiplies chroma by `1 + amount` (e.g. 0.2 = 20% more saturated).
  /// Capped at what sRGB can show for this lightness and hue.
  Color saturate([double amount = 0.1]) => _scaleChroma(1 + amount);

  /// Multiplies chroma by `1 - amount` (e.g. 0.2 = 20% less saturated;
  /// 1.0 gives a neutral gray of the same lightness).
  Color desaturate([double amount = 0.1]) => _scaleChroma(1 - amount);

  /// Returns this color with chroma set to [chroma] (0.0 = gray). Capped at
  /// what sRGB can show for this lightness and hue.
  Color withChroma(double chroma) =>
      _adjust((o) => o.copyWith(c: chroma < 0 ? 0.0 : chroma));

  /// Returns a neutral gray with the same perceptual lightness.
  Color get grayscale => withChroma(0);

  Color _scaleChroma(double factor) =>
      _adjust((o) => o.copyWith(c: o.c * (factor < 0 ? 0.0 : factor)));

  Color _adjust(OklchColor Function(OklchColor) change) {
    final source = OklchColor.fromColor(this);
    final result = change(source);
    // A gray has no meaningful hue; keep it gray instead of tinting it.
    final adjusted =
        source.c < 1e-4 && result.c == source.c ? result.copyWith(c: 0) : result;
    return adjusted.toGamut().toColor(alpha: a);
  }
}
