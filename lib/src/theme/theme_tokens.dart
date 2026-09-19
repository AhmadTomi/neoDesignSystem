import 'package:flutter/material.dart';
import '../color/app_color_theme.dart';
import '../shape/app_radius_theme.dart';
import '../spacing/app_spacing_theme.dart';
import '../typography/app_typography.dart';

/// Bundle containing all active design token instances for a theme.
class ThemeTokens {
  final AppColorTheme color;
  final AppRadiusTheme radius;
  final AppSpacingTheme spacing;
  final AppTypography typography;

  const ThemeTokens({
    required this.color,
    required this.radius,
    required this.spacing,
    required this.typography,
  });
}

/// Callback allowing custom ThemeData overrides with full access to active [ThemeTokens].
typedef ThemeModifier = ThemeData Function(
  ThemeData baseTheme,
  ThemeTokens tokens,
);
