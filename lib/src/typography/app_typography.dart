import 'package:flutter/material.dart';
import 'text_style_extensions.dart';

/// Single-font typography geometry and scale for the Design System.
@immutable
class AppTypography {
  final String fontFamily;

  // Headings
  final TextStyle titleLg;
  final TextStyle titleMd;
  final TextStyle titleSm;

  // Body content
  final TextStyle bodyLg;
  final TextStyle bodyMd;
  final TextStyle bodySm;

  // Labels & Micro content
  final TextStyle labelMd;
  final TextStyle labelSm;

  const AppTypography({
    required this.fontFamily,
    required this.titleLg,
    required this.titleMd,
    required this.titleSm,
    required this.bodyLg,
    required this.bodyMd,
    required this.bodySm,
    required this.labelMd,
    required this.labelSm,
  });

  /// Snaps a double value to the nearest 0.5 step for crisp pixel alignment.
  static double _snapToHalf(double value) => (value * 2).round() / 2;

  /// Multiplier ratios relative to [baseFontSize] (derived from standard 14.0 base).
  static const double titleLgMultiplier = 20.0 / 14.0;
  static const double titleMdMultiplier = 16.0 / 14.0;
  static const double titleSmMultiplier = 1.0;
  static const double bodyLgMultiplier = 16.0 / 14.0;
  static const double bodyMdMultiplier = 1.0;
  static const double bodySmMultiplier = 13.0 / 14.0;
  static const double labelMdMultiplier = 13.0 / 14.0;
  static const double labelSmMultiplier = 11.0 / 14.0;

  /// Factory creating font geometry tailored for comfortable or compact density
  /// derived proportionally from a single [baseFontSize] anchor, with optional [minFontWeight] clamping.
  factory AppTypography.create({
    String fontFamily = 'Inter',
    double baseFontSize = 14.0,
    bool isCompact = false,
    FontWeight? minFontWeight,
  }) {
    final double effectiveBase = isCompact ? baseFontSize - 1.0 : baseFontSize;

    final double hTitle = isCompact ? 1.20 : 1.35;
    final double hBody = isCompact ? 1.20 : 1.45;
    final double hLabel = isCompact ? 1.10 : 1.20;

    FontWeight clampWeight(FontWeight original) {
      if (minFontWeight == null) return original;
      return original.value < minFontWeight.value ? minFontWeight : original;
    }

    return AppTypography(
      fontFamily: fontFamily,
      titleLg: TextStyle(
        fontFamily: fontFamily,
        fontSize: _snapToHalf(effectiveBase * titleLgMultiplier),
        fontWeight: clampWeight(FontWeight.w600),
        height: hTitle,
      ),
      titleMd: TextStyle(
        fontFamily: fontFamily,
        fontSize: _snapToHalf(effectiveBase * titleMdMultiplier),
        fontWeight: clampWeight(FontWeight.w600),
        height: hTitle,
      ),
      titleSm: TextStyle(
        fontFamily: fontFamily,
        fontSize: _snapToHalf(effectiveBase * titleSmMultiplier),
        fontWeight: clampWeight(FontWeight.w600),
        height: hTitle,
      ),
      bodyLg: TextStyle(
        fontFamily: fontFamily,
        fontSize: _snapToHalf(effectiveBase * bodyLgMultiplier),
        fontWeight: clampWeight(FontWeight.w400),
        height: hBody,
      ),
      bodyMd: TextStyle(
        fontFamily: fontFamily,
        fontSize: _snapToHalf(effectiveBase * bodyMdMultiplier),
        fontWeight: clampWeight(FontWeight.w400),
        height: hBody,
      ),
      bodySm: TextStyle(
        fontFamily: fontFamily,
        fontSize: _snapToHalf(effectiveBase * bodySmMultiplier),
        fontWeight: clampWeight(FontWeight.w400),
        height: hBody,
      ),
      labelMd: TextStyle(
        fontFamily: fontFamily,
        fontSize: _snapToHalf(effectiveBase * labelMdMultiplier),
        fontWeight: clampWeight(FontWeight.w500),
        height: hLabel,
      ),
      labelSm: TextStyle(
        fontFamily: fontFamily,
        fontSize: _snapToHalf(effectiveBase * labelSmMultiplier),
        fontWeight: clampWeight(FontWeight.w500),
        height: hLabel,
      ),
    );
  }

  /// Builds a standard Flutter [TextTheme] using this typography and the given [textMain].
  TextTheme toTextTheme(Color textMain) {
    return TextTheme(
      headlineMedium: titleLg.withMain(textMain),
      titleLarge: titleLg.withMain(textMain),
      titleMedium: titleMd.withMain(textMain),
      titleSmall: titleSm.withMain(textMain),
      bodyLarge: bodyLg.withMain(textMain),
      bodyMedium: bodyMd.withMain(textMain),
      bodySmall: bodySm.withSecondary(textMain),
      labelLarge: labelMd.withMain(textMain),
      labelMedium: labelMd.withSecondary(textMain),
      labelSmall: labelSm.withMuted(textMain),
    );
  }

  /// Returns a new [AppTypography] where all styles with a [FontWeight] below [minWeight]
  /// are elevated to [minWeight], while styles already at or above [minWeight] remain untouched.
  AppTypography withMinWeight(FontWeight? minWeight) {
    if (minWeight == null) return this;
    return AppTypography(
      fontFamily: fontFamily,
      titleLg: titleLg.clampMinWeight(minWeight)!,
      titleMd: titleMd.clampMinWeight(minWeight)!,
      titleSm: titleSm.clampMinWeight(minWeight)!,
      bodyLg: bodyLg.clampMinWeight(minWeight)!,
      bodyMd: bodyMd.clampMinWeight(minWeight)!,
      bodySm: bodySm.clampMinWeight(minWeight)!,
      labelMd: labelMd.clampMinWeight(minWeight)!,
      labelSm: labelSm.clampMinWeight(minWeight)!,
    );
  }

  AppTypography copyWith({
    String? fontFamily,
    TextStyle? titleLg,
    TextStyle? titleMd,
    TextStyle? titleSm,
    TextStyle? bodyLg,
    TextStyle? bodyMd,
    TextStyle? bodySm,
    TextStyle? labelMd,
    TextStyle? labelSm,
  }) {
    return AppTypography(
      fontFamily: fontFamily ?? this.fontFamily,
      titleLg: titleLg ?? this.titleLg,
      titleMd: titleMd ?? this.titleMd,
      titleSm: titleSm ?? this.titleSm,
      bodyLg: bodyLg ?? this.bodyLg,
      bodyMd: bodyMd ?? this.bodyMd,
      bodySm: bodySm ?? this.bodySm,
      labelMd: labelMd ?? this.labelMd,
      labelSm: labelSm ?? this.labelSm,
    );
  }
}
