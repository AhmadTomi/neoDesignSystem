import 'package:flutter/material.dart';
import '../color/app_color_theme.dart';
import '../shape/app_radius_theme.dart';
import '../spacing/app_spacing_theme.dart';

/// Convenient extension getters on [BuildContext] for instant design token access.
extension DesignTokensContext on BuildContext {
  /// Active [AppColorTheme] instance (OKLCH tiered palette).
  AppColorTheme get color =>
      Theme.of(this).extension<AppColorTheme>() ??
      AppColorTheme.fromColor(anchorColor: const Color(0xFFF4F5F7), isDark: false);

  /// Backwards-compatibility alias for [color].
  AppColorTheme get palette => color;

  /// Shortcut to [AppColorTheme.containerBorder].
  Color get containerBorder => color.containerBorder;

  /// Semantic alias for [containerBorder].
  Color get border => color.containerBorder;

  /// Constant white color for text on dark/solid widgets across both themes.
  Color get white => color.white;

  /// Active [AppRadiusTheme] instance (directional corner radii).
  AppRadiusTheme get radius =>
      Theme.of(this).extension<AppRadiusTheme>() ?? AppRadiusTheme.rounded();

  /// Active [AppSpacingTheme] instance (insets, gaps, and SizedBox helpers).
  AppSpacingTheme get spacing =>
      Theme.of(this).extension<AppSpacingTheme>() ?? AppSpacingTheme.comfortable();

  /// Shortcut to active [TextTheme].
  TextTheme get text => Theme.of(this).textTheme;
}
