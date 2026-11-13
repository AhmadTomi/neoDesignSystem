import 'dart:ui';
import 'package:flutter/material.dart';

import '../spacing/app_spacing_theme.dart';

/// ThemeExtension for the heights of interactive controls.
///
/// Every control that sits in a row with others (buttons, text fields,
/// dropdowns, segmented tabs, search boxes) should take its height from this
/// scale so neighbouring controls always line up.
///
/// - [xs]: badges, inline chips, controls inside dense table rows.
/// - [sm]: tab bars, toolbar buttons, filters inside panel headers.
/// - [md]: the default for form fields, dropdowns, and buttons.
/// - [lg]: primary call-to-action buttons (submit order, login).
@immutable
class AppControlSizeTheme extends ThemeExtension<AppControlSizeTheme> {
  final double xs;
  final double sm;
  final double md;
  final double lg;

  /// Icon size that fits inside a [md] control.
  final double iconSize;

  const AppControlSizeTheme({
    this.xs = 25,
    this.sm = 30,
    this.md = 38,
    this.lg = 46,
    this.iconSize = 18,
  });

  /// Default [md] height for each density.
  static double defaultBaseHeight(DensityPreset density) =>
      density == DensityPreset.compact ? 30.0 : 38.0;

  /// Creates a scale proportional to [baseControlHeight] (the [md] height).
  ///
  /// When [baseControlHeight] is null, the density default is used
  /// (30 for compact, 38 for comfortable). Heights are rounded to whole
  /// pixels so borders stay crisp.
  factory AppControlSizeTheme.create({
    double? baseControlHeight,
    DensityPreset density = DensityPreset.comfortable,
  }) {
    final md = (baseControlHeight ?? defaultBaseHeight(density)).roundToDouble();
    return AppControlSizeTheme(
      xs: (md * 2 / 3).roundToDouble(),
      sm: (md * 0.8).roundToDouble(),
      md: md,
      lg: (md * 1.2).roundToDouble(),
      iconSize: (md * 0.5).clamp(14.0, 22.0).roundToDouble(),
    );
  }

  /// Vertical content padding that makes a dense text field exactly
  /// [controlHeight] tall (defaults to [md]) for text with [lineHeight].
  ///
  /// A dense `InputDecorator` paints its border around its content, so
  /// `InputDecoration.constraints.minHeight` alone leaves the border short.
  /// The padding never drops below [minPadding].
  double fieldVerticalPadding(
    double lineHeight, {
    double? controlHeight,
    double minPadding = 2.0,
  }) {
    final raw = ((controlHeight ?? md) - lineHeight) / 2;
    final snapped = (raw * 2).round() / 2;
    return snapped < minPadding ? minPadding : snapped;
  }

  @override
  AppControlSizeTheme copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? iconSize,
  }) {
    return AppControlSizeTheme(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      iconSize: iconSize ?? this.iconSize,
    );
  }

  @override
  AppControlSizeTheme lerp(ThemeExtension<AppControlSizeTheme>? other, double t) {
    if (other is! AppControlSizeTheme) return this;
    return AppControlSizeTheme(
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      iconSize: lerpDouble(iconSize, other.iconSize, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppControlSizeTheme &&
          xs == other.xs &&
          sm == other.sm &&
          md == other.md &&
          lg == other.lg &&
          iconSize == other.iconSize;

  @override
  int get hashCode => Object.hash(xs, sm, md, lg, iconSize);

  @override
  String toString() => 'AppControlSizeTheme(xs: $xs, sm: $sm, md: $md, lg: $lg, icon: $iconSize)';
}
