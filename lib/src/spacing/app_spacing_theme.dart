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

  /// Comfortable preset: balanced for standard mobile and web interfaces.
  factory AppSpacingTheme.comfortable() => const AppSpacingTheme(
    insetSquish: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    insetSm: EdgeInsets.all(8),
    insetMd: EdgeInsets.all(16),
    insetLg: EdgeInsets.all(24),
    gapXs: 6,
    gapSm: 12,
    gapMd: 16,
    gapLg: 24,
    touchTargetMin: 48.0,
  );

  /// Compact preset: pure high-density layout for desktop, spreadsheets, and admin tools.
  factory AppSpacingTheme.compact() => const AppSpacingTheme(
    insetSquish: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    insetSm: EdgeInsets.all(4),
    insetMd: EdgeInsets.all(10),
    insetLg: EdgeInsets.all(16),
    gapXs: 4,
    gapSm: 6,
    gapMd: 10,
    gapLg: 16,
    touchTargetMin: 0.0,
  );

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
