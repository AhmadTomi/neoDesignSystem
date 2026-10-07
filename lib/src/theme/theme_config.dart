import 'package:flutter/material.dart';
import '../shape/app_radius_theme.dart';
import '../spacing/app_spacing_theme.dart';
import 'theme_preset.dart';

/// JSON serializable configuration model for exporting and importing theme presets.
class ThemeConfig {
  final String id;
  final String name;
  final String description;
  final String lightAnchorHex;
  final String darkAnchorHex;
  final String primaryHex;
  final String? darkPrimaryHex;
  final String? lightPrimaryHex;
  final String? errorHex;
  final String? darkErrorHex;
  final String? lightErrorHex;
  final String? warningHex;
  final String? darkWarningHex;
  final String? lightWarningHex;
  final String? infoHex;
  final String? darkInfoHex;
  final String? lightInfoHex;
  final String? successHex;
  final String? darkSuccessHex;
  final String? lightSuccessHex;
  final String? borderHex;
  final String? darkBorderHex;
  final String? lightBorderHex;
  final String? dividerHex;
  final String? darkDividerHex;
  final String? lightDividerHex;
  final String? whiteHex;
  final String shape;
  final double? baseRadius;
  final String density;
  final double? baseSpacing;
  final String? fontFamily;
  final double baseFontSize;
  final int? minFontWeightValue;

  const ThemeConfig({
    required this.id,
    required this.name,
    this.description = '',
    required this.lightAnchorHex,
    required this.darkAnchorHex,
    required this.primaryHex,
    this.darkPrimaryHex,
    this.lightPrimaryHex,
    this.errorHex,
    this.darkErrorHex,
    this.lightErrorHex,
    this.warningHex,
    this.darkWarningHex,
    this.lightWarningHex,
    this.infoHex,
    this.darkInfoHex,
    this.lightInfoHex,
    this.successHex,
    this.darkSuccessHex,
    this.lightSuccessHex,
    this.borderHex,
    this.darkBorderHex,
    this.lightBorderHex,
    this.dividerHex,
    this.darkDividerHex,
    this.lightDividerHex,
    this.whiteHex,
    required this.shape,
    this.baseRadius,
    required this.density,
    this.baseSpacing,
    this.fontFamily,
    this.baseFontSize = 14.0,
    this.minFontWeightValue,
  });

  /// Creates a [ThemeConfig] from a [ThemePreset].
  factory ThemeConfig.fromPreset(ThemePreset preset) {
    return ThemeConfig(
      id: preset.id,
      name: preset.name,
      description: preset.description,
      lightAnchorHex: _colorToHex(preset.lightAnchor),
      darkAnchorHex: _colorToHex(preset.darkAnchor),
      primaryHex: _colorToHex(preset.primaryColor),
      darkPrimaryHex: preset.darkPrimaryColor != null ? _colorToHex(preset.darkPrimaryColor!) : null,
      lightPrimaryHex: preset.lightPrimaryColor != null ? _colorToHex(preset.lightPrimaryColor!) : null,
      errorHex: preset.errorColor != null ? _colorToHex(preset.errorColor!) : null,
      darkErrorHex: preset.darkErrorColor != null ? _colorToHex(preset.darkErrorColor!) : null,
      lightErrorHex: preset.lightErrorColor != null ? _colorToHex(preset.lightErrorColor!) : null,
      warningHex: preset.warningColor != null ? _colorToHex(preset.warningColor!) : null,
      darkWarningHex: preset.darkWarningColor != null ? _colorToHex(preset.darkWarningColor!) : null,
      lightWarningHex: preset.lightWarningColor != null ? _colorToHex(preset.lightWarningColor!) : null,
      infoHex: preset.infoColor != null ? _colorToHex(preset.infoColor!) : null,
      darkInfoHex: preset.darkInfoColor != null ? _colorToHex(preset.darkInfoColor!) : null,
      lightInfoHex: preset.lightInfoColor != null ? _colorToHex(preset.lightInfoColor!) : null,
      successHex: preset.successColor != null ? _colorToHex(preset.successColor!) : null,
      darkSuccessHex: preset.darkSuccessColor != null ? _colorToHex(preset.darkSuccessColor!) : null,
      lightSuccessHex: preset.lightSuccessColor != null ? _colorToHex(preset.lightSuccessColor!) : null,
      borderHex: preset.borderColor != null ? _colorToHex(preset.borderColor!) : null,
      darkBorderHex: preset.darkBorderColor != null ? _colorToHex(preset.darkBorderColor!) : null,
      lightBorderHex: preset.lightBorderColor != null ? _colorToHex(preset.lightBorderColor!) : null,
      dividerHex: preset.dividerColor != null ? _colorToHex(preset.dividerColor!) : null,
      darkDividerHex: preset.darkDividerColor != null ? _colorToHex(preset.darkDividerColor!) : null,
      lightDividerHex: preset.lightDividerColor != null ? _colorToHex(preset.lightDividerColor!) : null,
      whiteHex: preset.whiteColor != null ? _colorToHex(preset.whiteColor!) : null,
      shape: preset.shape == ShapePreset.sharp ? 'sharp' : 'rounded',
      baseRadius: preset.baseRadius,
      density: preset.density == DensityPreset.compact ? 'compact' : 'comfortable',
      baseSpacing: preset.baseSpacing,
      fontFamily: preset.fontFamily,
      baseFontSize: preset.baseFontSize,
      minFontWeightValue: preset.minFontWeight?.value,
    );
  }

