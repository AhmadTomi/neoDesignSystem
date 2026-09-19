import 'dart:ui';
import 'package:flutter/material.dart';

/// Enum representing the base shape personality preset.
enum ShapePreset {
  rounded,
  sharp,
}

/// A wrapper for corner radius providing convenient directional [BorderRadius] getters.
@immutable
class CornerRadius {
  final double value;

  const CornerRadius(this.value);

  /// Symmetrical border radius applied to all 4 corners.
  BorderRadius get all => BorderRadius.circular(value);

  /// Border radius applied only to top-left and top-right corners.
  BorderRadius get top => BorderRadius.vertical(top: Radius.circular(value));

  /// Border radius applied only to bottom-left and bottom-right corners.
  BorderRadius get bottom => BorderRadius.vertical(bottom: Radius.circular(value));

  /// Border radius applied only to top-left and bottom-left corners.
  BorderRadius get left => BorderRadius.horizontal(left: Radius.circular(value));

  /// Border radius applied only to top-right and bottom-right corners.
  BorderRadius get right => BorderRadius.horizontal(right: Radius.circular(value));

  /// Single [Radius] instance for use in paths or custom painters.
  Radius get asRadius => Radius.circular(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CornerRadius && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'CornerRadius($value)';
}

/// ThemeExtension for the Design System's corner radius scale.
@immutable
class AppRadiusTheme extends ThemeExtension<AppRadiusTheme> {
  final CornerRadius none;
  final CornerRadius xs;
  final CornerRadius sm;
  final CornerRadius md;
  final CornerRadius lg;
  final CornerRadius xl;
  final CornerRadius full;

  const AppRadiusTheme({
    this.none = const CornerRadius(0),
    this.xs = const CornerRadius(4),
    this.sm = const CornerRadius(6),
    this.md = const CornerRadius(10),
    this.lg = const CornerRadius(16),
    this.xl = const CornerRadius(24),
    this.full = const CornerRadius(9999),
  });

  /// Snaps a double value to the nearest 0.5 step for crisp pixel alignment.
  static double _snapToHalf(double value) => (value * 2).round() / 2;

  /// Modern rounded preset (friendly, rounded surfaces).
  factory AppRadiusTheme.rounded() => AppRadiusTheme.create(baseRadius: 12.0, shape: ShapePreset.rounded);

  /// Sharp enterprise preset (crisp, subtle radii for data-dense tools).
  factory AppRadiusTheme.sharp() => const AppRadiusTheme(
    none: CornerRadius(0),
    xs: CornerRadius(0),
    sm: CornerRadius(0),
    md: CornerRadius(0),
    lg: CornerRadius(0),
    xl: CornerRadius(0),
    full: CornerRadius(0),
  );

  /// Creates an [AppRadiusTheme] scaling proportionally from a [baseRadius] (default 12.0).
  /// If [shape] is [ShapePreset.sharp] or [baseRadius] is 0, returns a sharp radius theme.
  factory AppRadiusTheme.create({
    double baseRadius = 12.0,
    ShapePreset shape = ShapePreset.rounded,
  }) {
    if (shape == ShapePreset.sharp || baseRadius <= 0) {
      return AppRadiusTheme.sharp();
    }
    return AppRadiusTheme(
      none: const CornerRadius(0),
      xs: CornerRadius(_snapToHalf(baseRadius * (4.0 / 12.0))),
      sm: CornerRadius(_snapToHalf(baseRadius * (8.0 / 12.0))),
      md: CornerRadius(_snapToHalf(baseRadius)),
      lg: CornerRadius(_snapToHalf(baseRadius * (16.0 / 12.0))),
      xl: CornerRadius(_snapToHalf(baseRadius * (24.0 / 12.0))),
      full: const CornerRadius(9999),
    );
  }

  /// Calculates nested concentric corner radius: R_inner = max(0, R_outer - padding)
  CornerRadius nested({required CornerRadius outer, required double padding}) {
    final inner = outer.value - padding;
    return CornerRadius(inner > 0 ? inner : 0);
  }

  @override
  AppRadiusTheme copyWith({
    CornerRadius? none,
    CornerRadius? xs,
    CornerRadius? sm,
    CornerRadius? md,
    CornerRadius? lg,
    CornerRadius? xl,
    CornerRadius? full,
  }) {
    return AppRadiusTheme(
      none: none ?? this.none,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      full: full ?? this.full,
    );
  }

  @override
  AppRadiusTheme lerp(ThemeExtension<AppRadiusTheme>? other, double t) {
    if (other is! AppRadiusTheme) return this;
    return AppRadiusTheme(
      none: CornerRadius(lerpDouble(none.value, other.none.value, t)!),
      xs: CornerRadius(lerpDouble(xs.value, other.xs.value, t)!),
      sm: CornerRadius(lerpDouble(sm.value, other.sm.value, t)!),
      md: CornerRadius(lerpDouble(md.value, other.md.value, t)!),
      lg: CornerRadius(lerpDouble(lg.value, other.lg.value, t)!),
      xl: CornerRadius(lerpDouble(xl.value, other.xl.value, t)!),
      full: CornerRadius(lerpDouble(full.value, other.full.value, t)!),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppRadiusTheme &&
          runtimeType == other.runtimeType &&
          xs == other.xs &&
          sm == other.sm &&
          md == other.md &&
          lg == other.lg &&
          xl == other.xl;

  @override
  int get hashCode => Object.hash(none, xs, sm, md, lg, xl, full);
}
