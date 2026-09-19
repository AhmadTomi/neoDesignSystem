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

  /// Factory creating font geometry tailored for comfortable or compact density.
  factory AppTypography.create({
    String fontFamily = 'Inter',
    bool isCompact = false,
  }) {
    final double hTitle = isCompact ? 1.20 : 1.35;
    final double hBody = isCompact ? 1.20 : 1.45;
    final double hLabel = isCompact ? 1.10 : 1.20;

    return AppTypography(
      fontFamily: fontFamily,
      titleLg: TextStyle(
        fontFamily: fontFamily,
        fontSize: isCompact ? 18 : 20,
        fontWeight: FontWeight.w600,
        height: hTitle,
      ),
      titleMd: TextStyle(
        fontFamily: fontFamily,
        fontSize: isCompact ? 15 : 16,
        fontWeight: FontWeight.w600,
        height: hTitle,
      ),
      titleSm: TextStyle(
        fontFamily: fontFamily,
        fontSize: isCompact ? 13 : 14,
        fontWeight: FontWeight.w600,
        height: hTitle,
      ),
      bodyLg: TextStyle(
        fontFamily: fontFamily,
        fontSize: isCompact ? 15 : 16,
        fontWeight: FontWeight.w400,
        height: hBody,
      ),
      bodyMd: TextStyle(
        fontFamily: fontFamily,
        fontSize: isCompact ? 13.5 : 14,
        fontWeight: FontWeight.w400,
        height: hBody,
      ),
      bodySm: TextStyle(
        fontFamily: fontFamily,
        fontSize: isCompact ? 12 : 13,
        fontWeight: FontWeight.w400,
        height: hBody,
      ),
      labelMd: TextStyle(
        fontFamily: fontFamily,
        fontSize: isCompact ? 12 : 13,
        fontWeight: FontWeight.w500,
        height: hLabel,
      ),
      labelSm: TextStyle(
        fontFamily: fontFamily,
        fontSize: isCompact ? 10.5 : 11,
        fontWeight: FontWeight.w500,
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