  /// Converts this configuration into a runnable [ThemePreset].
  ThemePreset toPreset() {
    return ThemePreset(
      id: id,
      name: name,
      description: description,
      lightAnchor: _parseHex(lightAnchorHex),
      darkAnchor: _parseHex(darkAnchorHex),
      primaryColor: _parseHex(primaryHex),
      darkPrimaryColor: darkPrimaryHex != null ? _parseHex(darkPrimaryHex!) : null,
      lightPrimaryColor: lightPrimaryHex != null ? _parseHex(lightPrimaryHex!) : null,
      errorColor: errorHex != null ? _parseHex(errorHex!) : null,
      darkErrorColor: darkErrorHex != null ? _parseHex(darkErrorHex!) : null,
      lightErrorColor: lightErrorHex != null ? _parseHex(lightErrorHex!) : null,
      warningColor: warningHex != null ? _parseHex(warningHex!) : null,
      darkWarningColor: darkWarningHex != null ? _parseHex(darkWarningHex!) : null,
      lightWarningColor: lightWarningHex != null ? _parseHex(lightWarningHex!) : null,
      infoColor: infoHex != null ? _parseHex(infoHex!) : null,
      darkInfoColor: darkInfoHex != null ? _parseHex(darkInfoHex!) : null,
      lightInfoColor: lightInfoHex != null ? _parseHex(lightInfoHex!) : null,
      successColor: successHex != null ? _parseHex(successHex!) : null,
      darkSuccessColor: darkSuccessHex != null ? _parseHex(darkSuccessHex!) : null,
      lightSuccessColor: lightSuccessHex != null ? _parseHex(lightSuccessHex!) : null,
      borderColor: borderHex != null ? _parseHex(borderHex!) : null,
      darkBorderColor: darkBorderHex != null ? _parseHex(darkBorderHex!) : null,
      lightBorderColor: lightBorderHex != null ? _parseHex(lightBorderHex!) : null,
      dividerColor: dividerHex != null ? _parseHex(dividerHex!) : null,
      darkDividerColor: darkDividerHex != null ? _parseHex(darkDividerHex!) : null,
      lightDividerColor: lightDividerHex != null ? _parseHex(lightDividerHex!) : null,
      whiteColor: whiteHex != null ? _parseHex(whiteHex!) : null,
      shape: shape == 'sharp' ? ShapePreset.sharp : ShapePreset.rounded,
      baseRadius: baseRadius,
      density: density == 'compact' ? DensityPreset.compact : DensityPreset.comfortable,
      baseSpacing: baseSpacing,
      fontFamily: fontFamily,
      baseFontSize: baseFontSize,
      minFontWeight: minFontWeightValue != null
          ? FontWeight.values.where((w) => w.value == minFontWeightValue).firstOrNull
          : null,
      isBuiltIn: false,
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'lightAnchorHex': lightAnchorHex,
    'darkAnchorHex': darkAnchorHex,
    'primaryHex': primaryHex,
    if (darkPrimaryHex != null) 'darkPrimaryHex': darkPrimaryHex,
    if (lightPrimaryHex != null) 'lightPrimaryHex': lightPrimaryHex,
    if (errorHex != null) 'errorHex': errorHex,
    if (darkErrorHex != null) 'darkErrorHex': darkErrorHex,
    if (lightErrorHex != null) 'lightErrorHex': lightErrorHex,
    if (warningHex != null) 'warningHex': warningHex,
    if (darkWarningHex != null) 'darkWarningHex': darkWarningHex,
    if (lightWarningHex != null) 'lightWarningHex': lightWarningHex,
    if (infoHex != null) 'infoHex': infoHex,
    if (darkInfoHex != null) 'darkInfoHex': darkInfoHex,
    if (lightInfoHex != null) 'lightInfoHex': lightInfoHex,
    if (successHex != null) 'successHex': successHex,
    if (darkSuccessHex != null) 'darkSuccessHex': darkSuccessHex,
    if (lightSuccessHex != null) 'lightSuccessHex': lightSuccessHex,
    if (borderHex != null) 'borderHex': borderHex,
    if (darkBorderHex != null) 'darkBorderHex': darkBorderHex,
    if (lightBorderHex != null) 'lightBorderHex': lightBorderHex,
    if (dividerHex != null) 'dividerHex': dividerHex,
    if (darkDividerHex != null) 'darkDividerHex': darkDividerHex,
    if (lightDividerHex != null) 'lightDividerHex': lightDividerHex,
    if (whiteHex != null) 'whiteHex': whiteHex,
    'shape': shape,
    if (baseRadius != null) 'baseRadius': baseRadius,
    'density': density,
    if (baseSpacing != null) 'baseSpacing': baseSpacing,
    if (fontFamily != null) 'fontFamily': fontFamily,
    'baseFontSize': baseFontSize,
    if (minFontWeightValue != null) 'minFontWeightValue': minFontWeightValue,
  };

  /// Deserializes from JSON map.
  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      id: json['id'] as String? ?? 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Custom Preset',
      description: json['description'] as String? ?? '',
      lightAnchorHex: json['lightAnchorHex'] as String? ?? '#F4F5F7',
      darkAnchorHex: json['darkAnchorHex'] as String? ?? '#101010',
      primaryHex: json['primaryHex'] as String? ?? '#2563EB',
      darkPrimaryHex: json['darkPrimaryHex'] as String?,
      lightPrimaryHex: json['lightPrimaryHex'] as String?,
      errorHex: json['errorHex'] as String?,
      darkErrorHex: json['darkErrorHex'] as String?,
      lightErrorHex: json['lightErrorHex'] as String?,
      warningHex: json['warningHex'] as String?,
      darkWarningHex: json['darkWarningHex'] as String?,
      lightWarningHex: json['lightWarningHex'] as String?,
      infoHex: json['infoHex'] as String?,
      darkInfoHex: json['darkInfoHex'] as String?,
      lightInfoHex: json['lightInfoHex'] as String?,
      successHex: json['successHex'] as String?,
      darkSuccessHex: json['darkSuccessHex'] as String?,
      lightSuccessHex: json['lightSuccessHex'] as String?,
      borderHex: json['borderHex'] as String?,
      darkBorderHex: json['darkBorderHex'] as String?,
      lightBorderHex: json['lightBorderHex'] as String?,
      dividerHex: json['dividerHex'] as String?,
      darkDividerHex: json['darkDividerHex'] as String?,
      lightDividerHex: json['lightDividerHex'] as String?,
      whiteHex: json['whiteHex'] as String?,
      shape: json['shape'] as String? ?? 'rounded',
      baseRadius: (json['baseRadius'] as num?)?.toDouble(),
      density: json['density'] as String? ?? 'comfortable',
      baseSpacing: (json['baseSpacing'] as num?)?.toDouble(),
      fontFamily: json['fontFamily'] as String?,
      baseFontSize: (json['baseFontSize'] as num?)?.toDouble() ?? 14.0,
      minFontWeightValue: json['minFontWeightValue'] as int?,
    );
  }

  static String _colorToHex(Color color) {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }

  static Color _parseHex(String hex) {
    var clean = hex.replaceAll('#', '').trim();
    if (clean.length == 6) {
      clean = 'FF$clean';
    }
    return Color(int.parse(clean, radix: 16));
  }
}
