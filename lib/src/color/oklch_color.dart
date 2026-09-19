import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Helper class for converting OKLCH color coordinates to Flutter [Color].
///
/// Formula pipeline:
/// OKLCH (L, C, H) -> OKLab (L, a, b) -> Linear LMS -> Linear sRGB -> Standard sRGB (Color)
class OklchColor {
  /// Perceptual lightness in the range [0.0, 1.0].
  final double l;

  /// Chroma (color intensity / saturation), >= 0.0.
  final double c;

  /// Hue angle in degrees in the range [0.0, 360.0).
  final double h;

  const OklchColor(this.l, this.c, this.h);

  /// Converts OKLCH to a Flutter [Color] with the given [alpha] (0.0 to 1.0).
  Color toColor({double alpha = 1.0}) {
    // 1. OKLCH to OKLab
    final hRad = h * (math.pi / 180.0);
    final a = c * math.cos(hRad);
    final b = c * math.sin(hRad);

    // 2. OKLab to non-linear LMS
    final l_ = l + 0.3963377774 * a + 0.2158037573 * b;
    final m_ = l - 0.1055613458 * a - 0.0638541728 * b;
    final s_ = l - 0.0894841775 * a - 1.2914855480 * b;

    // Cube to obtain linear LMS
    final lLin = l_ * l_ * l_;
    final mLin = m_ * m_ * m_;
    final sLin = s_ * s_ * s_;

    // 3. Linear LMS to Linear sRGB (Björn Ottosson inverse matrix)
    final rLin =
        4.0767416621 * lLin - 3.3077115913 * mLin + 0.2309699292 * sLin;
    final gLin =
        -1.2684380046 * lLin + 2.6097574011 * mLin - 0.3413193965 * sLin;
    final bLin =
        -0.0041960863 * lLin - 0.7034186147 * mLin + 1.7076147010 * sLin;

    // 4. Linear sRGB to standard sRGB (gamma transfer function)
    final rSrgb = _linearToSrgb(rLin);
    final gSrgb = _linearToSrgb(gLin);
    final bSrgb = _linearToSrgb(bLin);

    // Quantize to 8-bit channels [0..255]
    final rInt = (rSrgb * 255.0).round().clamp(0, 255);
    final gInt = (gSrgb * 255.0).round().clamp(0, 255);
    final bInt = (bSrgb * 255.0).round().clamp(0, 255);
    final aInt = (alpha * 255.0).round().clamp(0, 255);

    return Color.fromARGB(aInt, rInt, gInt, bInt);
  }

  /// Converts a standard Flutter [Color] into [OklchColor].
  factory OklchColor.fromColor(Color color) {
    // 1. sRGB [0..1] to Linear sRGB (gamma decode)
    final r = _srgbToLinear(color.r);
    final g = _srgbToLinear(color.g);
    final b = _srgbToLinear(color.b);

    // 2. Linear sRGB to Linear LMS (Björn Ottosson matrix)
    final lLin = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b;
    final mLin = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b;
    final sLin = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b;

    // 3. Non-linear LMS (cube root)
    final l_ = _cbrt(lLin);
    final m_ = _cbrt(mLin);
    final s_ = _cbrt(sLin);

    // 4. LMS to OKLab (L, a, b)
    final lVal = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_;
    final aVal = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_;
    final bVal = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_;

    // 5. OKLab to OKLCH (L, C, H)
    final cVal = math.sqrt(aVal * aVal + bVal * bVal);
    var hRad = math.atan2(bVal, aVal);
    var hDeg = hRad * (180.0 / math.pi);
    if (hDeg < 0.0) hDeg += 360.0;

    return OklchColor(lVal.clamp(0.0, 1.0), math.max(0.0, cVal), hDeg % 360.0);
  }

  static double _cbrt(double x) {
    if (x > 0.0) return math.pow(x, 1.0 / 3.0).toDouble();
    if (x < 0.0) return -math.pow(-x, 1.0 / 3.0).toDouble();
    return 0.0;
  }

  static double _srgbToLinear(double val) {
    final clamped = val.clamp(0.0, 1.0);
    if (clamped <= 0.04045) {
      return clamped / 12.92;
    } else {
      return math.pow((clamped + 0.055) / 1.055, 2.4).toDouble();
    }
  }

  /// Standard IEC 61966-2-1 sRGB gamma transfer function.
  static double _linearToSrgb(double value) {
    final clamped = value.clamp(0.0, 1.0);
    if (clamped <= 0.0031308) {
      return 12.92 * clamped;
    } else {
      return 1.055 * math.pow(clamped, 1.0 / 2.4) - 0.055;
    }
  }

  /// Returns 6-character hex string (e.g. #3B82F6).
  String get hexCode {
    final color = toColor();
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }
}
