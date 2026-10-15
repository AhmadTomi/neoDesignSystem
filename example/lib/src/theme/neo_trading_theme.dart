import 'package:flutter/material.dart';
import 'package:neo_design_system/neo_design_system.dart';

/// Custom showcase preset for Neo Trading interface.
class NeoTradingTheme {
  static const ThemePreset preset = ThemePreset(
    id: 'neo_trading',
    name: 'Neo Trading',
    description:
        'Specialized trading interface with high contrast and compact metrics.',
    lightAnchor: Color(0xFFFCFDFD),
    darkAnchor: Color(0xFF1A1A1A),
    primaryColor: Color(0xFF1D65AB),
    darkPrimaryColor: Color(0xFF1D65AB),
    errorColor: Color(0xFFFE3E3F),
    warningColor: Color(0xFFF2960E),
    infoColor: Color(0xff417BD2),
    successColor: Color(0xFF07B667),
    darkSuccessColor: Color(0xFF07B667),
    lightSuccessColor: Color(0xFF417BD2),
    whiteColor: Color(0xFFC5C5C7),
    shape: ShapePreset.rounded,
    density: DensityPreset.compact,
    fontFamily: 'Inter',
    baseFontSize: 13,
    baseRadius: 4,
    baseSpacing: 8,
  );

  /// Backwards compatibility alias for [preset].
  static ThemePreset get theme => preset;
}
