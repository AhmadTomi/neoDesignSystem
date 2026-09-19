import 'package:flutter/material.dart';

/// Fluent extension on nullable [TextStyle] for OpenType font features and color chaining.
extension SingleFontFeaturesX on TextStyle? {
  /// Converts numbers to fixed-width (monospaced) within the same font family.
  /// Ideal for financial data tables, invoices, stopwatches, and balance cards.
  TextStyle? get tabular => this?.copyWith(
    fontFeatures: [
      ...?this?.fontFeatures,
      const FontFeature.tabularFigures(),
    ],
  );

  /// Renders zero digits with a diagonal slash ('0') to distinguish from capital letter 'O'.
  TextStyle? get slashZero => this?.copyWith(
    fontFeatures: [
      ...?this?.fontFeatures,
      const FontFeature.slashedZero(),
    ],
  );

  /// Fluent helper to set an explicit [Color].
  TextStyle? withColor(Color color) => this?.copyWith(color: color);

  /// Applies high-emphasis color (100% alpha [textMain]).
  TextStyle? withMain(Color textMain) => this?.copyWith(color: textMain);

  /// Applies medium-emphasis color (72% alpha [textMain]) for subtitles and descriptions.
  TextStyle? withSecondary(Color textMain) =>
      this?.copyWith(color: textMain.withValues(alpha: 0.72));

  /// Applies low-emphasis color (50% alpha [textMain]) for placeholders, captions, and footnotes.
  TextStyle? withMuted(Color textMain) =>
      this?.copyWith(color: textMain.withValues(alpha: 0.50));

  /// Applies disabled color (38% alpha [textMain]) for non-interactive elements.
  TextStyle? withDisabled(Color textMain) =>
      this?.copyWith(color: textMain.withValues(alpha: 0.38));

  /// Clamps this TextStyle's font weight to be at least [minWeight].
  /// If the current font weight is below [minWeight], it is elevated to [minWeight].
  /// If the current font weight is greater than or equal to [minWeight], it remains unchanged.
  TextStyle? clampMinWeight(FontWeight? minWeight) {
    if (minWeight == null || this == null) return this;
    final current = this!.fontWeight ?? FontWeight.w400;
    if (current.value < minWeight.value) {
      return this!.copyWith(fontWeight: minWeight);
    }
    return this;
  }
}
