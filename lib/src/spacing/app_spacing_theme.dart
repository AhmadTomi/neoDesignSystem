import 'dart:ui';
import 'package:flutter/material.dart';

/// Enum representing the density and spacing profile.
enum DensityPreset {
  comfortable,
  compact,
}

/// ThemeExtension for the Design System's spacing, insets, and gap helpers.
@immutable
class AppSpacingTheme extends ThemeExtension<AppSpacingTheme> {
  // Insets (Padding for closed components)
  final EdgeInsets insetSquish; // Buttons, TextFields, Chips (slender vertical)
  final EdgeInsets insetSm;     // List items, compact panels
  final EdgeInsets insetMd;     // Normal cards (C2, C3)
  final EdgeInsets insetLg;     // Dialogs, floating sheets (C4)

  // Gaps (Raw scalar distance values)
  final double gapXs;  // Micro: 4-6px (Icon to text)
  final double gapSm;  // Form: 6-12px (Field to field)
  final double gapMd;  // Section: 10-16px (Card to card)
  final double gapLg;  // Large: 16-24px (Major layout divider)

  /// Minimum touch target size (48px for comfortable, 0px for pure dense compact layout).
  final double touchTargetMin;

  const AppSpacingTheme({
    required this.insetSquish,
    required this.insetSm,
    required this.insetMd,
    required this.insetLg,
    required this.gapXs,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
    this.touchTargetMin = 48.0,
  });

  /// Snaps a double value to the nearest 0.5 step for crisp pixel alignment.
  static double _snapToHalf(double value) => (value * 2).round() / 2;

  /// Comfortable preset: balanced for standard mobile and web interfaces.
  factory AppSpacingTheme.comfortable() => AppSpacingTheme.create(
    baseSpacing: 16.0,
    density: DensityPreset.comfortable,
  );

  /// Compact preset: pure high-density layout for desktop, spreadsheets, and admin tools.
  factory AppSpacingTheme.compact() => AppSpacingTheme.create(
    baseSpacing: 10.0,
    density: DensityPreset.compact,
  );

  /// Creates an [AppSpacingTheme] scaling proportionally from a [baseSpacing] anchor.
  /// Standard comfortable defaults to 16.0 base spacing; compact defaults to 10.0.
  factory AppSpacingTheme.create({
    double baseSpacing = 16.0,
    DensityPreset density = DensityPreset.comfortable,
  }) {
    final isCompact = density == DensityPreset.compact;

    // Multipliers relative to comfortable base 16
    final gapXs = _snapToHalf(baseSpacing * (isCompact ? (4.0 / 10.0) : (6.0 / 16.0)));
    final gapSm = _snapToHalf(baseSpacing * (isCompact ? (6.0 / 10.0) : (12.0 / 16.0)));
    final gapMd = _snapToHalf(baseSpacing);
    final gapLg = _snapToHalf(baseSpacing * (isCompact ? (16.0 / 10.0) : (24.0 / 16.0)));

    final squishH = _snapToHalf(baseSpacing * (isCompact ? (8.0 / 10.0) : (14.0 / 16.0)));
    final squishV = _snapToHalf(baseSpacing * (isCompact ? (4.0 / 10.0) : (10.0 / 16.0)));
    final padSm = _snapToHalf(baseSpacing * (isCompact ? (4.0 / 10.0) : (8.0 / 16.0)));
    final padMd = _snapToHalf(baseSpacing);
    final padLg = _snapToHalf(baseSpacing * (isCompact ? (16.0 / 10.0) : (24.0 / 16.0)));

    return AppSpacingTheme(
      insetSquish: EdgeInsets.symmetric(horizontal: squishH, vertical: squishV),
      insetSm: EdgeInsets.all(padSm),
      insetMd: EdgeInsets.all(padMd),
      insetLg: EdgeInsets.all(padLg),
      gapXs: gapXs,
      gapSm: gapSm,
      gapMd: gapMd,
      gapLg: gapLg,
      touchTargetMin: isCompact ? 0.0 : 48.0,
    );
  }

  // Ergonomic SizedBox widget shortcuts
  SizedBox get vGapXs => SizedBox(height: gapXs);
  SizedBox get vGapSm => SizedBox(height: gapSm);
  SizedBox get vGapMd => SizedBox(height: gapMd);
  SizedBox get vGapLg => SizedBox(height: gapLg);

  SizedBox get hGapXs => SizedBox(width: gapXs);
  SizedBox get hGapSm => SizedBox(width: gapSm);
  SizedBox get hGapMd => SizedBox(width: gapMd);
  SizedBox get hGapLg => SizedBox(width: gapLg);

  @override
  AppSpacingTheme copyWith({
    EdgeInsets? insetSquish,
    EdgeInsets? insetSm,
    EdgeInsets? insetMd,
    EdgeInsets? insetLg,
    double? gapXs,
    double? gapSm,
    double? gapMd,
    double? gapLg,
    double? touchTargetMin,
  }) {
    return AppSpacingTheme(
      insetSquish: insetSquish ?? this.insetSquish,
      insetSm: insetSm ?? this.insetSm,
      insetMd: insetMd ?? this.insetMd,
      insetLg: insetLg ?? this.insetLg,
      gapXs: gapXs ?? this.gapXs,
      gapSm: gapSm ?? this.gapSm,
      gapMd: gapMd ?? this.gapMd,
      gapLg: gapLg ?? this.gapLg,
      touchTargetMin: touchTargetMin ?? this.touchTargetMin,
    );
  }

  @override
  AppSpacingTheme lerp(ThemeExtension<AppSpacingTheme>? other, double t) {
    if (other is! AppSpacingTheme) return this;
    return AppSpacingTheme(
      insetSquish: EdgeInsets.lerp(insetSquish, other.insetSquish, t)!,
      insetSm: EdgeInsets.lerp(insetSm, other.insetSm, t)!,
      insetMd: EdgeInsets.lerp(insetMd, other.insetMd, t)!,
      insetLg: EdgeInsets.lerp(insetLg, other.insetLg, t)!,
      gapXs: lerpDouble(gapXs, other.gapXs, t)!,
      gapSm: lerpDouble(gapSm, other.gapSm, t)!,
      gapMd: lerpDouble(gapMd, other.gapMd, t)!,
      gapLg: lerpDouble(gapLg, other.gapLg, t)!,
      touchTargetMin: lerpDouble(touchTargetMin, other.touchTargetMin, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSpacingTheme &&
          runtimeType == other.runtimeType &&
          insetSquish == other.insetSquish &&
          insetMd == other.insetMd &&
          gapSm == other.gapSm &&
          gapMd == other.gapMd;

  @override
  int get hashCode => Object.hash(insetSquish, insetSm, insetMd, insetLg, gapSm, gapMd);
}
